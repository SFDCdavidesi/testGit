trigger CouponSellerTrigger on Coupon_Seller__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
             //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) !=null &&
       EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).Coupon_Seller__c) { 
 
    if(trigger.isBefore){
    	if(trigger.isInsert){
    		CouponSellerTriggerHandler.blockManualSetStage(trigger.new,trigger.oldMap);
    		CouponSellerTriggerHandler.blockDuplicatedSeller(trigger.new,trigger.oldMap);
    		CouponSellerTriggerHandler.setEmailAddress(trigger.new);
			CouponSellerTriggerHandler.prepopulateOwnerFromSeller(trigger.new);
			CouponSellerTriggerHandler.setEmailManhattan(trigger.new);
			CouponSellerTriggerHandler.setCouponPromotionPreferences(trigger.new);
            CouponSellerTriggerHandler.synCurrencyValueFrom_Coupon(trigger.oldMap, trigger.new);
			CouponSellerTriggerHandler.couponSellerStageApproved_OnlySpecialPermiss(trigger.oldMap, trigger.new);
			CouponSellerTriggerHandler.assignSiteUrl(trigger.new);
			CouponSellerTriggerHandler.couponSellerStatusMappingWithSEP(trigger.new,trigger.oldMap); //SB US-0010431 13-5-2022
			//Comment by Sambath Seng - 29.07.2022 US-0011998 BA want to Exclude from Production
			// CouponSellerTriggerHandler.updateCSStageWhenCouponIsNegoOrRunning(trigger.new); //SB 01-06-2022 US-0011998 - Business Feedback Focus 75 AC3
    	}else if(trigger.isUpdate){
    		CouponSellerTriggerHandler.blockManualSetStage(trigger.new,trigger.oldMap);
    		CouponSellerTriggerHandler.blockDuplicatedSeller(trigger.new,trigger.oldMap);
            CouponSellerTriggerHandler.synCurrencyValueFrom_Coupon(trigger.oldMap, trigger.new);
            CouponSellerTriggerHandler.couponSellerContractReminderAU(trigger.new,trigger.oldMap);
            //NK:02/10/2019: US-0018725
            CouponSellerTriggerHandler.sendT4_T34Email(trigger.new,trigger.oldMap); 
			CouponSellerTriggerHandler.couponSellerStageApproved_OnlySpecialPermiss(trigger.oldMap, trigger.new);
			CouponSellerTriggerHandler.validateCoInv_SellerShareAndCompanyDetail(trigger.oldMap, trigger.newMap);
			CouponSellerTriggerHandler.assignSiteUrl(trigger.new);
			CouponSellerTriggerHandler.couponSellerStatusMappingWithSEP(trigger.new,trigger.oldMap); //SB US-0010431 13-5-2022
    	}else if(trigger.isDelete) { //MN-06082021-US-0009746
			CouponSellerTriggerHandler.preventRecordDeletion(trigger.oldMap); //MN-06082021-US-0009746
			CouponSellerTriggerHandler.resetCouponFields(trigger.oldMap);
		} 
    }
    //NK:04/04/2019
    else if(trigger.isAfter)
    {
    	
    	if(trigger.isInsert)
    	{
    		
    		//CouponSellerTriggerHandler.createCoInvest(trigger.new,trigger.oldMap);
    		CouponSellerTriggerHandler.createCoInvestOnceCouponSellerCreated(trigger.new);
    		//CouponSellerTriggerHandler.couponSellerContractReminderAU(trigger.new);
    		//CouponSellerTriggerHandler.createCoInvest2(trigger.new,trigger.oldMap);
    		CouponSellerTriggerHandler.sendContract(trigger.new,trigger.oldMap);
    		CouponSellerTriggerHandler.addFileAttachment(trigger.new,trigger.oldMap);
			CouponSellerTriggerHandler.calculateCouponSeller(trigger.new,trigger.oldMap);
    	}else if(trigger.isUpdate)
    	{
    		//CouponSellerTriggerHandler.createCoInvest(trigger.new,trigger.oldMap);
    		CouponSellerTriggerHandler.createCoInvest2(trigger.new,trigger.oldMap);
    		
    		CouponSellerTriggerHandler.sendContract(trigger.new,trigger.oldMap);
			//commented on 2020-09-03 by DHE because of ->http://hive.lightning.force.com/apex/GoToUserStory?US-0008187
			//uncommented by Ratha Sim on 2020-09-09 because of US-0008170
			CouponSellerTriggerHandler.sendCouponLaunchReminderTemplates(trigger.oldMap,trigger.new);
			CouponSellerTriggerHandler.sendCpnAcceptOfCpnContr(trigger.oldMap, trigger.new);
			CouponSellerTriggerHandler.addFileAttachment(trigger.new,trigger.oldMap);
			CouponSellerTriggerHandler.calculateCouponSeller(trigger.new,trigger.oldMap);
    	}
    	
    }
}
}