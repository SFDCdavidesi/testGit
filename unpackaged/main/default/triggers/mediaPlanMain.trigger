trigger mediaPlanMain on Media_Plan__c (before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {

    /* MN-27102021-Deprecated via US-0008401
    byPass__c profileCustomSetting = byPass__c.getInstance(UserInfo.getUserId());

    if( profileCustomSetting!=null && ( profileCustomSetting.triggerObjects__c!=null &&  profileCustomSetting.triggerObjects__c.contains('Media_Plan__c')
            && profileCustomSetting.byPass_Trigger__c)){
    return;
    }

    TriggerFactory.createHandler(MediaPlanMainTriggerHandler.class);
    */
}