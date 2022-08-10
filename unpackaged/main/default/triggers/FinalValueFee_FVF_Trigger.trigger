trigger FinalValueFee_FVF_Trigger on Final_Value_Fee_FVF__c (after insert,after update, before insert, before update) {
    
            //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) !=null &&
       EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).Final_value_Fee__c) { 

    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate)
        {
            FinalValueFee_FVF_Handler.checkNominateItemPriceisNotNull(trigger.new,trigger.oldMap);
            FinalValueFee_FVF_Handler.validateStagePermission(trigger.oldMap, trigger.new);
        } 
        
        //NK:23/12/2019: US-0006841: moved from after updated for assignment send date
        if(trigger.isUpdate)
        {
        	FinalValueFee_FVF_Handler.sendClickContract(trigger.new,trigger.oldMap);
            //FinalValueFee_FVF_Handler.validateStagePermission(trigger.oldMap, trigger.new);
            FinalValueFee_FVF_Handler.validateEmptyNominatedItem(trigger.oldMap, trigger.newMap);
        }

        if(trigger.isInsert){
        	FinalValueFee_FVF_Handler.populateContactPerson(trigger.new);
        }
    } 

    if(trigger.isAfter)
    {
    	if(trigger.isInsert)
    	{
            FinalValueFee_FVF_Handler.sumTotalListingNumberAndSeller(trigger.new,trigger.oldMap);
            FinalValueFee_FVF_Handler.createNorminatedItem(trigger.new);
            //FinalValueFee_FVF_Handler.updateFVFCampaignStatus(trigger.new,trigger.oldMap);
			//FinalValueFee_FVF_Handler.prepopulateContactPerson(trigger.new);
            FinalValueFee_FVF_Handler.assignPermset_NominatedItemEdit(trigger.new,trigger.oldMap);
    	}
    	if(trigger.isUpdate)
    	{
    		FinalValueFee_FVF_Handler.reminderClickContract(trigger.new,trigger.oldMap);//NK:23/12/2019:
    		FinalValueFee_FVF_Handler.sumTotalListingNumberAndSeller(trigger.new,trigger.oldMap);
    		FinalValueFee_FVF_Handler.sendEmailApproval(trigger.new,trigger.oldMap);
            FinalValueFee_FVF_Handler.assignPermset_NominatedItemEdit(trigger.new,trigger.oldMap);
            //FinalValueFee_FVF_Handler.updateFVFCampaignStatus(trigger.new,trigger.oldMap);
            
    	}
    	
    }
    
}
}