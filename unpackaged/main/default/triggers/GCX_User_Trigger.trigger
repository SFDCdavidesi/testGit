trigger GCX_User_Trigger on GCX_User__c (after update) {
	
	if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).GCX_User__c) {
	 	
	 	if(trigger.isAfter)
		{
			if(trigger.isUpdate)
			{ 
				GCX_USer_Handler.removeInactiveRecord(trigger.new,trigger.oldMap);
			}
		}
	
	}
	
}