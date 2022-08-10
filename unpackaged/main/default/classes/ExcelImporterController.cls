/*********************************************************************************************************************************
@ Class:          ExcelImporterController
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        US-0011643 - SPIKE Implement Excel import module using JS to support copy paste
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:  17.06.2022 / Sophal Noch / Created the class.
*********************************************************************************************************************************/
public with sharing class ExcelImporterController {

    private static final String DML_INSERT = 'Insert';
    private static final String DML_UPDATE = 'Update';
    private static final String DML_UPSERT = 'Upsert';

    private static String TXT_LIST_RESULT = 'listResult';

    private static String SUCCESS_MSG_TEMPLATE = '{0} Success.';
    private static String ERROR_MSG_TEMPLATE = '{0} Failed. Error : {1}';

    public String templateName {set; get;}
    public Boolean hideTemplateName {set; get;}
    public Boolean hideActionBtns {set; get;}
    public Boolean hideListTable {set; get;}

    public ExcelImporterController(){
        templateName = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('template') != null ? System.currentPageReference().getParameters().get('template') : '');
        hideTemplateName = Boolean.valueOf(String.escapeSingleQuotes(System.currentPageReference().getParameters().get('hName') != null ? System.currentPageReference().getParameters().get('hName') : ''));
        hideActionBtns =  Boolean.valueOf(String.escapeSingleQuotes(System.currentPageReference().getParameters().get('hBtns') != null ? System.currentPageReference().getParameters().get('hBtns') : ''));
        hideListTable = Boolean.valueOf(String.escapeSingleQuotes(System.currentPageReference().getParameters().get('hTable') != null ? System.currentPageReference().getParameters().get('hTable') : ''));
    }

    /*****************************************************************************************************************************
    @ Method:       getExcelImporterTemplate
    @ Author:       Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:      US-0011643 - SPIKE Implement Excel import module using JS to support copy paste
    @ Event:		when init lwcExcelImporter page
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	Excel_Importer_Template__mdt api name : templateName
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 17.06.2022  / Sophal Noch / Created the method.
    @*****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Excel_Importer_Template__mdt> getExcelImporterTemplate(String templateName){
        Map<String,Excel_Importer_Template__mdt> mapExcelImportTemp = new Map<String,Excel_Importer_Template__mdt>();
        for(Excel_Importer_Template__mdt temp : [SELECT Id,MasterLabel, DeveloperName,Excel_Column_Names__c,Use_Excel_Column_Header_Mapping__c,Mapped_Field_Names__c,Sobject_Api_Name__c,Operator__c,Batch_Size__c FROM Excel_Importer_Template__mdt WHERE DeveloperName =: templateName]){ 
            mapExcelImportTemp.put(temp.DeveloperName, temp);
        }
        return mapExcelImportTemp;
    }

/*****************************************************************************************************************************
    @ Method:       getExcelImporterTemplate
    @ Author:       Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:      US-0011643 - SPIKE Implement Excel import module using JS to support copy paste
    @ Event:		when Upload from lwcExcelImporter page
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	name of object : sobjectApiName, dml operator : operator, List of records to save : listRecord
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 17.06.2022  / Sophal Noch / Created the method.
    @*****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> saveRecords(String sobjectApiName, String operator, List<Map<String,String>> listRecord){
        Map<String,Object> mapResult = new Map<String,Object>();
        Savepoint sp = Database.setSavepoint();
        try{
            List<SObject> listSobject = new List<SObject>();
            SObject newObj = Schema.getGlobalDescribe().get(sobjectApiName).newSObject();
            for(Map<String,String> mapObj : listRecord){
                SObject eachSobject = newObj.clone(false,false,false,false);
                for(String key : mapObj.keySet()){
                    // for upsert dml, skip when id column exists but id field value is blank to avoid upserting error.
                    if(operator == DML_UPSERT && key.toLowerCase().trim() == 'id' &&  String.isBlank(String.valueOf(mapObj.get(key)))) continue;
                    eachSobject.put(key.trim(),mapObj.get(key));
                }
                listSobject.add(eachSobject);
            }
            List<Map<String,Object>> listResult = new List<Map<String,Object>>();
            if(!listSobject.isEmpty()){
                if(operator == DML_INSERT || operator == DML_UPDATE){
                    List<Database.SaveResult> listSaveResult = new List<Database.SaveResult>();
                    if(operator == DML_INSERT){ listSaveResult = Database.insert(listSobject, false);}
                    else if(operator == DML_UPDATE){ listSaveResult = Database.update(listSobject, false);}
                    for(Database.SaveResult result : listSaveResult) {
                        populateResultMsg(operator, result.isSuccess(), (result.isSuccess() ? null : result.getErrors()[0].getMessage()), listResult);
                    }
                    mapResult.put(TXT_LIST_RESULT,listResult); // return result of insert or update
                }
                else if(operator == DML_UPSERT){
                    List<Database.UpsertResult> listUpsertResult = Database.upsert(listSobject, false);
                    for (Database.UpsertResult result : listUpsertResult) {
                        populateResultMsg(operator, result.isSuccess(), (result.isSuccess() ? null : result.getErrors()[0].getMessage()), listResult);
                    }
                    mapResult.put(TXT_LIST_RESULT,listResult); // return result of upsert
                }  
            }
            if(listResult.isEmpty()){mapResult.put('status','ko'); mapResult.put('error',Label.ExcelImporter_Error_NoSaveResult);  return mapResult;}
            
            mapResult.put('status','ok');
        }catch(Exception ex){ Database.rollback(sp); mapResult.put('status','ko'); mapResult.put('error',ex.getMessage());}
        return mapResult;
    }

    private static void populateResultMsg(String operator, Boolean isSuccess, String msg, List<Map<String,Object>> listResult){
        if (isSuccess) {
            listResult.add(new Map<String,Object>{'isSucess'=>true,'msg'=>String.format(SUCCESS_MSG_TEMPLATE, new String[]{operator})});
        }else {
            listResult.add(new Map<String,Object>{'isSucess'=>false,'msg'=>String.format(ERROR_MSG_TEMPLATE, new String[]{operator,msg})});
        }
    }

}