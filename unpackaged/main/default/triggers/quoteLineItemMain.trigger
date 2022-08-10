trigger quoteLineItemMain on QuoteLineItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    byPass__c profileCustomSetting = byPass__c.getInstance(UserInfo.getUserId());

    if( profileCustomSetting!=null && ( profileCustomSetting.triggerObjects__c!=null && profileCustomSetting.triggerObjects__c.contains('QuoteLineItem')
            && profileCustomSetting.byPass_Trigger__c)){
    return;
    }

    TriggerFactory.createHandler(QuoteLineItemMainTriggerHandler.class);
}