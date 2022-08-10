/*********************************************************************************************************************************
@ Interface:     DealListViewFilterController
@ Version:       1.0
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 27.01.2022 / Mony Nou (mony.nou@gaea-sys.com) / US-0010983 - Rejection Reason pick values on Filter needs to be adjusted
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 28.01.2022 / Mony Nou (mony.nou@gaea-sys.com) / US-0011174 - Updates/ Addition To-Do list and List Views
*********************************************************************************************************************************/
public with sharing class DealListViewFilterController {


        /*****************************************************************************************************************************
        @ Method:   getAllPickListValue
        @ Version:  1.0
        @ Purpose:  Retrieve all picklist value for Picklist field in List View Filter Section
        ------------------------------------------------------------------------------------------------------------------------------
        @ Parameter:      sObject's API Name , Array of field's API Name , Site Number
        ------------------------------------------------------------------------------------------------------------------------------
        @ Change history: 27.01.2022 / Mony Nou (mony.nou@gaea-sys.com) / US-0010983 - Rejection Reason pick values on Filter needs to be adjusted
        *****************************************************************************************************************************/
        @AuraEnabled(cacheable=true)
        public static Map<String, List<SelectOptionObj>> getAllPickListValue(String objectApiName, List<String> field_name, String siteId) { //MN-27012022-US-0010983-Added new param siteId that will pass from lwcListViewFilter
            
            List<SelectOptionObj> picklistOptionsCopy = new List<SelectOptionObj>();
            Map<String, List<SelectOptionObj>> picklistFieldValues = new Map<String, List<SelectOptionObj>>();
            
            if (field_name.isEmpty()) return picklistFieldValues; //MN-28012022-Avoid list of out of bound error
            
            String fieldApiName = field_name.get(0);
            
            try {
                Schema.SObjectType obj_describe = Schema.getGlobalDescribe().get(objectApiName) ;
                Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe() ;
                Map<String,Schema.SObjectField> fields = obj_describe_result.fields.getMap() ;
                for(String fieldName: field_name){
                    // System.debug('fieldName: '+fieldName);
                    Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
                    
                    
                    //MN-27012022-US-0010983
                    List<SelectOptionObj> picklistOptions = new List<SelectOptionObj>();
                    Boolean getDepValue = false;

                    if (fieldResult.isDependentPicklist()) { //MN-27012022-US-0010983
                        String control_field = fieldResult.getController().getDescribe().getName();
                        
                        Map<String,List<ApexUtil.PicklistEntryWrapper>> pklDepPicklistVal  = ApexUtil.getDependentMap(obj_describe,control_field,fieldName);
                       
                        if (pklDepPicklistVal.containsKey(siteId)) {
                            getDepValue = true;
                            for (ApexUtil.PicklistEntryWrapper plew : pklDepPicklistVal.get(siteId)) {
                                SelectOptionObj option = new SelectOptionObj(plew.label, plew.value);
                                picklistOptions.add(option);
                            }
                        }

                    }
                    
                    if (!getDepValue) { //MN-27012022-US-0010983

                        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                        SelectOptionObj option = null;
                        for (Schema.PicklistEntry pickListVal : ple) {
                            // System.debug('pickListVal: '+pickListVal);

                            option = new SelectOptionObj(pickListVal.getLabel(), pickListVal.getValue());
                            picklistOptions.add(option);
                        }
                    }   
                    /* //MN-27012022-US-0010983
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    SelectOptionObj option = null;
                    List<SelectOptionObj> picklistOptions = new List<SelectOptionObj>();
                    for (Schema.PicklistEntry pickListVal : ple) {
                        System.debug('pickListVal: '+pickListVal);

                        option = new SelectOptionObj(pickListVal.getLabel(), pickListVal.getValue());
                        picklistOptions.add(option);
                    }
                    */
                    picklistFieldValues.put(fieldName, picklistOptions.clone());
                }                
            } catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            }
            return picklistFieldValues;
        }
        public class SelectOptionObj {
            @AuraEnabled
            public String label { get; set; }
            @AuraEnabled
            public String value { get; set; }
            
            public SelectOptionObj(String label, String val) {
                this.label = label;
                this.value = val;
            }
        }
        
        public class PickListWrapperClass{
            @AuraEnabled public List<EBH_Deal__c> statusOptions{get;set;}
            @AuraEnabled public List<EBH_Deal__c> getRejectionReason{get;set;} 
            @AuraEnabled public List<EBH_Deal__c> getDealFormat{get;set;}      
           
        }

        @AuraEnabled(cacheable=true) 
        public static metadaWrapperClass filterFieldsMetadata(String objectAPIName, String listViewName){ //MN-08112021-US-0010640 - Add param listViewName
            
            metadaWrapperClass obj = new metadaWrapperClass();
            obj.userLanguage = UserInfo.getLanguage();
            System.debug('userLanguage===>'+obj.userLanguage);
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objectAPIName) ;            
            Schema.DescribeSObjectResult r = s.getDescribe() ;            
            Map<String,Schema.SObjectField> fields = r.fields.getMap() ; 
            obj.fieldsMetadata = new List<Seller_Portal_List_View_Filter__mdt>();
            //MN-08112021-US-0010640 - add field List_View_Name__c in query
            //MN-28012022-US-0011174 - Updates/ Addition To-Do list and List Views - add field Site__c in query
            for(Seller_Portal_List_View_Filter__mdt mdta: [SELECT Site__c, List_View_Name__c, DeveloperName,Field_API_Name__c,Field_Data_Type__c,Field_Label__c,Object_API_Name__c,Id FROM Seller_Portal_List_View_Filter__mdt where Object_API_Name__c=:objectAPIName order by Field_Data_Type__c, Field_API_Name__c DESC]){
                if (String.isBlank(mdta.List_View_Name__c) || mdta.List_View_Name__c.contains(listViewName)) { //MN-08112021-US-0010640 Display correct fields for Deal List Views
                    Schema.DescribeFieldResult fieldResult = fields.get(mdta.Field_API_Name__c).getDescribe();
                    mdta.Field_Label__c = fieldResult.getLabel();
                    obj.fieldsMetadata.add(mdta);
                }
            }
            return obj;
        }

        public class metadaWrapperClass{
            @AuraEnabled public List<Seller_Portal_List_View_Filter__mdt> fieldsMetadata{get;set;}
            @AuraEnabled public String userLanguage{get;set;}
        }
       
}