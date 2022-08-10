trigger AdProductTrigger on Ad_Product__c (after insert,after update, before insert, before update, before delete) {

    //  Sophal Noch 15.01.2020  : US-0008981 - Add byPass on AdproductTrigger
    byPass__c profileCustomSetting = byPass__c.getInstance(UserInfo.getUserId());
    if( profileCustomSetting != null && 
        profileCustomSetting.triggerObjects__c != null && 
        profileCustomSetting.triggerObjects__c.contains('Ad_Product__c') && 
        profileCustomSetting.byPass_Trigger__c) 
    {
        return;
    }


    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        // Sophal Noch 21.08.2020  : US-0008007 
        AdProductTriggerHandler.populateFields(Trigger.new, Trigger.oldMap);

        if (Trigger.isUpdate) {

            // Mony Nou / 24.03.2021 / US-0009260 - [Ads 2020] OLI Trigger to QLI/AP, Fields & Syncing
            AdProductTriggerHandler.calcAmountByDelivery(Trigger.new);
        }

    }else if(Trigger.isBefore && Trigger.isDelete){
        // 18.12.2020 / Sophal Noch / US-0008866
        AdProductTriggerHandler.preventDeleteAdProduct(Trigger.old);
    }else if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        // US-0007980 :
        AdProductTriggerHandler.populateAdRevenueMonthlyAndDaily(Trigger.new, Trigger.oldMap);
        // 31.12.2020 / Sophal Noch / US-0008300 updateDeliverySumme should run after populateAdRevenueMonthlyAndDaily
        // 08.02.2021 / Sophal Noch / US-0008908 - [Ads 2020] Monthly Ads Revenue - Delivery Summer Trigger for Accruals
        if(Trigger.isUpdate){
            AdProductTriggerHandler.updateDeliverySumme(Trigger.new, Trigger.oldMap);
            AdProductTriggerHandler.updateInvoiceAmount(Trigger.new, Trigger.oldMap); // Sophal / 08.04.2021 / US-0009328
        }
        
    }

}