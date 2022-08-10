trigger DealStatementTrigger on Deal_Statement__c (before update, after update) {
    if(Trigger.isUpdate && Trigger.isBefore){
        // 05.05.2021 / Sophal Noch / US-0009424
        DealStatementTriggerHandler.detectStatusChangedAndGenerateXsl(Trigger.new, Trigger.oldMap);
        DealStatementTriggerHandler.updateDealStatementApprovalCheckbox(Trigger.new, Trigger.oldMap);
    }else if(Trigger.isUpdate && Trigger.isAfter){
        DealStatementTriggerHandler.updateXslFromVF(Trigger.new, Trigger.oldMap);
    }
}