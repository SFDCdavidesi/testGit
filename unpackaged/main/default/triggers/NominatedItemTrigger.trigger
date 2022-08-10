trigger NominatedItemTrigger on Nominated_Item__c (before insert,before update) {
    
    
              //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) !=null &&
       EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).Nominated_Item__c) { 
          
		if(trigger.isBefore ){
			if(trigger.isInsert){
				NominatedItemTriggerHandler.updatedNorminatedItem(trigger.new);
				NominatedItemTriggerHandler.populatedListinIDAndPriceTargetField(trigger.new,null);
				NominatedItemTriggerHandler.populateDiscountFVF(trigger.new);
			}else if(trigger.isUpdate){
				NominatedItemTriggerHandler.populatedListinIDAndPriceTargetField(trigger.new,trigger.oldMap);
				//NominatedItemTriggerHandler.updateNominatedByOwnerAndRequestor(trigger.new);				
			}
		}
	}
}