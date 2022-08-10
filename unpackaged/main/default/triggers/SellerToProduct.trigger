trigger SellerToProduct on Seller_to_Product__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    //trigger control - proceed if trigger switched ON
    // if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) !=null &&
    //    EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).Seller_to_Product__c) { 
           /* MN-19/05/2021 - US-0009522 - Retired Codes
           if(trigger.isAfter)
           {
           	//NK:02/10/2019: US-0015716: moved to batch
            //    if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete)
            //    {
            //        SellerToProductTriggerHandler.calculateProductFields(trigger.new,trigger.oldMap,trigger.isDelete);
            //    }
            //    if(trigger.isDelete)
            //    {
            //        SellerToProductTriggerHandler.calculateProductFields(trigger.old,trigger.oldMap,trigger.isDelete);
            //    }
           }
           */ 
    //    }
}