// @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
trigger SprintTrigger on SPRINT__c (after insert, after update) {
    /*
    if(trigger.isInsert){
        SprintTriggerHandler.createdSprintCapacityUser(trigger.new);
    }else if(trigger.isUpdate){
        SprintTriggerHandler.updatedOrDeletedSprintCapacityUser(trigger.new,trigger.oldMap);
    }
    */
    // end US-0007031 old US-0001238 US-0001227
}