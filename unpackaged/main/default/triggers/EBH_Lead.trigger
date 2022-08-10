trigger EBH_Lead on Lead (before update, after update) {
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            LeadTriggerHandler.changeConvertedContactRecordType(Trigger.new);
            LeadTriggerHandler.validateAUSMBLead(Trigger.new);
        }
    }else if(Trigger.isAfter){
        if(Trigger.isUpdate){
            LeadTriggerHandler.leadOnboardingProcess(Trigger.oldMap, Trigger.newMap);
            LeadTriggerHandler.leadConversionNA_Validation(Trigger.newMap);
        }
    }
}