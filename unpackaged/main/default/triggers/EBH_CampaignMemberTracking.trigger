trigger EBH_CampaignMemberTracking on et4ae5__IndividualEmailResult__c (before insert, before update) {

    
       if( Trigger.isBefore){
           
           EBH_IndividualResultTriggerHandler.trackCampaignMembers(trigger.new, trigger.oldMap);
           
           //NK:12/02/2019: EPH-7043
           EBH_IndividualResultTriggerHandler.populateTargetDate(trigger.new, trigger.oldMap);
           
           //EPH-5945
           EBH_IndividualResultTriggerHandler.updateEmailPhoneContacts(trigger.new, trigger.oldMap);
       }
}