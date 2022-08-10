trigger QuoteMain on Quote (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    byPass__c profileCustomSetting = byPass__c.getInstance(UserInfo.getUserId());

    if( profileCustomSetting != null && 
        profileCustomSetting.triggerObjects__c != null && 
        profileCustomSetting.triggerObjects__c.contains('Quote') && 
        profileCustomSetting.byPass_Trigger__c) 
    {
        return;
    }
    TriggerFactory.createHandler(QuoteHandler.class);
}