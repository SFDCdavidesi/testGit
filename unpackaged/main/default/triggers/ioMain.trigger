trigger ioMain on io__c (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {

    /* MN-26102021-US-0010693
    byPass__c profileCustomSetting = byPass__c.getInstance(UserInfo.getUserId());

    if( profileCustomSetting!=null && ( profileCustomSetting.triggerObjects__c!=null &&  profileCustomSetting.triggerObjects__c.contains('io__c')
            && profileCustomSetting.byPass_Trigger__c)){
    return;
    }
    */
    
    // TriggerFactory.createHandler(ioMainTriggerHandler.class); MN-26102021-US-0010693 ioMainTriggerHandler will be deprecated as a part of this story
    
}