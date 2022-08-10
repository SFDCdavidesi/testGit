@isTest
private class BatchUpdateCouponSellerStageTest {
    
    @isTest 
    static void test_UpdateStage4ContactSigned () {

        DateTime now = System.now();
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account acc1 = new Account(Name='Test Abc123',RecordTypeID = sellerRecordType.Id);
        insert acc1;

        RecordType couponRecordTypeItem = ApexUtil.getRecordTypeByName('Coupon__c','Item_Based');
        Coupon__c c1 = new Coupon__c(Main_Coupon_Site__c = 'ebay.com',Contract_Language__c='DE',RecordTypeID = couponRecordTypeItem.Id, Coupon_Start_Time__c=now.timeGmt(), Coupon_End_Time__c=Time.newInstance(12, 22, 30, 000), Coupon_Start_Date__c=System.Today(), Coupon_End_Date__c=System.Today().addDays(2));
        insert c1;

        Coupon_Seller__c cs1 = new Coupon_Seller__c(
            Coupon__c = c1.Id,
            Coupon_Seller_Stage__c='Contract Signed', 
            Seller__c=acc1.Id,
            Cofund_Start_Date__c = Date.today());
        insert cs1;

        Test.startTest();

            BatchUpdateCouponSellerStage bat = new BatchUpdateCouponSellerStage();
            bat.execute(null);

        Test.stopTest();

        for (Coupon_Seller__c cs : [SELECT Coupon_Seller_Stage__c, TriggerStageUpdatedDate__c  FROM Coupon_Seller__c WHERE Id=:cs1.Id]) {
            System.assert(cs.Coupon_Seller_Stage__c == 'Coupon Running', 'Coupon Seller Stage should be "Coupon Running".');
            System.assert(cs.TriggerStageUpdatedDate__c != null);
        }

    }

    @isTest 
    static void test_UpdateStage4CouponRunning () {

        DateTime now = System.now();
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account acc1 = new Account(Name='Test Abc123',RecordTypeID = sellerRecordType.Id);
        insert acc1;

        Date d1 = Date.today().addDays(-7);
        Date d2 = Date.today();

        RecordType couponRecordTypeItem = ApexUtil.getRecordTypeByName('Coupon__c','Item_Based');
        Coupon__c c1 = new Coupon__c(
            Main_Coupon_Site__c = 'ebay.com',
            Contract_Language__c='DE',
            RecordTypeID = couponRecordTypeItem.Id, 
            Coupon_Start_Time__c=now.timeGmt(), 
            Coupon_End_Time__c=Time.newInstance(12, 22, 30, 000), 
            Coupon_Start_Date__c=d1, 
            Coupon_End_Date__c=d2
        );
        insert c1;

       

        Coupon_Seller__c cs1 = new Coupon_Seller__c(
            Coupon__c = c1.Id,
            Coupon_Seller_Stage__c='Coupon Running', 
            Seller__c=acc1.Id,
            Cofund_Start_Date__c = d1,
            Cofund_End_Date__c = d2
        );
        insert cs1;

        Test.startTest();

            BatchUpdateCouponSellerStage bat = new BatchUpdateCouponSellerStage();
            bat.execute(null);

        Test.stopTest();

        for (Coupon_Seller__c cs : [SELECT Coupon_Seller_Stage__c, TriggerStageUpdatedDate__c  FROM Coupon_Seller__c WHERE Id=:cs1.Id]) {
            System.assert(cs.Coupon_Seller_Stage__c == 'Coupon executed', 'Coupon Seller Stage should be "Coupon executed".');
            System.assert(cs.TriggerStageUpdatedDate__c != null);
        }

    }

    @isTest 
    static void test_UpdateStage4PopCouponRunning() {

        DateTime now = System.now();
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account acc1 = new Account(Name='Test Abc123',RecordTypeID = sellerRecordType.Id);
        insert acc1;

        Date d1 = Date.today().addDays(-7);
        Date d2 = Date.today();

        RecordType couponRecordTypePopCP = ApexUtil.getRecordTypeByName('Coupon__c','Pop_Coupon');
        Coupon__c c1 = new Coupon__c(
            
            RecordTypeID = couponRecordTypePopCP.Id, 
            Coupon_Start_Date__c = d1,
            Coupon_End_Date__c = d2,
            Coupon_ID__c = 'TEST POP COUPON'
        );
        insert c1;

       
        RecordType cSRecordTypePopCP = ApexUtil.getRecordTypeByName('Coupon_Seller__c','Pop_Coupon');
        

        Coupon_Seller__c cs1 = new Coupon_Seller__c(
            Coupon__c = c1.Id,
            Coupon_Seller_Stage__c='Running', 
            Seller__c=acc1.Id,
            Cofund_Start_Date__c = d1,
            Cofund_End_Date__c = d2,
            RecordTypeId = cSRecordTypePopCP.Id
        );
        insert cs1;

        Test.startTest();

            BatchUpdateCouponSellerStage bat = new BatchUpdateCouponSellerStage();
            bat.execute(null);

        Test.stopTest();

        for (Coupon_Seller__c cs : [SELECT Coupon_Seller_Stage__c, TriggerStageUpdatedDate__c  FROM Coupon_Seller__c WHERE Id=:cs1.Id]) {
            System.assert(cs.Coupon_Seller_Stage__c == 'Contract Terminated', 'Coupon Seller Stage should be "Contract Terminated".');
            System.assert(cs.TriggerStageUpdatedDate__c != null);
        }

    }

    @isTest 
    static void test_UpdateStage4ContractAccepted() {

        DateTime now = System.now();
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account acc1 = new Account(Name='Test Abc123',RecordTypeID = sellerRecordType.Id);
        insert acc1;

        Date d1 = Date.today();
        Date d2 = Date.today().addDays(7);

        RecordType couponRecordTypePopCP = ApexUtil.getRecordTypeByName('Coupon__c','Pop_Coupon');
        Coupon__c c1 = new Coupon__c(
            
            RecordTypeID = couponRecordTypePopCP.Id, 
            Coupon_Start_Date__c = d1,
            Coupon_End_Date__c = d2,
            Coupon_ID__c = 'TEST POP COUPON'
        );
        insert c1;

       
        RecordType cSRecordTypePopCP = ApexUtil.getRecordTypeByName('Coupon_Seller__c','Pop_Coupon');
        

        Coupon_Seller__c cs1 = new Coupon_Seller__c(
            Coupon__c = c1.Id,
            Coupon_Seller_Stage__c='Contract Accepted', 
            Seller__c=acc1.Id,
            Cofund_Start_Date__c = d1,
            Cofund_End_Date__c = d2,
            RecordTypeId = cSRecordTypePopCP.Id
        );
        insert cs1;

        Test.startTest();

            BatchUpdateCouponSellerStage bat = new BatchUpdateCouponSellerStage();
            bat.execute(null);

        Test.stopTest();

        for (Coupon_Seller__c cs : [SELECT Coupon_Seller_Stage__c, TriggerStageUpdatedDate__c  FROM Coupon_Seller__c WHERE Id=:cs1.Id]) {
            System.assert(cs.Coupon_Seller_Stage__c == 'Running', 'Coupon Seller Stage should be "Running".');
            System.assert(cs.TriggerStageUpdatedDate__c != null);
        }

    }

    @isTest
    static void test_UpdateStage() {

        DateTime now = System.now();
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account acc1 = new Account(Name='Test Abc123',RecordTypeID = sellerRecordType.Id);
        insert acc1;

        RecordType couponRecordTypeItem = ApexUtil.getRecordTypeByName('Coupon__c','Item_Based');
        Coupon__c c1 = new Coupon__c(Main_Coupon_Site__c = 'ebay.com',Contract_Language__c='DE',RecordTypeID = couponRecordTypeItem.Id, Coupon_Start_Time__c=now.timeGmt(), Coupon_End_Time__c=Time.newInstance(12, 22, 30, 000), Coupon_Start_Date__c=System.Today(), Coupon_End_Date__c=System.Today().addDays(2));
        insert c1;

        Coupon_Seller__c cs1 = new Coupon_Seller__c(
            Coupon__c = c1.Id,
            Coupon_Seller_Stage__c='Contract Signed', 
            Seller__c=acc1.Id,
            Cofund_Start_Date__c = Date.today());
        insert cs1;

        Test.startTest();

            BatchUpdateCouponSellerStage bat = new BatchUpdateCouponSellerStage(cs1.Id);
            bat.execute(null);

        Test.stopTest();

        for (Coupon_Seller__c cs : [SELECT Coupon_Seller_Stage__c, TriggerStageUpdatedDate__c  FROM Coupon_Seller__c WHERE Id=:cs1.Id]) {
            System.assert(cs.Coupon_Seller_Stage__c == 'Coupon Running', 'Coupon Seller Stage should be "Coupon Running".');
            System.assert(cs.TriggerStageUpdatedDate__c != null);
        }
    }

    @TestSetup
    static void makeData(){
        
        insert new EBH_ActiveTriggers__c(Name = 'EBH Trigger Controller',
                                         EBH_AccountContactRelationTrigger__c = true,
                                         EBH_AccountTrigger__c = true,
                                         EBH_AttachmentTrigger__c = true,
                                         EBH_BUApprovalGroupTrigger__c = true,
                                         EBH_CampaignApprovalGroupTrigger__c = true,
                                         EBH_CampaignKPITrigger__c = true,
                                         EBH_CampaignMemberTrigger__c = true,
                                         EBH_CampaignTrigger__c = true,
                                         EBH_ContactTrigger__c = true,
                                         EBH_ContentDocumentLinkTrigger__c = true,
                                         EBH_ContentDocumentTrigger__c = true,
                                         EBH_ContractApprovalHierarchyTrigger__c = true,
                                         EBH_ContractApprovalMatrixTrigger__c = true,
                                         EBH_ContractTrigger__c = true,
                                         Coupon__c = false, //Disable Coupon Trigger so that we can use Batch to sync data
                                         Coupon_Category__c = true,
                                         Coupon_Co_Invest__c = true,
                                         Coupon_Item__c = true,
                                         Coupon_Seller__c = true,
                                         EBH_CustomCampaignMemberTrigger__c = true,
                                         EBH_DocuSignStatusTrigger__c = true,
                                         EBH_ExecuteContractUpdateBatch__c = true,
                                         EBH_FeedItemTrigger__c = true,
                                         Final_value_Fee__c = true,                                         
                                         EBH_KPIResultTrigger__c = true,                                         
                                         Nominated_Item__c = true,
                                         EBH_PricingTrigger__c = true,
                                         Product__c = true,
                                         EBH_SellerListTrigger__c = true,
                                         Seller_to_Product__c = true,
                                         EBH_EnableUrgencyEmail__c = true,
                                         EBH_TargetedSellerTrigger__c = true,
                                         EBH_TaskTrigger__c = true,
                                         EBH_TicketTrigger__c = true,
                                         EBH_User__c = true,
                                         DealTrigger__c = true,
                                         Coupon_Send_BCD_File_To_DL__c =true,
                                         Coupon_Seller_Send_T4_T40_to_seller__c =true,
                                         CaseTrigger__c =true
                                        ); 
		ActiveValidationRules__c avr = new ActiveValidationRules__c();
		avr.All_Validation_Rules_Deactivated__c = false;
		insert avr;   

    }
    

    

}