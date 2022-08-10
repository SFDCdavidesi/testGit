trigger CouponCoInvest on Coupon_Co_Invest__c (before insert, before delete, before update) {
    
                 //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) !=null &&
       EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).Coupon_Co_Invest__c) { 
 
		if(trigger.isBefore){
			if(trigger.isInsert){
				CouponCoInvestTriggerHandler.checkIsAllowAddCategoryExceptions(trigger.new,trigger.old);
				CouponCoInvestTriggerHandler.setDefaultSellerShare(trigger.new);
				CouponCoInvestTriggerHandler.synCurrencyValueFrom_Coupon(trigger.oldMap, trigger.new);
			}else if(trigger.isDelete){
				CouponCoInvestTriggerHandler.checkIsAllowAddCategoryExceptions(trigger.new,trigger.old);
				CouponCoInvestTriggerHandler.deleteUpdateCouponCoInvest(trigger.old);
				//SRONG TIN : 06.06.2021 : US-0011872 - Validation rule for Co-Invest deletion
				//CouponCoInvestTriggerHandler.deleteCouponCoInvest(trigger.old); //MN-22072022 - story is not needing.
			}else if(trigger.isUpdate){
				CouponCoInvestTriggerHandler.deleteUpdateCouponCoInvest(trigger.new);
				CouponCoInvestTriggerHandler.synCurrencyValueFrom_Coupon(trigger.oldMap, trigger.new);
				CouponCoInvestTriggerHandler.couponCoInvestAccessibility(trigger.oldMap, trigger.newMap);
			}
		}

	}
}