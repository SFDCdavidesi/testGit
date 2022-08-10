trigger Action_TemplateTrigger on Action_Template__c (after update) {
    if (EBH_ActiveTriggers__c.getInstance('EBH Trigger Controller').Action_Template__c) 
    {
        if(Trigger.isAfter )
        {
            if(Trigger.isUpdate)
            {
                Action_TemplateHandler.updateDescriptionToActions(trigger.new, trigger.oldMap);
            }
            
        }
    }
}