/*********************************************************************************************************************************
@ Class:         Subscription_Request_TriggerHandler
@ Version:       1.0
@ Author:       vadhanak voun (vadhanak.voun@gaea-sys.com)
@ Purpose:     handle for trigger: Subscription_Request_Trigger object (Subscription_Request__c)   
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 21.12.2021 / vadhanak.voun (vadhanak.voun@gaea-sys.com) / US-0010561 - [AM] Store Account Manager Subscription Requests in Hive
*********************************************************************************************************************************/
public with sharing class Subscription_Request_TriggerHandler {
    
    final static String STATUS_SUBSCRIBED = 'Subscribed';
    /*****************************************************************************************************************************
    @ Method:   populateFields
    @ Version:  1.0
    @ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:  US-0010561 - [AM] Store Account Manager Subscription Requests in Hive
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter: listNew, mapOld
    ------------------------------------------------------------------------------------------------------------------------------
    @ event: before update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21.12.2021 / vadhanak.voun (vadhanak.voun@gaea-sys.com) / US-0010561 - [AM] Store Account Manager Subscription Requests in Hive
    @                           / Earliest_Unsubscribe_Date__c is set to the last day of the third calendar month after the opt-in date
    *****************************************************************************************************************************/
    public static void populateFields(List<Subscription_Request__c> listNew,Map<Id,Subscription_Request__c> mapOld)
    {
        RecordType rt_AM = ApexUtil.getRecordTypeByName('Subscription_Request__c', 'Account_Manager');
        for(Subscription_Request__c sub: listNew)
        {
            Subscription_Request__c subOld = mapOld.get(sub.Id);
            if(sub.Opt_In_Date__c <> null && sub.Opt_In_Date__c <> subOld.Opt_In_Date__c <> null && sub.Earliest_Unsubscribe_Date__c == null && sub.RecordTypeId == rt_AM.Id)
            {
                sub.Earliest_Unsubscribe_Date__c = sub.Opt_In_Date__c.addMonths(4).toStartOfMonth().addDays(-1);    // is set to the last day of the third calendar month after the opt-in date
            }
            if(sub.Status__c == STATUS_SUBSCRIBED && sub.Status__c <> subOld.Status__c && sub.RecordTypeId == rt_AM.Id)
            {
                sub.Opt_In_Effective_Date__c = Date.today();
            }



        }
    }
}