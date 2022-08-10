@isTest
private class BatchCouponSellerStatusTest {
    
    static testMethod void testCouponSellerAutoStatus() {
		DateTime now = System.now();
		RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account acc1 = new Account(Name='Test Abc123',RecordTypeID = sellerRecordType.Id);
        insert acc1;
        
		RecordType couponRecordTypeItem = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_CATEGORYBASE);
        Coupon__c c1 = new Coupon__c(Contract_Language__c='DE',RecordTypeID = couponRecordTypeItem.Id, Coupon_Start_Time__c=now.timeGmt(), Coupon_End_Time__c=Time.newInstance(12, 22, 30, 000), Coupon_Start_Date__c=System.Today(), Coupon_End_Date__c=System.Today().addDays(2));
        Coupon__c c2 = new Coupon__c(Contract_Language__c='DE',RecordTypeID = couponRecordTypeItem.Id, Coupon_Start_Time__c=now.timeGmt(), Coupon_End_Time__c=now.timeGmt(), Coupon_Start_Date__c=System.Today().addDays(-5), Coupon_End_Date__c=System.Today());
        Coupon__c cT4 = new Coupon__c(Contract_Language__c='DE',RecordTypeID = couponRecordTypeItem.Id, Coupon_Start_Time__c=now.timeGmt(), Coupon_End_Time__c=Time.newInstance(12, 22, 30, 000), Coupon_Start_Date__c=System.Today().addDays(-10), Coupon_End_Date__c=System.Today().addDays(-4));
        Coupon__c cT40 = new Coupon__c(Contract_Language__c='DE',RecordTypeID = couponRecordTypeItem.Id, Coupon_Start_Time__c=now.timeGmt(), Coupon_End_Time__c=now.timeGmt(), Coupon_Start_Date__c=System.Today().addDays(-50), Coupon_End_Date__c=System.Today().addDays(-40));
        
		//insert new List<Coupon__c>{c1,c2,cT4,cT40};
		insert c1;
		insert c2;
		insert cT4;
		insert cT40;
		
		 
    	Coupon_Seller__c cs1 = new Coupon_Seller__c(Coupon__c = c1.Id,Coupon_Seller_Stage__c=EBH_ConstantsUtility.COUPON_SELLER_STAGE_CONTRACT_SIGNED, Seller__c=acc1.Id);
    	Coupon_Seller__c cs2 = new Coupon_Seller__c(Coupon__c = c2.Id,Coupon_Seller_Stage__c=EBH_ConstantsUtility.COUPON_SELLER_STAGE_RUNNING, Seller__c=acc1.Id);
    	Coupon_Seller__c csT4 = new Coupon_Seller__c(Coupon__c = cT4.Id,Coupon_Seller_Stage__c=EBH_ConstantsUtility.COUPON_SELLER_STAGE_CONTRACT_SIGNED, Seller__c=acc1.Id);
    	Coupon_Seller__c csT40 = new Coupon_Seller__c(Coupon__c = cT40.Id,Coupon_Seller_Stage__c=EBH_ConstantsUtility.COUPON_SELLER_STAGE_RUNNING, Seller__c=acc1.Id);
		insert new List<Coupon_Seller__c>{cs1,cs2,csT4,csT40};
    	
		Test.startTest();
		
		BatchCouponSellerStatus b = new BatchCouponSellerStatus();
		BatchCouponSellerStatus b1 = new BatchCouponSellerStatus(c1.Id);
		Database.executeBatch(b);
		
		Test.stopTest();
		
		Coupon_Seller__c res1 = [select Coupon_Seller_Stage__c from Coupon_Seller__c where Id =:cs1.Id];
		System.assertEquals('Coupon Running', res1.Coupon_Seller_Stage__c, 'Coupon Seller stage is Coupon Running');

		Coupon_Seller__c res2= [select Coupon_Seller_Stage__c from Coupon_Seller__c where Id =:cs2.Id];
		System.assertEquals('Coupon executed', res2.Coupon_Seller_Stage__c, 'Coupon Seller stage is Coupon executed');
        
        BatchCouponSellerStatus.runSchedulerHourly();
        b.execute(null);
    }
}