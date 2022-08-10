@isTest
private class SEP_HelperTest {
    
    @TestSetup
    static void makeData(){
        
        insert new SEPWindowAlert__c(SetupOwnerId=UserInfo.getOrganizationId(), Deploying__c=true);

        EBH_TestDataFactory.setUpCustomSettings();

    	//create an account
        Account acc = new Account( Name = 'TestAccount' );
        insert acc;

        //create a contact
        Contact con = new Contact(Accepted_Current_Deals_Agreement__c=false,
                                    FirstName='test fn', LastName='test ln', AccountId=acc.Id, Email = 'test123@test.com');
        insert con;
        
        RecordType couponRecordTypeItem = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_ITEMBASE);
        RecordType couponRecordTypeCat = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_CATEGORYBASE);
        Coupon__c c1 = new Coupon__c(Main_Coupon_Site__c = 'ebay.com',MC_Whitelisted__c = true,Stage__c = 'Draft', RecordTypeID = couponRecordTypeItem.Id,Coupon_Start_Date__c = System.today(),Coupon_End_Date__c=System.today(),Contract_Language__c = 'UK',Contract_Due_Date__c = System.today()-1);
        insert new List<Coupon__c>{c1};

        RecordType manhattanCouponSellerRecordType = ApexUtil.getRecordTypeByName('Coupon_Seller__c',EBH_ConstantsUtility.COUPONSELLER_MANHATTAN_RECORDTYPE);
        Coupon_Seller__c cs1 = new Coupon_Seller__c(Coupon__c = c1.Id,Coupon_Seller_Stage__c='Targeted',Seller_Contact__c=con.Id,EBH_CouponSellerOwner__c = UserInfo.getUserId(),Seller__c = acc.Id,RecordTypeID=manhattanCouponSellerRecordType.Id);
        insert cs1;

    }

    @IsTest 
    static void test_initRecordInfo() {

        Test.startTest();
            
            Coupon_Seller__c cs1 = [SELECT ID FROM Coupon_Seller__c LIMIT 1];

            Map<String, Object> mResult = SEP_Helper.initRecordInfo(cs1.Id, '', '');

            System.assert( !mResult.isEmpty(), 'There should be data in the result.');

            
        Test.stopTest();
    }

}