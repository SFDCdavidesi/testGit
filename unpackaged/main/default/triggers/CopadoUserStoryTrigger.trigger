trigger CopadoUserStoryTrigger on copado__User_Story__c (before insert,before update,after update,after insert) {
    
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) !=null &&
       EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).CopadoUserStory__c ){
           
           if (trigger.isInsert || trigger.isUpdate){
               //TH: US-0010666 : 25/05/2022
               if(trigger.isAfter){
                 CopadoUserStoryTriggerHandler.updateProjectStatus(Trigger.new, Trigger.oldMap);
               }
       //        CopadoUserStoryTriggerHandler.calculateTechnicalSpecifications(trigger.new, trigger.oldMap);
           }
            if(trigger.isUpdate && trigger.isBefore){
                CopadoUserStoryTriggerHandler.validatePriorityChanged(Trigger.new, Trigger.oldMap);
            }
           if(trigger.isUpdate &&trigger.isAfter){
                // 24.03.2021 / Loumang SENG / US-0009262 : Maximum Runtime = 2, It allows updating child-user-story status up to level 2.
                CopadoUserStoryTriggerHandler.checkDependency(Trigger.new, Trigger.oldMap);
            }
           if (trigger.isInsert && trigger.isBefore){
               CopadoUserStoryTriggerHandler.emptySelectedFieldsWhenCloning(Trigger.new);
           }
           if (trigger.isInsert){
               CopadoUserStoryTriggerhandler.decodeDescription(Trigger.new, null, false);
           }else{
               CopadoUserStoryTriggerhandler.decodeDescription(Trigger.new, Trigger.oldMap, true);
           }            
           
       }
    
    
    
}