trigger CouponCategoryTrigger on Coupon_Category__c (before insert, before update, before delete, after insert) {
    
                 //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) !=null &&
       EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).Coupon_Category__c) { 
 
    if(trigger.isAfter && trigger.isInsert){
    	CouponCategoryTriggerHandler.createCoInvestOnceCouponCategoryCreated(trigger.new);
    }

    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate) ) {     
        CouponCategoryTriggerHandler.blockDuplicatedCategory(trigger.oldMap, trigger.new);
        CouponCategoryTriggerHandler.populateCouponMainSite(trigger.new);//SB 05.07.2022 US-0011958 - Change Requests Focus 75
      }
      
    //MN-06082021-US-0009746
    if (trigger.isBefore && trigger.isDelete) {
      CouponCategoryTriggerHandler.preventRecordDeletion(trigger.oldMap);
    }

    //SB 24.6.2022 US-0011958 - Change Requests Focus 75
    if(trigger.isBefore && trigger.isInsert){
      CouponCategoryTriggerHandler.visibleCouponCategoryInSellerPortal(trigger.new);
    }
}
}