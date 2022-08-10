//@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
trigger DayTrigger on Day__c (before insert,after update) {
    // @ Change history: 04.07.2022 /Chetra Sarlom/ destructive US-0007031 - Deactivate triggers
    /*
    if(trigger.isBefore && trigger.isInsert){
        DayTriggerHandler.updatedCompetency(trigger.new);
    }
    
    
    else if(trigger.isAfter && trigger.isUpdate){
        // @ Change history: 04.07.2022 /Chetra Sarlom/ destructive US-0007031 - Deactivate triggers
        //DayTriggerHandler.updateSprintCapacityUser(trigger.new,trigger.oldMap);
        // end US-0007031 with old US-0001460 US-0001236
    }*/
}