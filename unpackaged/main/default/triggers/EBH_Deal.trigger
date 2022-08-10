trigger EBH_Deal on EBH_Deal__c (after delete, after insert, after undelete, after update,before update,before insert) {
    //System.debug('########## Inside trigger');
    //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).DealTrigger__c) {
 
        if(trigger.isBefore){
        	if(trigger.isInsert){
            	EBH_DealTriggerHandler.checkDuplicate(trigger.new,trigger.oldMap);
            	EBH_DealTriggerHandler.newDealNotBackDate(trigger.new,trigger.oldMap);
 
                EBH_DealTriggerHandler.handleDealSlotAllocation(trigger.isUpdate,trigger.old,trigger.new);
                EBH_DealTriggerHandler.setNonPayOutItemEstimate(trigger.oldMap,trigger.new);
                EBH_DealTriggerHandler.blockDealStatus(trigger.oldMap,trigger.new);
                
                //NK:17/05/2019
                //TH: 05/01/2020 : trigger.new because using for all record type
                EBH_DealTriggerHandler.assignSiteUrl(trigger.new);

                EBH_DealTriggerHandler.OverwriteClone(trigger.new);

                // // 28.05.2021 / Sophal Noch / US-0009533
                // EBH_DealTriggerHandler.populateStartDateTime(trigger.new,null);

                // 15.11.2021 / Acmatac SEING / US-0010485
                EBH_DealTriggerHandler.dealStatusMappingWithSEP(trigger.new,trigger.oldMap);
                EBH_DealTriggerHandler.dealNAUnsubStatusMappingWithSEP(trigger.new,trigger.oldMap);
                
        	}else if(trigger.isUpdate){
            	if(UserInfo.getUserType() != 'Guest'){
            		EBH_DealTriggerHandler.checkDuplicate(trigger.new,trigger.oldMap);
            	}
            	EBH_DealTriggerHandler.newDealNotBackDate(trigger.new,trigger.oldMap);
            	if(UserInfo.getUserType() != 'Guest'){
                	EBH_DealTriggerHandler.lockCompletedDeals(trigger.newMap, trigger.oldMap);  
                	EBH_DealTriggerHandler.changeAllowed(trigger.new,trigger.oldMap);
            	}

                EBH_DealTriggerHandler.checkDealNotification(trigger.new,trigger.oldMap);

                EBH_DealTriggerHandler.handleDealSlotAllocation(trigger.isUpdate,trigger.old,trigger.new);
                EBH_DealTriggerHandler.setNonPayOutItemEstimate(trigger.oldMap,trigger.new);
                EBH_DealTriggerHandler.blockDealStatus(trigger.oldMap,trigger.new);

                //NK:17/05/2019
                //TH: 05/01/2020 : trigger.new because using for all record type
                EBH_DealTriggerHandler.assignSiteUrl(trigger.new);

                // 28.05.2021 / Sophal Noch / US-0009533
                // EBH_DealTriggerHandler.populateStartDateTime(trigger.new,trigger.oldMap);

                // 15.11.2021 / Acmatac SEING / US-0010485
                EBH_DealTriggerHandler.dealStatusMappingWithSEP(trigger.new,trigger.oldMap);
                EBH_DealTriggerHandler.dealNAUnsubStatusMappingWithSEP(trigger.new,trigger.oldMap);
        	}
        }else if(trigger.isAfter){
        	if(trigger.isInsert){
        		EBH_DealTriggerHandler.checkDealIdChanged(trigger.new,trigger.oldMap);

                //NK:02/04/2018:EPH-5465
                EBH_DealTriggerHandler.handleAvailableSlot(trigger.isUpdate,trigger.oldMap,(trigger.isDelete?trigger.oldMap:trigger.newMap));

                // 15.11.2021 / Acmatac SEING / US-0010485
                EBH_DealTriggerHandler.setDealPrice(trigger.new);  
        	}else if(trigger.isUpdate){
        		// EBH_DealTriggerHandler.notifyMerchantApproverDealsReady4approval(mapOldNA, mapNewNA); //Sophal:06/04/2021:US-0009353
        		EBH_DealTriggerHandler.rollUpDisputeAmountForDealStatement(trigger.oldMap,trigger.new);

                //NK:11/06/2018: [#EPH-5741]
                EBH_DealTriggerHandler.lockDeals(trigger.isUpdate,trigger.oldMap,trigger.new);
                EBH_DealTriggerHandler.checkDealIdChanged(trigger.new,trigger.oldMap);  

                //NK:02/04/2018:EPH-5465
                EBH_DealTriggerHandler.handleAvailableSlot(trigger.isUpdate,trigger.oldMap,(trigger.isDelete?trigger.oldMap:trigger.newMap));

                EBH_DealTriggerHandler.afterUpdate(trigger.new,trigger.oldMap); // Sophal:01/09/2021:US-0010285

                //12.10.2021 - SRONG TIN : US-0010453 - [UK-Deals] Deal Invoice - eBay billing address and VAT changes
                EBH_DealTriggerHandler.updateDealInvoiceIsDealSiteUK(trigger.new,trigger.oldMap);  

        	}else if(trigger.isDelete){
                //NK:02/04/2018:EPH-5465
                EBH_DealTriggerHandler.handleAvailableSlot(trigger.isUpdate,trigger.oldMap,(trigger.isDelete?trigger.oldMap:trigger.newMap));
            }else if(trigger.isUndelete){
                //NK:02/04/2018:EPH-5465
                EBH_DealTriggerHandler.handleAvailableSlot(trigger.isUpdate,trigger.oldMap,(trigger.isDelete?trigger.oldMap:trigger.newMap));
            }
        }
    }
}