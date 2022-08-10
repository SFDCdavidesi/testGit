/*********************************************************************************************************************************
@ Class:          TransferSellersControllerTest
@ Version:        1.0
@ Author:         Loumang SENG (loumang.seng@gaea-sys.com)
@ Purpose:        test Class for TransferSellersController
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 10.06.2021 / Loumang SENG / Created the class			 
*********************************************************************************************************************************/
@isTest
private  class TransferSellersControllerTest {
    static Account acc;
    static Account acc2;
    static Contact cont;
    static Contact cont2;
    static BoB__c bob;
    static BoB__c bob2;
    static BoB__c bob3;
    static BoB_Seller__c bs;
    static BoB_Seller__c bs2;
    static Action_Template__c template1;
    static Action__c action1;
    static Action_Template__c template2;
    static Action__c action2;

    static void setUpData()
    {
         	RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
            acc = new Account(
                Name='Test Account',
                RecordTypeId=sellerRecordType.Id,
                Managed_Type__c = 'LTTM Managed'
            );
            acc2 = new Account(
                Name='Test Account2',
                RecordTypeId=sellerRecordType.Id,
                Managed_Type__c = 'LTTM Plus'
            );
            insert new List<Account>{acc,acc2};
    
            cont = new Contact(LastName='Last',AccountId=acc.Id);
            cont2 = new Contact(LastName='Last2',AccountId=acc2.Id);
            insert new List<Contact>{cont,cont2};
    
            RecordType boblttmRecordType = ApexUtil.getRecordTypeByName('BOB__c','Light_Touch_Category_Cohort');
            bob = new BoB__c(
                Status__c='BoB Active',
                EBH_BOBCNTRY__c='3',
                EBH_BOBVertical__c='Fashion',
                Managed_Type__c ='LTTM Managed',
                LTTM_Group__c='test group',
                RecordTypeId=boblttmRecordType.Id,
                ownerId = UserInfo.getUserId()
            );
            bob2 = new BoB__c(
                Status__c='BoB Active',
                EBH_BOBCNTRY__c='3',
                EBH_BOBVertical__c='Fashion',
                Managed_Type__c ='LTTM Managed',
                LTTM_Group__c='test group2',
                RecordTypeId=boblttmRecordType.Id,
                ownerId = UserInfo.getUserId()
            );
            bob3 = new BoB__c(
                Status__c='BoB Active',
                EBH_BOBCNTRY__c='3',
                EBH_BOBVertical__c='Fashion',
                Managed_Type__c ='LTTM Plus',
                LTTM_Group__c='test group3',
                RecordTypeId=boblttmRecordType.Id,
                ownerId = UserInfo.getUserId()
            );
            insert new List<BoB__c>{bob,bob2,bob3};
    
            RecordType bobSellerlttmRecordType = ApexUtil.getRecordTypeByName('BoB_Seller__c','LTTM');
    
            bs = new BoB_Seller__c(
                RecordTypeId = bobSellerlttmRecordType.Id,
                Parent_Seller__c=acc.Id,
                Account_Manager__c=UserInfo.getUserId(),
                Status__c=EBH_ConstantsUtility.BOB_SELLER_STATUS_DRAFT,
                Seller__c=acc.Id,
                BoB__c = bob.Id,
                EBH_BOBSegment__c='MSO',
                BoB_Subsegment__c='Platin',
                Call_Outcome__c='Next call scheduled',
                Call_Attempt__c = 0
            );
            bs2 = new BoB_Seller__c(
                RecordTypeId = bobSellerlttmRecordType.Id,
                Parent_Seller__c=acc2.Id,
                Account_Manager__c=UserInfo.getUserId(),
                Status__c=EBH_ConstantsUtility.BOB_SELLER_STATUS_DRAFT,
                Seller__c=acc2.Id,
                BoB__c = bob3.Id,
                EBH_BOBSegment__c='MSO',
                BoB_Subsegment__c='Platin',
                Call_Outcome__c='Next call scheduled',
                Call_Attempt__c = 0
            );
    
            insert new List<BoB_Seller__c>{bs,bs2};
    
            template1 = new Action_Template__c(Name='Tempalte1',Active__c=true);
            insert template1;
    
            action1 = new Action__c(Name='Action1',Action_Template__c=template1.Id,LTTM_Seller__c=bs.Id,Status__c='Not Started');
            insert action1;
    
            template2 = new Action_Template__c(Name='Tempalte2',Active__c=true);
            insert template2;
    
            action2 = new Action__c(Name='Action2',Action_Template__c=template2.Id,LTTM_Seller__c=bs2.Id,Status__c='Not Started');
            insert action2;   
    }

    @IsTest
    static void testApexInit(){
        setUpData();
        Test.startTest(); 
            Map<String,Object> mapResult1 =  TransferSellersController.apexInit(bob2.Id,null);
            Map<String,Object> mapResult2 =  TransferSellersController.apexInit(bob3.Id,bs2.Id);
            Map<String,Object> mapResult3 =  TransferSellersController.apexInit(bob2.Id,bs.Id);
            //system.System.debug('size:::'+mapResult1);
            //System.assertEquals(1, ((List<BOB__C>)mapResult.get('listPossibleBob')).size(),'1 realted contact');

        Test.stopTest();
        
    }  

    @IsTest
    static void testApexSave(){
        setUpData();
        BoB_Seller__c bobSeller = new BoB_Seller__c(Account_Manager__c = UserInfo.getUserId(),TTEC_MANAGER__c=UserInfo.getUserId());

        Test.startTest();
            Map<String,Object> mapResult =  TransferSellersController.apexSave(bob2.Id,bs.Id,bobSeller);
        Test.stopTest();
        BoB_Seller__c bsSel = [Select Id,Name,BoB__c From BoB_Seller__c Where Id=:bs.Id];
        //System.assertEquals(bsSel.BoB__c, bob2.Id);
    }

    @isTest
    static void test_createaction() {
        setUpData();

        Test.startTest();
            List<BoB_Seller__c> lstbs = [select Id, BOB__c, RecordTypeId from BoB_Seller__c where BOB__c=:bob.Id AND RecordType.DeveloperName='LTTM' AND Managed_Type__c='LTTM Managed'];
            Test.setCurrentPage(Page.TransferSellers);

            ApexPages.currentPage().getParameters().put('id',bob.Id);

            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(lstbs);
            sc.setSelected(new List<BoB_Seller__c>());
            TransferSellersController tc = new TransferSellersController(sc);
            sc.setSelected(lstbs);
            tc = new TransferSellersController(sc);
            //tc.backToListView();

            System.assert(String.isNotBlank(tc.bobId));
            System.assert(String.isNotBlank(tc.bobSellerIds));

        Test.stopTest();
    }

}