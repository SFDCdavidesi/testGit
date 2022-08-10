/*********************************************************************************************************************************
@ Class:         TransferSellersController
@ Version:       1.0
@ Author:        Loumang SENG (loumang.seng@gaea-sys.com)
@ Purpose:       US-0009600 - [Pro-Trader] In Flight transfer of Cohort Sellers within Pro-Trader
@				 Given that I am any user with "BoB Category Lead" Permission
@				 Select a Cohort Seller(related to Light Touch Category Cohort and BoB__c.Managed Type = "Pro-Trader")
@				 Click "Transfer Sellers" should open a new Component that displays
@				 All Light Touch Category Cohorts(with status = Cohort Active and Managed Type = Pro-Trader)
@				 Select a Cohort and click "Save
@				 so that the Cohort Seller , related Actions are transferred to new BoB or Cohort record selected.
@				US-0009917 - In Flight transfer of Cohort Sellers to from and to any "Light Touch Category Cohorts"
@				Given that I am any user with "BoB Category Lead" permissionSelect any Cohort(record type = Light touch category Cohort and Status = Cohort Active)
@				when I click "Transfer Sellers" in the Cohort Seller List View,
@				the Component should display all Cohorts(with record type = Light touch category Cohort and Status = Cohort Active)
@				the Component also displays below 2 fields which they can populate (BoB_Seller__C.Account_Manager__c , BoB_Seller__C.TTEC_MANAGER__c)
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:  	08.06.2021 / Loumang SENG (loumang.seng@gaea-sys.com) / Created the class.
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:  	27.07.2021 / Sovantheany Dim (sovantheany.dim@gaea-sys.com) / updated the class.US-0009917
*********************************************************************************************************************************/
public without sharing class TransferSellersController {
    /******************* CONTROLLER FOR VF PAGE *****************************/
	public String   bobId           {get;set;}
    public String   bobSellerIds    {get;set;}
    public Boolean  isError         {get;set;} 

    private final static String STATUS_BOB_ACTIVE = 'BoB Active';
    private final static String PRO_TRADER = 'LTTM Managed';
    
    public TransferSellersController(ApexPages.StandardSetController controller)
    {
        List<BoB_Seller__c> bobSellers = controller.getSelected();
		bobId = (ApexPages.currentPage().getParameters().get('id')!=null)?String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id')):'';
        List<String> tmpIds = new List<Id>();
        for(BOB_Seller__c bs: bobSellers){
            tmpIds.add(bs.Id);

        }
        bobSellerIds = (tmpIds.isEmpty())?'':String.join(tmpIds, ',');

    }

    @AuraEnabled
    public static Map<String,Object> apexInit(String bobId, String bobSellerIds)
    {	
        
        Map<String,Object> mapResult = new Map<String,Object>();
        if(String.isBlank(bobSellerIds)){
            mapResult.put('status','ko');
            mapResult.put('error',System.Label.COHORT_SELLERS_ERROR);
            mapResult.put('noCohortSellersError',true);
            return mapResult;

        }
        Id recTypeLTTMId = ApexUtil.getRecordTypeByName('BoB_Seller__c',System.Label.BoBSellerRecordType_LTTM).Id;
        List<String> tmp = bobSellerIds.split(',');
        List<BoB_Seller__c> listBS= [select Id, Managed_Type__c,RecordTypeId from BoB_Seller__c where Id in:tmp];
        
        for (BoB_Seller__c bobSeller: listBS) {
            if( bobSeller.RecordTypeId != recTypeLTTMId){ 
                mapResult.put('status','ko');
                mapResult.put('error','Incorrect record type');
                return mapResult;
             }
             //TH: 27/07/2021 : US-0009917: comment out, so that all Manage type can be transfer
            /*if( bobSeller.Managed_Type__c != PRO_TRADER){ //'LTTM Managed'
                mapResult.put('status','ko');
                mapResult.put('error',System.Label.CohortSeller_NOT_Protrader_Error);
                mapResult.put('noCohortSellersError',false);
                return mapResult;
            }*/
            
        }

        //String recLTCC = 'Light_Touch_Category_Cohort';
        Id recLTCC = ApexUtil.getRecordTypeByName('BOB__c','Light_Touch_Category_Cohort').Id;
        String sWhereBob  = ' Where Id <>\''+bobId+'\' AND RecordTypeId =\''+recLTCC+'\' AND Status__c=\''+STATUS_BOB_ACTIVE+'\'';//AND Managed_Type__c =\''+PRO_TRADER+'\' //TH: US-0009917: comment out, so that all Manage type can be transfer 
        List<ColName> listColNameBOB = new List<ColName>();
        Set<String> setFieldNameBOB = new Set<String>{'id'};
        Map<String,String> mapFixPkl = new Map<String,String>{'Managed_Type__c'=>'toLabel(Managed_Type__c)lbl_Managed_Type__c','Status__c'=>'toLabel(Status__c)lbl_Status__c'};
        Map<String,String> mapFixPklForCol = new Map<String,String>{'Managed_Type__c'=>'lbl_Managed_Type__c','Status__c'=>'lbl_Status__c'};
        Map<String,String> mapFixLabel = new Map<String,String>{'Account_Manager__r.Name'=>'Account Manager'};
        for(Schema.FieldSetMember f: SObjectType.BOB__c.FieldSets.TransferSellers.getFields())
        {
            setFieldNameBOB.add(mapFixPkl.containsKey(f.getFieldPath())?mapFixPkl.get(f.getFieldPath()):f.getFieldPath() );
            if(f.getFieldPath().contains('.') && f.getFieldPath().endsWith('Name'))
        	{
        		String fId = ApexUtil.getFieldIdRef(f.getFieldPath());
        		setFieldNameBOB.add(fId);
        	}
            listColNameBOB.add(
                new ColName(mapFixLabel.containsKey(f.getFieldPath())?mapFixLabel.get(f.getFieldPath()):f.getLabel(),
                mapFixPklForCol.containsKey(f.getFieldPath())?mapFixPklForCol.get(f.getFieldPath()):f.getFieldPath(),
                f.getType()+'')
            );
        }
        //String soql_bob = 'Select '+String.join(new List<String>(setFieldNameBOB),',')+', Account_Manager__r.Name From BOB__c';
        String soql_bob = 'Select '+String.join(new List<String>(setFieldNameBOB),',')+' From BOB__c';
        mapResult.put('status','ok');
        mapResult.put('soql_bob',soql_bob);
        mapResult.put('sWhereBob',sWhereBob);
        mapResult.put('listColNameBOB',listColNameBOB);
        mapResult.put('sitePrefix',Site.getPathPrefix());
        
        return mapResult;
    }
    
	@AuraEnabled
	public static Map<String,Object> apexSave(String newbobId, String bobSellerIds,BoB_Seller__c bobSeller){
		Map<String,Object> mapResult = new Map<String,Object>();
		try {
			List<String> listBSId = bobSellerIds.split(',');
            if(!listBSId.isEmpty() && String.isNotBlank(newbobId)){
            	List<BOB__c> bobs = [select Account_Manager__c from BOB__c where id =: newbobId];
                List<BoB_Seller__c> listbs = New List<BoB_Seller__c>();
                for(BoB_Seller__c bs : [select Id, BoB__c,Account_Manager__c,TTEC_MANAGER__c from BoB_Seller__c where Id In:listBSId]){
                    bs.BoB__c = newbobId;
                    //TH: US-0009917 :set bs.Account_Manager__c and bs.TTEC_MANAGER__c
                    bs.Account_Manager__c = bobSeller.Account_Manager__c != null ? bobSeller.Account_Manager__c : bobs[0].Account_Manager__c;
                    bs.TTEC_MANAGER__c = bobSeller.TTEC_MANAGER__c != null ? bobSeller.TTEC_MANAGER__c : null;
                	listbs.add(bs);
                }
                if(!listbs.isEmpty()) update listbs;
            }
			mapResult.put('status','ok');
		}catch(DMLException dex)
    	{	mapResult.put('status','ko');mapResult.put('error',dex.getDmlMessage(0));mapResult.put('errorDetail',dex.getStackTraceString());
    	}catch(Exception ex)
    	{  mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString());	}
        
		return mapResult;
	}
    
    static Map<String,String> mapLinkField = new Map<String,String>{'Account_Manager__r.Name'=>'Account_Manager__c'};
    
    class ColName{
    	@AuraEnabled
    	public String label;
    	
    	@AuraEnabled
    	public String fieldName;
      
        @AuraEnabled
    	public String type;
    	
    	@AuraEnabled
    	public Map<String,Object> typeAttributes;
    	
    	public ColName(String label,String fieldName,String type)
    	{
    		this.label = label;
    		this.fieldName = fieldName;
    		this.type = type.toLowerCase();
    		if(mapLinkField.containsKey(fieldName))
    		{
    			typeAttributes = new Map<String,Object>{
    				'label' => new Map<String,Object>{'fieldName'=>mapLinkField.get(fieldName)},
    				'target'=>'_blank',
    				'tooltip'=>''
    			};

    			this.fieldName = 'link_'+mapLinkField.get(fieldName);
    			this.type = 'url';

    		}else if(this.type.equalsIgnoreCase('datetime')){
                this.type = 'date';
                typeAttributes = new Map<String,Object>{
                    'label' => new Map<String,Object>{'fieldName'=>fieldName},
                    'day' => 'numeric',
                    'month'=> 'short',
                    'year'=> 'numeric',
                    'hour'=> '2-digit',
                    'minute'=> '2-digit',
                    'second'=> '2-digit',
                    'hour12'=> false
                };
            }
    	}
    }
	

}