trigger opportunityMain on opportunity (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {

        byPass__c profileCustomSetting = byPass__c.getInstance(UserInfo.getUserId());

        if( profileCustomSetting!=null && ( profileCustomSetting.triggerObjects__c!=null && profileCustomSetting.triggerObjects__c.contains('Opportunity') && profileCustomSetting.byPass_Trigger__c)){return;}


        // TriggerFactory.createHandler(OpportunityMainTriggerHandler.class); // 25.01.2021 / Sophal Noch // US-0009019

        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            // US-0008007 :
            OpportunityTriggerHandler.manageAdsProduct(Trigger.new, Trigger.oldMap);
        }

       
        
}