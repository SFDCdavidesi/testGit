trigger AdRevenueDailyTrigger on Ad_Revenue_Daily__c (after delete, after insert, after update) {

     // 31.12.2020 / Sophal Noch / US-0008300 
    if(Trigger.isAfter && (Trigger.isDelete || Trigger.isInsert || Trigger.isUpdate)){
        AdRevenueDailyTriggerHandler.updateDeliverySummeDaily(Trigger.new, Trigger.oldMap); //US-0008300 migrate from ads eu instance
    }
}