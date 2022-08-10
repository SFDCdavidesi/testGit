/*********************************************************************************************************************************
@ Class:        BoBSellerTriggerHandler
@ Version:      1.0
@ Author:       Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:      BoB_Seller__c Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 14.08.2018 / Vadhanak Voun / Created the trigger.
@ Change history: 15.07.2022/ Sophal Noch / US-0011996 - Call booking for Ads
*********************************************************************************************************************************/

trigger BoBSellerTrigger on BoB_Seller__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    if(trigger.isAfter)
    {
    	//NK:11/02/2020:US-0007164: handle by batch from button, or nightly job
    	//if(trigger.isInsert || trigger.isUpdate)
    	//{
    	//	BoBSellerTriggerHandler.assignActiveBoBFieldsToSeller(trigger.new,trigger.oldMap);
    	//}

		if(trigger.isInsert || trigger.isUpdate)
    	{
    		BoBSellerTriggerHandler.populateSchduleSlotsWithBS(trigger.new,trigger.oldMap); //15.07.2022/ Sophal Noch / US-0011996
    	}
		if(trigger.isDelete)
    	{
			BoBSellerTriggerHandler.populateSchduleSlotsWithBS(trigger.old, null); //15.07.2022/ Sophal Noch / US-0011996
		}

    }
    if(trigger.isBefore)
    {	 
    	if(trigger.isDelete)
    	{
    		BoBSellerTriggerHandler.checkBoBSellerDelete(trigger.old);
			//MN-23092021-US-0010407
			BoBSellerTriggerHandler.removeRelatedRecordWithCohortSeller(trigger.old);
    	}
		
		if(trigger.isInsert || trigger.isUpdate)
    	{
    		BoBSellerTriggerHandler.validateBoBSeller(trigger.new,trigger.oldMap);
    		BoBSellerTriggerHandler.populateBobSeller(trigger.new,trigger.oldMap);
    	}
    	
    }
}