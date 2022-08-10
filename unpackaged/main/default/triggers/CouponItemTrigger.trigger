trigger CouponItemTrigger on Coupon_Item__c (after insert,before insert, before delete, before update) {
                 //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) !=null &&
       EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).Coupon_Item__c) {
       	
       	if (trigger.isBefore) {
       		if(trigger.isInsert) {
       			CouponItemTriggerHandler.validateCouponItem(trigger.new,trigger.oldMap);
       		}else if (trigger.isUpdate) {
	        	CouponItemTriggerHandler.validateCouponItem(trigger.new,trigger.oldMap);
	        	CouponItemTriggerHandler.deleteUpdateCouponItem(trigger.new);
	        }
	        else if (trigger.isDelete){
				CouponItemTriggerHandler.preventRecordDeletion(trigger.oldMap); //MN-06082021-US-0009746
	        	CouponItemTriggerHandler.deleteUpdateCouponItem(trigger.old);
	        }
	    }
	    else if(trigger.isAfter && trigger.isInsert){
    		CouponItemTriggerHandler.createCoInvestOnceCouponItemCreated(trigger.new);
    	}

}
}