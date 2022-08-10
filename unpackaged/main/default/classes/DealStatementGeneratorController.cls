/*********************************************************************************************************************************
@ Class:          DealStatementGeneratorController
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        US-0010376 - [NA Deal Statement] Monthly Statement Summary and Approval
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 14.10.2021 / Sovantheany Dim / Created the class.                
*********************************************************************************************************************************/
public with sharing class DealStatementGeneratorController {
    private final static String SOQL_DEALSTATEMENT = 'select id[PLACEHOLDER] from Deal_Statement__c';
    private final static String SOQL_DEALSTATEMENTSUMMARY = 'select Summary_Name__c, Month__c, Year__c, Statement_Type__c, id from Deal_Statement_Summary__c';
    private static Map<String,String> mapField_Type = new Map<String,String>{
        '1st Statement'=>'X1st_Statement_Approved__c',
        'Final Statement'=>'Final_Statement_Approved__c',
        'Adjusted Statement'=>'Adjustment_Approved__c'
    };
    private static set<String> sFields = new set<String>{'eBay_Seller__r.Name','Month__c','Year__c','Initial_Payout__c','Total_Paid_Out__c','Subsidy_30_Day_Calculation__c','Amount_Held_Back__c','Subsidy_Final_Calculation__c','Second_Payout__c','Disputes_Payout__c'};
    private static Map<String,String[]> mapHeaderCol = new Map<String,String[]>
    {
    	'US'=>new String[]{'\uFEFFeBay Seller:Business Name','Month','Year','Initial Payout (60%)','Total Paid Out','Subsidy 30 Day Calculation','Subsidy Amount Held Back (40%)','Subsidy Final (60-Day) Calculation','Subsidy Final Payout','Adjusted Payout'}
    };
    /*****************************************************************************************************************************
	@ Method:   generateToExcel
	@ Version:  1.0
	@ Author:   Sovantheany Dim (sovantheany.dim@gaea-sys.com)
	@ Purpose:  US-0010376 - [NA Deal Statement] Monthly Statement Summary and Approval
	@			Summary Excel will use Month, Year and Statement Type to select Deal Statements to be selected for the file. Only Deal Statements which match Month, Year and the fields in AC1 matching the Statement Type will be included. If AC1 field is FALSE, then that Statement is excluded.
	@			AC5) If no matching Deal Statements for the criteria is found. System will give error message: 'No Deal Statements found for this Summary'
	@			AC5) If Excel file is successfully generated. Deal Statement Summary 'Status' field will be updated to 'Ready for Approval' and Excel file is attached to the Deal Statement Summary record.
	------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 14.10.2021/ Sovantheany Dim / Created the  Method.
	*****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String, Object> generateToExcel(String parentId) {
        Map<String, Object> mResult = new Map<String, Object>();
        List<Attachment> lstAttach = new List<Attachment>();
        String key = 'US';
        String[] listHeader = mapHeaderCol.containsKey(key)?mapHeaderCol.get(key):null;
        List<List<String>> listRows = new List<List<String>>{listHeader};
        try{
            //get deal statement summary
            String month = '';
            String year = '';
            String where_Type = '';
            String dssName = '';
            for(Deal_Statement_Summary__c dss : Database.query(SOQL_DEALSTATEMENTSUMMARY+' where id =: parentId')){
                month = dss.Month__c;
                year = dss.Year__c;
                if(!String.isEmpty(dss.Statement_Type__c) && mapField_Type.containsKey(dss.Statement_Type__c)) where_Type += ' AND '+mapField_Type.get(dss.Statement_Type__c)+' = true';
            	dssName = dss.Summary_Name__c;
            }
            //convert Year from string to integer
            Integer year_int = Integer.valueOf(year);
            String fields = ','+String.join(new List<String>(sFields),',');
            String soql_dealstatement2 = SOQL_DEALSTATEMENT.replace('[PLACEHOLDER]', fields).replace('Month__c','toLabel(Month__c)');
            boolean hasDealStement = false;
            //get Deal Statement
            for(Deal_Statement__c ds : Database.query(soql_dealstatement2+' where Month__c =: month AND Year__c =: year_int'+where_Type)){
            	hasDealStement = true;
                List<String> listCells = new List<String>();
                for(String f : sFields){
                    listCells.add(getFieldValue(f,ds,'UK'));
                }
                listRows.add(listCells);
            }
            if(hasDealStement){
                //update Deal Statement Summary 'Status' to 'Ready for Approval'
                Deal_Statement_Summary__c dssReadyForApproval = new Deal_Statement_Summary__c(id=parentId ,Status__c = 'Ready for Approval');
              	update dssReadyForApproval;
                //generate to excel file
                List<ExcelGenerator.xSheet> listSheets = new List<ExcelGenerator.xSheet>();
                ExcelGenerator.xSheet sheetSTP = new ExcelGenerator.xSheet('Sheet1',listRows);
                listSheets.add(sheetSTP);
                ExcelGenerator generator = new ExcelGenerator(userinfo.getname(),listSheets);
                generator.generateWorkBook();
                String xml = generator.getWorkbookXML();
                String fileName = dssName+'.xls';
                //attached Excel file  to the Deal Statement Summary record
                Attachment attach = createAttachment(Blob.valueOf(xml), filename,'application/vnd.ms-excel', parentId);
                lstAttach.add(attach);
                insert lstAttach;
                mResult.put('isSuccess', true);
                mResult.put('msg', System.label.successAddFile_msg);  
            }else{
               	mResult.put('isSuccess', false);
           		mResult.put('msg', System.label.failAddFile_msg); 
            }
        }catch (Exception ex) { mResult.put('isSuccess', false);mResult.put('msg', ex.getMessage());}
        return mResult;
    }
    
    private static Attachment createAttachment(Blob body, String fileName,String contentType, Id parentId) {
        Attachment att = new Attachment();
        att.Body = body;
        att.Name = fileName;
        att.IsPrivate = false;
        att.ContentType = contentType; 
        att.ParentId = parentId;
        return att;
    }
    private static Map<String,Schema.DisplayType> mapFieldType = new Map<String,Schema.DisplayType>
    {
    	'Deal_Statement__c:Initial_Payout__c' => Schema.DisplayType.Double,
    	'Deal_Statement__c:Total_Paid_Out__c' => Schema.DisplayType.Double,
    	'Deal_Statement__c:Subsidy_30_Day_Calculation__c' => Schema.DisplayType.Double,
    	'Deal_Statement__c:Amount_Held_Back__c' => Schema.DisplayType.Double,
    	'Deal_Statement__c:Subsidy_Final_Calculation__c'=> Schema.DisplayType.Double,
    	'Deal_Statement__c:Second_Payout__c' => Schema.DisplayType.Double,
        'Deal_Statement__c:Disputes_Payout__c' => Schema.DisplayType.Double
    };
    private static String getFieldValue(String fieldName,Sobject sobj,String revRoll)
    {
    	//System.debug('>>>fieldName: '+fieldName);
    	Object val = ApexUtil.getValue(fieldName,sobj);
    	if(val==null)
    	{
    		return '';
        }else{
            if(!mapFieldType.containsKey(sobj.getSObjectType()+':'+fieldName)){
            	return val+''; 
        	}
            Schema.DisplayType fType =  mapFieldType.get(sobj.getSObjectType()+':'+fieldName);
            if(Schema.DisplayType.Percent ==fType)
            {
                //return val +' %';
                return ApexUtil.formatNumber((Decimal)val,2,revRoll)+' %';
            }else if(Schema.DisplayType.Date ==  fType)
            {
                return ((Date)val).format();
            }else if(Schema.DisplayType.DateTime == fType)
            {
                return ((DateTime)val).format();
            }else if(Schema.DisplayType.Currency == fType|| Schema.DisplayType.Integer == fType  || Schema.DisplayType.Double == fType ||  Schema.DisplayType.Long == fType)
            {
                return ApexUtil.formatNumber((Decimal)val,2,revRoll);
            }
        }
    	return val+''; 
    } 
}