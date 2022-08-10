@isTest
private class EBH_CampaignMemberBatchTest {
	@isTest
    static void testCampaignMemberBatch(){
        EBH_CampaignMemberBatch cmb = new EBH_CampaignMemberBatch();
    //     EBH_TestDataFactory.setUpCustomSettings();
    //     Set<Id> accIds = new Set<Id>();
    //     Set<Id> camIds = new Set<Id>();
    //     Map<Id, Campaign> camIdMap = new Map<Id, Campaign>();
    //     Map<Id, List<EBH_TargetedSeller__c>> sellerListTargetedSellerMap = new Map<Id, List<EBH_TargetedSeller__c>>();
    //     List<EBH_TargetedSeller__c> lstTargetedSeller1 = new List<EBH_TargetedSeller__c>();
    //     List<Account> sellers = EBH_TestDataFactory.createAccounts(2, 'EBH_Seller');
    //     RecordType rtSellerList = EBH_TestDataFactory.getRecordTypeByName('EBH_Filter__c', 'EBH_ManualSellerList');
    //     EBH_Filter__c sellerList1 = new EBH_Filter__c(Name='test', RecordTypeId=rtSellerList.Id);
    //     insert sellerList1;
    //     List<Campaign> campaign1 = EBH_TestDataFactory.createCampaignsWithParent(2, 'Test Campaign1', 'UK', EBH_ConstantsUtility.CAMP_RECORDTYPE_OUTREACH, null, 'Feasibility');
    //     RecordType rtContact = EBH_TestDataFactory.getRecordTypeByName('Contact','EBH_DWH');
    //     Contact con1 = new Contact(EBH_Status__c='Active', LastName = 'Test Contact 1', AccountId = sellers[0].Id, recordTypeId = rtContact.Id);
    //     insert con1;
    //     Contact con2 = new Contact(EBH_Status__c='Active', LastName = 'Test Contact 2', AccountId = sellers[1].Id, recordTypeId = rtContact.Id);
    //     insert con2;
    //     lstTargetedSeller1.add(new EBH_TargetedSeller__c(EBH_Seller__c=sellers[0].Id, EBH_SellerList__c=sellerList1.Id, Priority__c=10, EBH_ExitCode__c='10'));
    //     lstTargetedSeller1.add(new EBH_TargetedSeller__c(EBH_Seller__c=sellers[1].Id, EBH_SellerList__c=sellerList1.Id, Priority__c=10, EBH_ExitCode__c='10'));
    //     insert lstTargetedSeller1;
    //     for(Account oAcc : sellers){
    //         accIds.add(oAcc.Id);
    //     }
    //     for(Campaign oCam : campaign1){
    //         camIds.add(oCam.Id);
    //         camIdMap.put(oCam.Id, oCam);
    //     }
    //     sellerListTargetedSellerMap.put(sellerList1.Id, lstTargetedSeller1);
    //     List<AccountContactRelation> lstAccCon = [SELECT ContactId, Account.Name FROM AccountContactRelation WHERE accountId IN :accIds];
    //     System.debug('lst Acc Con ='+lstAccCon);
    //     System.debug('sellerListTargetedSellerMap value = '+sellerListTargetedSellerMap.values());
    //     Test.startTest();
    //         Database.executeBatch(new EBH_CampaignMemberBatch(accIds, camIds, sellerListTargetedSellerMap, camIdMap));
    //     Test.stopTest();
    }
}