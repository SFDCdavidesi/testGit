/**
 * @change        created mappingSObjectLabel method 
 * @modifiedDate  21/10/2021
 * @modifiedBy    Samnang MUONG
 */
public with sharing class CustomSearchController {

  @AuraEnabled
  public static List<SObject> searchRecords(String searchText) {

    List<SObject> results = new List<SObject>();

   // String currentId = System.UserInfo.getUserId();
    
    String str='%'+searchText+ '%';

    List<EBH_Deal__c> ebhDeal= [SELECT EBH_Deal__c.Id,EBH_Deal__c.EBH_ProductTitle__c, RecordType.SobjectType FROM EBH_Deal__c 
     WHERE Name Like:str OR EBH_ProductTitle__c Like:str OR EBH_DealRetailCampaign__r.EBH_DealTitle__c Like:
     str OR EBH_DealRetailCampaign__r.Name Like:str OR EBH_eBayItemID__c Like:str LIMIT 5];

     List<EBH_DealRetailCampaign__c> ebhDealRetailCampaign =[SELECT Id,EBH_DealTitle__c, RecordType.SobjectType from EBH_DealRetailCampaign__c
     WHERE Name Like:str OR EBH_DealTitle__c Like:str OR Status__c Like:str LIMIT 5];
     
     results.addAll(ebhDeal);
     results.addAll(ebhDealRetailCampaign);
     return results;
         
  }


  @AuraEnabled(cacheable=true)
  public static List<EBH_Deal__c> searchDealRecords(String searchText) {
    String str='%'+searchText+ '%';
    List<EBH_Deal__c> ebhDeal= [SELECT Id,EBH_eBayItemID__c,EBH_ProductTitle__c,Status_Seller_Portal__c,EBH_DealPrice__c,EBH_RRPWASPrice__c,EBH_Quantity__c,EBH_Category__c,EBH_DealStartDate__c,EBH_DealEndDate__c FROM EBH_Deal__c 
    WHERE Name Like:str OR EBH_ProductTitle__c Like:str OR EBH_DealRetailCampaign__r.EBH_DealTitle__c Like:
    str OR EBH_DealRetailCampaign__r.Name Like:str OR EBH_eBayItemID__c Like:str];

    return ebhDeal;
         
  }



  
  @AuraEnabled(cacheable=true)
  public static List<EBH_DealRetailCampaign__c> searchDealCampaignRecords(String searchText) {
    String str='%'+searchText+ '%';
    List<EBH_DealRetailCampaign__c> ebhDealRetailCampaign =[SELECT Id,Name,EBH_Date__c,EPH_EndDate__c,Status_Seller_Portal__c from EBH_DealRetailCampaign__c
    WHERE Name Like:str OR EBH_DealTitle__c Like:str OR Status__c Like:str];

    return ebhDealRetailCampaign;
         
  }


   /***********************************************************************************************************************************
    @ Method:       mappingSObjectLabel 
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Param:    List<String> lstObjNames
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Returns map label of object and fields
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: ??.??.?? / Trigg / @description Method call from customer search component for get sobject label
    @               : 16.12.2021 / vadhanak voun / US-0010919 - [SP EU - Deals] Adjustments required to hide Generic Features                                        
    ***********************************************************************************************************************************/
  @AuraEnabled
  public static Map<String, Object> mappingSObjectLabel(List<String> lstObjNames){

    Map<String, Object> mapObj = new Map<String, Object>();

   // List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(lstObjNames); 
      Map<String, String> mapAPIName2Label = new Map<String, String>();
      Map<String, String> mapFieldAPIName2Label = new Map<String, String>();
      for (Schema.DescribeSObjectResult desObjRes :Schema.describeSObjects(lstObjNames)) {
        
          // mapping object name with label
          mapAPIName2Label.put(desObjRes.getName(), desObjRes.getLabel());

          // fetch fields
          Map<String, Schema.SObjectField> fieldMap = desObjRes.fields.getMap();
          
          for (String fieldName :fieldMap.keySet()) {

            String key = desObjRes.getName()+fieldMap.get(fieldName).getDescribe().getName(); // key : Object Name + Field Name
            mapFieldAPIName2Label.put(key, fieldMap.get(fieldName).getDescribe().getLabel());     
          
          }  

      }

      // add to return map

      mapObj.put('mapSobject', mapAPIName2Label);
      mapObj.put('mapField', mapFieldAPIName2Label);

      //NK:16/12/2021:US-0010919:
      mapObj.put('hasPermission', (Schema.sObjectType.EBH_Deal__c.isAccessible() && Schema.sObjectType.EBH_DealRetailCampaign__c.isAccessible()));

      return mapObj;
    
  }

}