trigger EBH_Project on EBH_Project__c (before insert, before update, before delete,after insert, after update) {
    //trigger control - proceed if trigger switched ON
    //23.12.2021 - SRONG TIN : US-0010604
    if(!EBH_ActiveTriggers__c.getInstance(ApexUtil.TRIGGERCONTROLLER).Project_Trigger__c || EBH_ProjectTriggerHandler.isHistoryCreate)return;

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            EBH_ProjectTriggerHandler.validatedAuSMBProject(trigger.new);
            EBH_ProjectTriggerHandler.validateManagedPaymentProj(trigger.new);
            
        }else if(Trigger.isUpdate){
            EBH_ProjectTriggerHandler.validateManagedPaymentProj(trigger.new);
            EBH_ProjectTriggerHandler.validatedRequiredField(trigger.new,trigger.oldMap);
            
        }else if(Trigger.isDelete){
            EBH_ProjectTriggerHandler.validateManagedPaymentProj(trigger.old);

            // Acmatac SEING, 28.June.2011, US-0009646 AC3
            EBH_ProjectTriggerHandler.validateSRMProj(trigger.old);
        }
    }else if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            //22.12.2021 - SRONG TIN : US-0010604 - Project Stage duration
             EBH_ProjectTriggerHandler.createAndUpdateProjectStageHistory(trigger.new,trigger.oldMap);
       
    }

}