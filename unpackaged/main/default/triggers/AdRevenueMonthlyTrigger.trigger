trigger AdRevenueMonthlyTrigger on Ad_Revenue_Monthly__c (before insert, before update, after delete, after insert, after update) {

    // Sophal / 08.04.2021 / US-0009328
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        AdRevenueMonthlyTriggerHandler.prePopulateFields(Trigger.new, Trigger.oldMap);
    }


    // 08.02.2021 / Sophal Noch / US-0008908
    if(Trigger.isAfter && (Trigger.isDelete || Trigger.isInsert || Trigger.isUpdate)){
        AdRevenueMonthlyTriggerHandler.updateDeliverySummeMonthly(Trigger.new, Trigger.oldMap);
    }


    
}