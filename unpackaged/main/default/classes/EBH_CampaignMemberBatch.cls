/*********************************************************************************************************************************
@ Class:          EBH_CampaignMemberBatch
@ Version:        1.0
@ Author:         ASHISH BARANWAL (asbaranwal@deloitte.co.uk)
@ Purpose:        Batch class to insert targeted seller
                  EPH-106 : Campaign Member creation
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 22.07.2017 / ASHISH BARANWAL (asbaranwal@deloitte.co.uk) / Created the class.
				 26.01.2022 / Sambath Seng / US-0008351 DEPRECIATED
*********************************************************************************************************************************/

global with sharing class EBH_CampaignMemberBatch{

    global EBH_CampaignMemberBatch() {}
    
    /*global final String AccountContactReleationQuery = EBH_ConstantsUtility.CTH_ACRQUERY;
    global final Map<Id,List<EBH_TargetedSeller__c>> sellerListTargetedSellerMap;
    global final Map<Id, Campaign> sellerIdCampaignMap;
    global final Set<Id> accountIds;
    global final Set<Id> campaignIds;*/
    
    /*****************************************************************************************************************************
    @ Constructor:    EBH_CampaignMemberBatch
    @ Version:        1.0
    @ Author:         ASHISH BARANWAL (asbaranwal@deloitte.co.uk)
    @ Purpose:        Initialises the class for controller instance.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Seller List record, LocalAccQuery
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 22.07.2017 / ASHISH BARANWAL (asbaranwal@deloitte.co.uk) / Created the constructor.
    *****************************************************************************************************************************/
    /*global EBH_CampaignMemberBatch (Set<Id> accounts, Set<Id> campaigns, 
                                    Map<Id,List<EBH_TargetedSeller__c>> sellerListTargetedSellers, 
                                    Map<Id, Campaign> sellerIdCampaigns){
        accountIds = accounts;
        campaignIds = campaigns;
        sellerListTargetedSellerMap = sellerListTargetedSellers;
        sellerIdCampaignMap = sellerIdCampaigns;
    }*/
    /*****************************************************************************************************************************
    @ Method:         start
    @ Version:        1.0
    @ Author:         ASHISH BARANWAL (asbaranwal@deloitte.co.uk)
    @ Purpose:        QueryLocator start method
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 22.07.2017 / ASHISH BARANWAL (asbaranwal@deloitte.co.uk) / Created the method.
    *****************************************************************************************************************************/
    /*global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(AccountContactReleationQuery);
    }*/
    
    /*****************************************************************************************************************************
    @ Method:         execute
    @ Version:        1.0
    @ Author:         ASHISH BARANWAL (asbaranwal@deloitte.co.uk)
    @ Purpose:        QueryLocator execute method
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 22.07.2017 / ASHISH BARANWAL (asbaranwal@deloitte.co.uk) / Created the method.
    *****************************************************************************************************************************/
    /*global void execute(Database.BatchableContext pBc, List<Account> scope){
        
        Map<Id, Account> accountMap = new Map<Id, Account>();    //account map
        List<CampaignMember> campaignMemberListToDelete = new List<CampaignMember>();    //list of CampaignMember to delete
        Map<Id,CampaignMember> campaignMemberMap = new Map<Id,CampaignMember>();    //list of CampaignMember to insert
        Map<Id,List<AccountContactRelation>> sellerListContactMap = new Map<Id,List<AccountContactRelation>>();    
        
        //fetch all the account and related contacts
        for(Account acc : scope) {
            accountMap.put(acc.Id, acc);
        }
        
        //to get all contacts in sellerListContactMap
        List<AccountContactRelation> conList = new List<AccountContactRelation>();          
        for(List<EBH_TargetedSeller__c> targetedSellerListIterate : sellerListTargetedSellerMap.values()){
            for(EBH_TargetedSeller__c targetedSellerRecord : targetedSellerListIterate){
                if(sellerListContactMap.containsKey(targetedSellerRecord.EBH_SellerList__c)){
                    conList.addAll(accountMap.get(targetedSellerRecord.EBH_Seller__c).AccountContactRelations);
                } 
                else {
                    conList = new List<AccountContactRelation>();          
                    conList.addAll(accountMap.get(targetedSellerRecord.EBH_Seller__c).AccountContactRelations);
                }
                sellerListContactMap.put(targetedSellerRecord.EBH_SellerList__c, conList);
            }
        }
        
        //camapignMember list to delete
        campaignMemberListToDelete = Database.query(EBH_ConstantsUtility.CTH_CAMPAIGNMEMBERTODELETERQUERY);
        
        //to iterate through campaigns
        for(Campaign campaignRecord : sellerIdCampaignMap.values()){
            //proceed if sellerListContactMap and campaign has the same sellerlist 
            if(sellerListContactMap.containsKey(campaignRecord.EBH_SellerList__c)){
                //to iterate through contacts
                for(AccountContactRelation contactRecord : sellerListContactMap.get(campaignRecord.EBH_SellerList__c)){
                    CampaignMember campaignMemberRecord = new CampaignMember();    //new CampaignMember
                    campaignMemberRecord.CampaignId = campaignRecord.Id;
                    campaignMemberRecord.ContactId = contactRecord.ContactId;
                    campaignMemberMap.put(contactRecord.ContactId,campaignMemberRecord); //bulkify-add to campaignMemberList
                }
            }
        }
        //proceed if list is not empty
        if(!campaignMemberListToDelete.isEmpty()){
            try {
                Database.delete(campaignMemberListToDelete);
            } catch(Exception ex) {
                EBH_ApexLogger.logError(new List<Exception> { ex }, 
                                        EBH_ConstantsUtility.CTH_CLASS, EBH_ConstantsUtility.CTH_CCMMETHOD);
            } 
        } 
        //proceed if map is not empty
        if(!campaignMemberMap.values().isEmpty()){
            try {
                Database.insert(campaignMemberMap.values());
            } catch(Exception ex) {
                EBH_ApexLogger.logError(new List<Exception> { ex }, 
                                        EBH_ConstantsUtility.CTH_CLASS, EBH_ConstantsUtility.CTH_CCMMETHOD);
            }   
        }        
    }*/
    
    /*****************************************************************************************************************************
    @ Method:         finish
    @ Version:        1.0
    @ Author:         ASHISH BARANWAL (asbaranwal@deloitte.co.uk)
    @ Purpose:        QueryLocator finish method, it sends an email notification to the seller list owner once the insert batch
                      is complete.  
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 22.07.2017 / ASHISH BARANWAL (asbaranwal@deloitte.co.uk) / Created the method.
    *****************************************************************************************************************************/
    /*global void finish(Database.BatchableContext pBc){
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {Filter.Owner.Email};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo(EBH_ConstantsUtility.ITSBATCH_NOREPLY);
        mail.setSubject(Label.EBH_TargetingEngineBatchComplete);
        mail.setSenderDisplayName(EBH_ConstantsUtility.ITSBATCH_SENDERDISPLAY + Filter.Name);
        mail.setTargetObjectId(Filter.OwnerId);
        mail.setWhatId(filter.Id);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(EBH_ConstantsUtility.ITSBATCH_MAILBODY + EBH_LightningURL__c.getInstance().EBH_URL__c+ Filter.Id);
                              
        if(toAddresses[0] != null) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }*/
}