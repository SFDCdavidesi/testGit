@isTest
private class Batch_CreateCoInvestTest {
    static RecordType sellerRecordType;
    static Map<String,RecordType> couponRecordType;
    static Account acc;
    static Account acc2;    	 
    static Coupon__c c1;	 
    static Coupon_Seller__c cs1;
    static Coupon_Seller__c cs2;    	 
    static Category_Tree__c ct1;     
    static Category_Tree__c ct2;
    static Coupon_Category__c cc1;
    static Coupon_Category__c cc2;        
        
    static void setupData()
    {
        EBH_TestDataFactory.setUpCustomSettings();  

        sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	couponRecordType = ApexUtil.getRecordTypeBySobjectName('Coupon__c');
    	acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id);
    	acc2 = new Account(Name='Test Acc2',RecordTypeID = sellerRecordType.Id);
    	insert new List<Account>{acc,acc2};
    	c1 = new Coupon__c(RecordTypeID = couponRecordType.get(EBH_ConstantsUtility.COUPON_CATEGORYBASE).Id);
		insert c1;
    	cs1 = new Coupon_Seller__c(Coupon__c = c1.Id,seller__c = acc.Id);
    	cs2 = new Coupon_Seller__c(Coupon__c = c1.Id,seller__c = acc2.Id);
    	insert new List<Coupon_Seller__c>{cs1,cs2};
    	ct1 = new Category_Tree__c(Name = 'testCategoryTree1',Level__c = 0,Active__c=true);
    	ct2 = new Category_Tree__c(Name = 'testCategoryTree2',Level__c = 1,Note_ID__c=ct1.Id,Active__c=true);
    	insert ct2;
    	cc1 = new Coupon_Category__c(Coupon__c = c1.Id,Category__c = ct1.Id);
    	cc2 = new Coupon_Category__c(Coupon__c = c1.Id,Category__c = ct2.Id);
    	insert new List<Coupon_Category__c>{cc1,cc2};
    }
    static @IsTest
    void testBatchCoInvest(){
        setupData();       

        Test.startTest();
            Batch_CreateCoInvest bCoInvest = new Batch_CreateCoInvest(new Set<Id>{c1.Id});
            Database.executeBatch(bCoInvest);
        Test.stopTest();
        
    }
}