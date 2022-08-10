/*********************************************************************************************************************************
@ Class:        BoBTriggerHandler
@ Version:      1.0
@ Author:       Vadhanak Vooun (vadhanak.voun@gaea-sys.com)
@ Purpose:      BoB__c Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 10.08.2018 / Vadhanak Vooun / Created the trigger.
*********************************************************************************************************************************/

trigger BoBTrigger on BOB__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    if(trigger.isAfter)
    {	
    	if(trigger.isUpdate)
    	{
    		//NK:11/02/2020:US-0007164: handle by batch from button, or nightly job
    		//BoBTriggerHandler.assignActiveBoBFieldsToSellerFromBoB(trigger.new,trigger.oldMap);
            //BoBTriggerHandler.UpdateSellerOwnerBasedonBobSellerAccountManager(trigger.new,trigger.oldMap);
            
			BoBTriggerHandler.bobActivationCheck(trigger.new,trigger.oldMap);
			// BoBTriggerHandler.bobDeactivationCheck(trigger.new,trigger.oldMap); // 10.01.2022 / Sophal Noch / US-0011008, // 14.02.2022 / Sophal Noch / US-0011283 move logic to bobActivationCheck method
    	}
    	
    }
	if(trigger.isBefore)
    {
    	if(trigger.isInsert || trigger.isUpdate)
    	{
    		BoBTriggerHandler.bobCreationDuplicateCheck(trigger.new,trigger.oldMap);
    		if(trigger.isUpdate){
    			BoBTriggerHandler.validationLLTMbobBeforeActivated(trigger.new,trigger.oldMap);
    		}
    	}
    }
}