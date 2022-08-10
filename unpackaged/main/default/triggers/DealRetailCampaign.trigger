/*********************************************************************************************************************************
@ Class:          DealRetailCampaignTriggerHandler
@ Version:        1.0
@ Author:         SRONG TIN (srong.tin@gaea-sys.com)
@ Purpose:        DealRetailCampaign Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 01.July.2021 / SRONG TIN / Created the trigger.
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 25-4-2022 / Sambath Seng / US-0011625 - Bugs/issues and user feedback
*********************************************************************************************************************************/

trigger DealRetailCampaign on EBH_DealRetailCampaign__c (after delete, after insert, after undelete, after update,before update,before insert, before delete) {
    //trigger control - proceed if trigger switched ON
    //LA-17-12-2021:US-0010824 - [SP - EU Deals] Adjust Sharing for Deal Retail Campaign Object
    /* ManagedSharingRecordsHandler.isInsert = Trigger.isInsert;
    ManagedSharingRecordsHandler.isUpdate = Trigger.isUpdate;
    ManagedSharingRecordsHandler.isDelete = Trigger.isDelete;
    ManagedSharingRecordsHandler.isUndelete = Trigger.isUndelete;*/
    //SYstem.debug('EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).DealRetailCampaign_Trigger__c: '+EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).DealRetailCampaign_Trigger__c);
    /*END US-0010824*/
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).DealRetailCampaign_Trigger__c) {
      
        /*AFTER Block - BEGIN*/
        if(Trigger.isAfter){
            //Rishi K-ebay-345
            if(Trigger.isInsert && !DealRetailCampaignTriggerHandler.isFDRCHandler){
                DealRetailCampaignTriggerHandler.insertDealRetailCampaign(Trigger.newMap);
            }
            //LA-17-12-2021:US-0010824 - [SP - EU Deals] Adjust Sharing for Deal Retail Campaign Object
            //SCH Add Apex Managed Sharing to Deal Retail Campaign trigger(eBay-710)
            /*if(Trigger.isInsert || Trigger.isUpdate){
                ManagedSharingRecordsHandler.shareDealRetailCampaignsBasedOnSite(Trigger.newMap,Trigger.oldMap);
            }*/
            /*END US-0010824*/
            /*UPDATE Block - BEGIN*/
            if(Trigger.isUpdate){
                //US-0009685 - [SEP] US - NA Unsub Deal - Time Based Status Changes
                DealRetailCampaignTriggerHandler.updateDealStatusByTimeBaseChange(Trigger.newMap,Trigger.oldMap);

                //MN-20072021-US-0009853
                DealRetailCampaignTriggerHandler.sendEmailToDealSellerContact(Trigger.newMap, Trigger.oldMap);
                
                //Rishi K-ebay-345
                if(!DealRetailCampaignTriggerHandler.isFDRCHandler) DealRetailCampaignTriggerHandler.updateDealRetailCampaign(Trigger.newMap, Trigger.oldMap);
            }
            /*UPDATE Block - END*/

            
        }
        else{
            if(Trigger.isDelete){
                //Rishi K-ebay-345#
                SYstem.debug('Trigger.oldMap: '+Trigger.oldMap);
                if(!DealRetailCampaignTriggerHandler.isFDRCHandler) {
                    DealRetailCampaignTriggerHandler.deleteDealRetailCampaign(Trigger.oldMap);
                }
            }
            //Sambath Seng 25/4/2022 US-0011625 - Bugs/issues and user feedback
            if(Trigger.isInsert){
                DealRetailCampaignTriggerHandler.setStartAndEndTimeDE(Trigger.New);
            }
        }
        /*AFTER Block - END*/
    }
}