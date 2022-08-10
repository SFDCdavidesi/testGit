/*********************************************************************************************************************************
@ Class:          ToDoListViewController
@ Version:        1.0
@ Author:         Broseth KATOR 
@ Purpose:        Summary 'to-do' Component (EBAY-285)
@ createdDate 25-Aug-2021
@ ToDoListViewController for LWC lwcTodoListView
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 25-Aug-2021/ Broseth KATOR / Created the class.
@               : 16.12.2021/ vadhanak voun/ US-0010919 - [SP EU - Deals] Adjustments required to hide Generic Features
@               : 13.01.2022/ Mony Nou/ US-0010726 - [SP - EU Deals] To-Do List Notifications for Deals
*********************************************************************************************************************************/

public with sharing class ToDoListViewController {    
    
    /* MN-18012022-US-0010726-No longer needing the existed logic
    @AuraEnabled(cacheable=true)   
    public static String initCountLiveDeals(String lastNday2) { 
        try {
            String accId = ToDoListViewController.getCurrentUserAccountId();
            String sql = 'SELECT COUNT() FROM EBH_Deal__c WHERE EBH_DealStartDate__c <= TODAY AND EBH_DealEndDate__c >= TODAY';
            if (String.isNotBlank(accId)) sql += ' AND EBH_BusinessName__c = \''+accId+'\'';
            // system.debug('full sql initCountLiveDeals: >>>>>>>> '+sql);
            Integer numberDeals = Database.countQuery(sql);           
            return String.valueOf(numberDeals);
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }

    @AuraEnabled(cacheable=true)   
    public static String initCountScheduledDeals(String lastNday2) { 
        try {
            String accId = ToDoListViewController.getCurrentUserAccountId();
            String sql = 'SELECT COUNT() FROM EBH_Deal__c WHERE EBH_Status__c = \'Planned\'';
            if (String.isNotBlank(lastNday2)) sql += ' AND CreatedDate = LAST_N_DAYS:'+lastNday2;
            if (String.isNotBlank(accId)) sql += ' AND EBH_BusinessName__c = \''+accId+'\'';
            // system.debug('full sql initCountScheduledDeals: >>>>>>>> '+sql);
            Integer numberDeals = Database.countQuery(sql);           
            return String.valueOf(numberDeals);
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }

    @AuraEnabled(cacheable=true)   
    public static String initCountCancelledDeals(String lastNday3) { 
        try {
            String accId = ToDoListViewController.getCurrentUserAccountId();
            String sql = 'SELECT COUNT() FROM EBH_Deal__c WHERE (EBH_Status__c = \'Cancelled\' OR EBH_Status__c = \'Rejected\')';
            if (String.isNotBlank(lastNday3)) sql += ' AND CreatedDate = LAST_N_DAYS:'+lastNday3;
            if (String.isNotBlank(accId)) sql += ' AND EBH_BusinessName__c = \''+accId+'\'';
            // system.debug('full sql initCountCancelledDeals: >>>>>>>> '+sql);
            Integer numberDeals = Database.countQuery(sql);           
            return String.valueOf(numberDeals);
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }


    private static String getCurrentUserAccountId() {
        List<Contact> lstCons = [SELECT AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id =:UserInfo.getUserID())];
        List<Account> lstDefaultAcc = [SELECT Id FROM Account WHERE Name = 'Trigg Digital Ltd' LIMIT 1];
        return (!lstCons.isEmpty()) ? lstCons[0].AccountId : lstDefaultAcc[0].Id; // fixed Id of account Trigg Digital Ltd use as default on sandbox         
    }
    */

    /***********************************************************************************************************************************
    @ Method:       hasPermission 
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Returns has or no
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 16.12.2021 / vadhanak voun / US-0010919 - [SP EU - Deals] Adjustments required to hide Generic Features
    ***********************************************************************************************************************************/
    @AuraEnabled(cacheable=true)   
    public static boolean hasPermission() { 
        return Schema.sObjectType.EBH_Deal__c.isAccessible();
    }


    /***********************************************************************************************************************************
    @ Method:       fetchToDoListMetadata 
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Description:  To get all 'ToDoList' records from Custom Metadata Seller_Portal_Global_Variables__mdt's that has Prefix that assigned in DeveloperName field
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Params:       String, prefix before underscore that we use in DeveloperName field of each records 
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Returns:      List<ToDoListViewController.ToDoListWrapper>
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 14.01.2022 / Mony Nou / US-0010726 - [SP - EU Deals] To-Do List Notifications for Deals
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 5.4.2022 / Sambath Seng / US-0011579 - Read Only Access to Deals 
    ***********************************************************************************************************************************/
    @AuraEnabled ( cacheable=true )   
    public static List<ToDoListViewController.ToDoListWrapper> fetchToDoListMetadata(String prefix) {
        
        String tmp = (String.isNotBlank(prefix)?prefix.trim():'') + '%';
        
        List<ToDoListViewController.ToDoListWrapper> lstResult = new List<ToDoListViewController.ToDoListWrapper>();
        ToDoListViewController.ToDoListWrapper tdl_None = new ToDoListViewController.ToDoListWrapper();

        for (Seller_Portal_Global_Variables__mdt spgv : [SELECT Id, Label, DeveloperName, Value__c, Value_in_German__c, Value_Big__c FROM Seller_Portal_Global_Variables__mdt WHERE DeveloperName like:tmp Order By Label]) {
            
            ToDoListViewController.ToDoListWrapper wrapper = new ToDoListViewController.ToDoListWrapper(spgv);
            
            if (String.isNotBlank(spgv.Value_Big__c)) {

                List<String> lstTmp = spgv.Value_Big__c.split('#');
                
                if (lstTmp.isEmpty()) continue;
                
                String tab_id = (lstTmp.size()>1)?lstTmp[0]:'#';
                String count_query = (lstTmp.size()>1)?lstTmp[1]:lstTmp[0];
                Integer rec_count = Database.countQuery(count_query);
                
                wrapper.ret_url = tab_id;

                if (rec_count > 0) {
                    wrapper.rec_count = rec_count;
                    wrapper.notif_text_en = (String.isNotBlank(spgv.Value__c))?spgv.Value__c.replace('{X}', String.valueOf(rec_count)):'';
                    wrapper.notif_text_de = (String.isNotBlank(spgv.Value_in_German__c))?spgv.Value_in_German__c.replace('{X}', String.valueOf(rec_count)):wrapper.notif_text_en;

                    lstResult.add(wrapper);
                }
            
            }else {
                wrapper.isNone = true;
                tdl_None = wrapper;
            }
            
        }

        if (lstResult.isEmpty()) lstResult.add(tdl_None);

        // System.debug('***** lstResult :: ' + lstResult);


        return lstResult;

    }

    public class ToDoListWrapper {

        @AuraEnabled
        public String todolist_id;

        @AuraEnabled
        public Integer rec_count;

        @AuraEnabled
        public String notif_text_de;

        @AuraEnabled
        public String notif_text_en;

        @AuraEnabled
        public String ret_url;

        @AuraEnabled
        public Boolean isNone;
            
        //SB 5-4-2022 US-0011579 - Read Only Access to Deals 
        @AuraEnabled
        public String settingName;

        public ToDoListWrapper(Seller_Portal_Global_Variables__mdt meta) {
            this.todolist_id = meta.Id;
            this.notif_text_en = meta.Value__c;
            this.notif_text_de = (String.isNotBlank(meta.Value_in_German__c))?meta.Value_in_German__c:this.notif_text_en;
            this.ret_url = '/';
            this.isNone = false;
            this.settingName = meta.DeveloperName;//SB 5-4-2022 US-0011579 - Read Only Access to Deals
        }

        public ToDoListWrapper () {}
    }
}