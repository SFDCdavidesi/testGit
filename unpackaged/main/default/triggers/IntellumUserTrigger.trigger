trigger IntellumUserTrigger on intellumapp__IntellumUser__c (before insert, before update) {
   
    if( EBH_ActiveTriggers__c.getInstance(IntellumUserTriggerHandler.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(IntellumUserTriggerHandler.TRIGGERCONTROLLER).IntellumUserTrigger__c) {

            if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
                IntellumUserTriggerHandler.prePopulateFields(Trigger.new, Trigger.oldMap); // Sophal / 17.08.2021 / US-0010060
            }

    }


}