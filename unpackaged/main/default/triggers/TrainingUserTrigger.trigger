trigger TrainingUserTrigger on Training_User__c (before insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        TrainingUserTriggerHandler.checkDuplicatedUserCreated(Trigger.New);
    }
}