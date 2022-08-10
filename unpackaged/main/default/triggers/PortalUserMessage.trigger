trigger PortalUserMessage on Portal_User_Message__c (before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            PortalUserMessageTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        if(trigger.isUpdate){
            PortalUserMessageTriggerHandler.handleBeforeUpdate(Trigger.oldMap, Trigger.newMap);
        }

    }

}