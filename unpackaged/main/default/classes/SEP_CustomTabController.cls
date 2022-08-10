/*********************************************************************************************************************************
@ Class:          SEP_CustomTabController
@ Version:        1.0
@ Author:         Sambath Seng (sambath.seng@gaea-sys.com)
@ Purpose:        US-0010743 - [SP - Seller Portal] [Bug] Fix how results are displayed on Global Search
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 2.12.2021 / Sambath Seng / Created the class.
*********************************************************************************************************************************/
public with sharing class SEP_CustomTabController {
    /*****************************************************************************************************************************
    @ Method:         getGlobalSearchTab
    @ Version:        1.0
    @ Author:         Sambath Seng (sambath.seng@gaea-sys.com)
    @ Purpose:        US-0010743 - [SP - Seller Portal] [Bug] Fix how results are displayed on Global Search
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String searchKey
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 2.12.2021 / Sambath Seng / Create the method
    *****************************************************************************************************************************/
    @AuraEnabled(cacheable=true) 
    public static Map<String, TabWrapper> getGlobalSearchTabs(String searchKey) {
        Set<String> customSettingNames = new Set<String>();
        Map<String, TabWrapper> mTabRecord = new Map<String, TabWrapper>();
        List<Seller_Portal_Setting__mdt> lstSpsMdt = getSellerPortalSetting('');
        for(Seller_Portal_Setting__mdt sps : lstSpsMdt){
            TabWrapper tw = new TabWrapper();
            tw.label = sps.MasterLabel;
            tw.developerName = sps.DeveloperName;
            tw.objectApi = sps.Object_API_Name__c;
            mTabRecord.put(sps.Object_API_Name__c, tw);
            customSettingNames.add(sps.DeveloperName);
        }
        Map<String, TabWrapper> mResult = new Map<String, TabWrapper>();
        for(String oString : customSettingNames){
            TabWrapper mSearchResult = getSearchResult(searchKey, oString);
            mResult.put(mSearchResult.objectApi,mSearchResult);
        }

        for(TabWrapper oTw : mTabRecord.values()){
            if(mResult.containsKey(oTw.objectApi)){
                oTw.recordCount = Integer.valueOf(mResult.get(oTw.objectApi).recordCount);
            }
        }
        return mTabRecord;
    }
    /*****************************************************************************************************************************
    @ Method:         getSearchResult
    @ Version:        1.0
    @ Author:         Sambath Seng (sambath.seng@gaea-sys.com)
    @ Purpose:        US-0010743 - [SP - Seller Portal] [Bug] Fix how results are displayed on Global Search
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String searchKey, String settingName
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 2.12.2021 / Sambath Seng / Create the method
    *****************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static TabWrapper getSearchResult(String searchKey, String settingName){
        List<Seller_Portal_Setting__mdt> lstSpsMdt = getSellerPortalSetting(settingName);
        String filters = '';
        String key = '';
        if ( String.isNotBlank(searchKey)) {
            key = '%' + searchKey + '%';
            if(String.isNotBlank(lstSpsMdt[0].Specific_Search_Field__c) )filters += ' (' + lstSpsMdt[0].Specific_Search_Field__c +') ';
        }
        String query = 'SELECT COUNT() FROM '+ lstSpsMdt[0].Object_API_Name__c +(String.isNotBlank(filters)? ' WHERE '+filters : '');
        TabWrapper tw = new TabWrapper();
        tw.objectApi = lstSpsMdt[0].Object_API_Name__c;
        tw.developerName = settingName;
        tw.recordCount = Database.countQuery(query);
        return tw;    
    }
    public class TabWrapper{
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String developerName{ get; set; } 
        @AuraEnabled public String objectApi{ get; set; } 
        @AuraEnabled public Integer recordCount{ get; set; } 
    }
    private static List<Seller_Portal_Setting__mdt> getSellerPortalSetting(String developerName){
        String query = 'SELECT DeveloperName, Object_API_Name__c, Specific_Search_Field__c, MasterLabel FROM Seller_Portal_Setting__mdt WHERE Global_Search_Tab__c = true '+(String.isNotBlank(developerName)?'AND DeveloperName =:developerName ':'')+'ORDER BY MasterLabel DESC';
        return Database.query(query);
    }
}