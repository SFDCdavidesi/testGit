trigger CouponTrigger on Coupon__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
                 //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) !=null &&
       EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).Coupon__c) { 
 
    if(trigger.isBefore ){
    	if(trigger.isInsert)
    	{
    		CouponTriggerHandler.blockManualSetStage(trigger.new,trigger.oldMap);
    		CouponTriggerHandler.setDefaultStage(trigger.new);
    		
    		CouponTriggerHandler.populateDateTimeAuto(trigger.new,trigger.oldMap);
    		//CouponTriggerHandler.setEmailManhattanForCoupon(trigger.new,trigger.oldMap); //NK:15/11/2019: disabled moved all to scheduler 
    	}
    	if(trigger.isUpdate)
    	{
    		CouponTriggerHandler.blockManualSetStage(trigger.new,trigger.oldMap);
    		CouponTriggerHandler.populateDateTimeAuto(trigger.new,trigger.oldMap);
    		//CouponTriggerHandler.setEmailManhattan(trigger.new,trigger.oldMap); //NK: 07/10/2019: disabled
    		//CouponTriggerHandler.setEmailManhattanForCoupon(trigger.new,trigger.oldMap); //NK:15/11/2019: disabled moved all to scheduler 
			CouponTriggerHandler.setCouponCoinvestStaticOwner(trigger.new,trigger.oldMap);
    	}
    }else if(trigger.isAfter){
    	if(trigger.isUpdate){
    		CouponTriggerHandler.createCoInvestWithRecordType(trigger.new,trigger.oldMap);
    		// CouponTriggerHandler.sendBCDFileEmail(trigger.new,trigger.oldMap);
    		CouponTriggerHandler.synCurrencyValueTo_CpnSelrAndCpnCoInv(trigger.oldMap, trigger.newMap);
			CouponTriggerHandler.couponNegotitaionEndDateReachSendEmail(trigger.oldMap, trigger.newMap);
			CouponTriggerHandler.checkNegotiationEndDateIsChange(trigger.oldMap, trigger.newMap);
			CouponTriggerHandler.changeStage(trigger.new, trigger.oldMap); //Sophal:11/03/2022:US-0011385
			CouponTriggerHandler.syncCouponInfo2CouponSellers(trigger.newMap, trigger.oldMap); //MN-27062022-US-0010785
    	}
    }
    
}
}