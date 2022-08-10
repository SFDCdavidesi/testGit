trigger FeatureRequestTrigger on Requirement_Request__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
     //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).Feature_Request_Trigger__c) {

            if(trigger.isBefore){
                if(trigger.isInsert){
                   
                    
                }else if(trigger.isUpdate)
                {
                    
                }else if(trigger.isDelete) 
                { 
                    
                } 
            }
            else if(trigger.isAfter)
            {
                
                if(trigger.isInsert)
                {
                   FeatureRequestTriggerHandler.calculateComplexityEstimation(trigger.new,trigger.oldMap);

                }else if(trigger.isUpdate)
                {
                   FeatureRequestTriggerHandler.calculateComplexityEstimation(trigger.new,trigger.oldMap);

                }else if(trigger.isDelete)
                {
                   FeatureRequestTriggerHandler.calculateComplexityEstimation(trigger.old,null);
                }
                
            }


        }

}