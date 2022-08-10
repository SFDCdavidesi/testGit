@isTest
private class SEPCouponControllerTest {
    
    @testSetup
    static void setup(){
        
        EBH_TestDataFactory.setUpCustomSettings();

    	//create an account
        Account acc = new Account( Name = 'TestAccount', SP_Coupons__c='Full Access');
        insert acc;

        //create a contact
        Contact con = new Contact(Accepted_Current_Deals_Agreement__c=false,
                                    FirstName='test fn', LastName='test ln', AccountId=acc.Id, Email = 'test123@test.com');
        insert con;
        
        RecordType couponRecordTypeItem = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_ITEMBASE);
        RecordType couponRecordTypeCat = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_CATEGORYBASE);
        Coupon__c c1 = new Coupon__c(Main_Coupon_Site__c = 'ebay.com',MC_Whitelisted__c = true,Stage__c = 'Draft', RecordTypeID = couponRecordTypeItem.Id,Coupon_Start_Date__c = System.today(),Coupon_End_Date__c=System.today(),Contract_Language__c = 'UK',Contract_Due_Date__c = System.today()-1);
        Coupon__c c2 = new Coupon__c(Main_Coupon_Site__c = 'ebay.com',MC_Whitelisted__c = true,Stage__c = 'Draft', RecordTypeID = couponRecordTypeCat.Id,Coupon_Start_Date__c = System.today(),Coupon_End_Date__c=System.today(),Contract_Language__c = 'UK',Contract_Due_Date__c = System.today()-1);

        insert new List<Coupon__c>{c1,c2};

        RecordType manhattanCouponSellerRecordType = ApexUtil.getRecordTypeByName('Coupon_Seller__c',EBH_ConstantsUtility.COUPONSELLER_MANHATTAN_RECORDTYPE);
        Coupon_Seller__c cs1 = new Coupon_Seller__c(Coupon__c = c1.Id,Coupon_Seller_Stage__c='Targeted',Seller_Contact__c=con.Id,EBH_CouponSellerOwner__c = UserInfo.getUserId(),Seller__c = acc.Id,RecordTypeID=manhattanCouponSellerRecordType.Id);
        Coupon_Seller__c cs2 = new Coupon_Seller__c(Coupon__c = c2.Id,Coupon_Seller_Stage__c='Targeted',Seller_Contact__c=con.Id,EBH_CouponSellerOwner__c = UserInfo.getUserId(),Seller__c = acc.Id,RecordTypeID=manhattanCouponSellerRecordType.Id);
        insert new List<Coupon_Seller__c>{cs1,cs2};

        
    }

    @IsTest
    static void testFetchSingleSEPGlobalVar(){

        Test.startTest();

            Seller_Portal_Global_Variables__mdt result = SEPCouponController.fetchSingleSEPGlobalVar('SEP_Coupon_Seller_Record_Info');

            System.assert( result != null , 'There should be records in custom metadata Seller_Portal_Global_Variables__mdt.');

        Test.stopTest();

    }

    @isTest 
    static void test_updateCouponSellerStage2Review() {

        Coupon_Seller__c cs1 = [SELECT ID FROM Coupon_Seller__c LIMIT 1];

        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1];
        
        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name = 'DE - Seller Portal'];
        
        Contact con = [SELECT Id,Email FROM Contact WHERE FirstName='test fn' AND LastName='test ln' limit 1];
        User user1 = new User(
                                Username = System.now().millisecond() + 'test12345@test.com',
                                ContactId = con.Id,
                                
                                ProfileId = profile1.Id,
                                Alias = 'test123',
                                Email = 'test12345xx@test.com',
                                EmailEncodingKey = 'UTF-8',
                                LastName = 'McTesty',
                                CommunityNickname = 'test12345',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US'
                                );
        
        Test.startTest(); 

        System.runAs(user1) {

            Object result = SEPCouponController.updateCouponSellerStage2Review(String.valueOf(cs1.Id));

            Coupon_Seller__c cs = [SELECT Coupon_Seller_Stage__c FROM Coupon_Seller__c WHERE Id=:cs1.Id];

            System.assert(cs.Coupon_Seller_Stage__c == 'Review', 'This Coupon Seller Stage should changed to Review.');

        }
        
       
        Test.stopTest();
    }

    @isTest 
    static void test_doDeleteCouponCoInvest () {

        Coupon_Seller__c cs1 = [SELECT ID FROM Coupon_Seller__c LIMIT 1];

        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1];
        
        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name = 'DE - Seller Portal'];
        
        Contact con = [SELECT Id,Email FROM Contact WHERE FirstName='test fn' AND LastName='test ln' limit 1];
        User user1 = new User(
                                Username = System.now().millisecond() + 'test12345@test.com',
                                ContactId = con.Id,
                                ProfileId = profile1.Id,
                                
                                Alias = 'test123',
                                Email = 'test12345xx@test.com',
                                EmailEncodingKey = 'UTF-8',
                                LastName = 'McTesty',
                                CommunityNickname = 'test12345',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US'
                                );
        
        Test.startTest(); 

        System.runAs(user1) {

            
            List<Coupon_Co_Invest__c> lstCCI = new List<Coupon_Co_Invest__c>();
            Id cciRT = Schema.SObjectType.Coupon_Co_Invest__c.getRecordTypeInfosByName().get('Coupon Co-Invest Item').getRecordTypeId();

            lstCCI.add(new Coupon_Co_Invest__c(
                Coupon_Seller__c = cs1.Id,
                Seller_Name__c = acc.Id,
                Co_Invest__c = 10,
                CurrencyIsoCode = 'USD',
                RecordtypeId = cciRT
            ));

            // Object result = ClsBulkUploadCSV.doSubmitMultipleCouponItems(lstCCI, 'Item Based');
            insert lstCCI;

            List<Coupon_Co_Invest__c> lstCCICreated = [SELECT Id FROM Coupon_Co_Invest__c];


            Object result = SEPCouponController.doDeleteCouponCoInvest(new List<String>{String.valueOf(lstCCICreated.get(0).Id)});

            System.debug('**** result :: ' + result);

        }
        
       
        Test.stopTest();

    }

    @isTest 
    static void test_getCouponContractTemplate () {
        // Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1];
        // Contact con = [SELECT Id,Email FROM Contact WHERE FirstName='test fn' AND LastName='test ln' limit 1];
        // RecordType couponRecordTypeCat = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_CATEGORYBASE);
        // Coupon__c c1 = new Coupon__c(Main_Coupon_Site__c = 'ebay.com',MC_Whitelisted__c = true,Stage__c = 'Draft', RecordTypeID = couponRecordTypeCat.Id,Coupon_Start_Date__c = System.today(),Coupon_End_Date__c=System.today(),Contract_Language__c = 'UK',Contract_Due_Date__c = System.today()-1);
        // insert c1;
        // RecordType manhattanCouponSellerRecordType = ApexUtil.getRecordTypeByName('Coupon_Seller__c',EBH_ConstantsUtility.COUPONSELLER_MANHATTAN_RECORDTYPE);
        // Coupon_Seller__c cs = new Coupon_Seller__c(Coupon__c = c1.Id,Coupon_Seller_Stage__c='Targeted',Seller_Contact__c=con.Id,EBH_CouponSellerOwner__c = UserInfo.getUserId(),Seller__c = acc.Id,RecordTypeID=manhattanCouponSellerRecordType.Id);
        // insert cs;
        // List<Coupon_Co_Invest__c> lstCCI = new List<Coupon_Co_Invest__c>();
        //     Id cciRT = Schema.SObjectType.Coupon_Co_Invest__c.getRecordTypeInfosByName().get('Coupon Co-Invest Item').getRecordTypeId();
        //     lstCCI.add(new Coupon_Co_Invest__c(
        //         Coupon_Seller__c = cs.Id,
        //         Seller_Name__c = acc.Id,
        //         Co_Invest__c = 10,
        //         CurrencyIsoCode = 'USD',
        //         RecordtypeId = cciRT
        //     ));
        //     insert lstCCI;
        // Test.startTest(); 
        //     String result = SEPCouponController.getCouponContractTemplate(cs.Id);
        //     System.assert(String.isNotBlank(result));
        // Test.stopTest();

        RecordType couponRecordTypeItem = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_ITEMBASE);
        
        Coupon_Seller__c cs1 = [SELECT ID FROM Coupon_Seller__c WHERE Coupon__r.RecordTypeId=:couponRecordTypeItem.Id LIMIT 1];

        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1];
        
        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name = 'DE - Seller Portal'];
        
        Contact con = [SELECT Id,Email FROM Contact WHERE FirstName='test fn' AND LastName='test ln' limit 1];
        User user1 = new User(
                                Username = System.now().millisecond() + 'test12345@test.com',
                                ContactId = con.Id,
                                ProfileId = profile1.Id,
                                
                                Alias = 'test123',
                                Email = 'test12345xx@test.com',
                                EmailEncodingKey = 'UTF-8',
                                LastName = 'McTesty',
                                CommunityNickname = 'test12345',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US'
                                );
        
        Test.startTest(); 

        System.runAs(user1) {

            
            List<Coupon_Co_Invest__c> lstCCI = new List<Coupon_Co_Invest__c>();
            Id cciRT = Schema.SObjectType.Coupon_Co_Invest__c.getRecordTypeInfosByName().get('Coupon Co-Invest Item').getRecordTypeId();

            lstCCI.add(new Coupon_Co_Invest__c(
                Coupon_Seller__c = cs1.Id,
                Seller_Name__c = acc.Id,
                Co_Invest__c = 10,
                CurrencyIsoCode = 'USD',
                RecordtypeId = cciRT
            ));

            // Object result = ClsBulkUploadCSV.doSubmitMultipleCouponItems(lstCCI, 'Item Based');
            insert lstCCI;

            String result = SEPCouponController.getCouponContractTemplate(cs1.Id);
            System.assert(String.isNotBlank(result));

        }
        
       
        Test.stopTest();

    }

    @isTest 
    static void test_getCouponContractTemplate_2 () {
        

        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1];
        Contact con = [SELECT Id,Email FROM Contact WHERE FirstName='test fn' AND LastName='test ln' limit 1];

        
        RecordType couponRecordTypeCat = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_CATEGORYBASE);
        Coupon_Seller__c cs1 = [SELECT ID FROM Coupon_Seller__c WHERE Coupon__r.RecordTypeId=:couponRecordTypeCat.Id LIMIT 1];
        
        
        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name = 'DE - Seller Portal'];
        
        User user1 = new User(
                                Username = System.now().millisecond() + 'test12345@test.com',
                                ContactId = con.Id,
                                ProfileId = profile1.Id,
                                
                                Alias = 'test123',
                                Email = 'test12345xx@test.com',
                                EmailEncodingKey = 'UTF-8',
                                LastName = 'McTesty',
                                CommunityNickname = 'test12345',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US'
                                );
        
        Test.startTest(); 

        System.runAs(user1) {

            
            List<Coupon_Co_Invest__c> lstCCI = new List<Coupon_Co_Invest__c>();
            Id cciRT = Schema.SObjectType.Coupon_Co_Invest__c.getRecordTypeInfosByName().get('Coupon Co-Invest Item').getRecordTypeId();

            lstCCI.add(new Coupon_Co_Invest__c(
                Coupon_Seller__c = cs1.Id,
                Seller_Name__c = acc.Id,
                Co_Invest__c = 10,
                CurrencyIsoCode = 'USD',
                RecordtypeId = cciRT
            ));

            // Object result = ClsBulkUploadCSV.doSubmitMultipleCouponItems(lstCCI, 'Item Based');
            insert lstCCI;

            String result = SEPCouponController.getCouponContractTemplate(cs1.Id);
            System.assert(String.isNotBlank(result));

        }
        
       
        Test.stopTest();

    }

    @isTest 
    static void test_handleContractCouponSellerAgree () {
        Coupon_Seller__c cs = [SELECT ID FROM Coupon_Seller__c LIMIT 1];

        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1];
        
        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name = 'DE - Seller Portal'];
        
        Contact con = [SELECT Id,Email FROM Contact WHERE FirstName='test fn' AND LastName='test ln' limit 1];
        User user1 = new User(
                                Username = System.now().millisecond() + 'test12345@test.com',
                                ContactId = con.Id,
                                ProfileId = profile1.Id,
                                
                                Alias = 'test123',
                                Email = 'test12345xx@test.com',
                                EmailEncodingKey = 'UTF-8',
                                LastName = 'McTesty',
                                CommunityNickname = 'test12345',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US'
                                );
        
        Test.startTest(); 

        System.runAs(user1) {
            SEPCouponController.handleContractCouponSellerAgree(cs.Id, user1.Id, con.Id);
        }        
       
        Test.stopTest();

    }

    @isTest 
    static void test_handleUpdateCouponSellerStage () {
        Coupon_Seller__c cs = [SELECT ID FROM Coupon_Seller__c LIMIT 1];        
        Contact con = [SELECT Id,Email FROM Contact WHERE FirstName='test fn' AND LastName='test ln' limit 1];
        String csId = cs.Id;
        String conId = con.Id;
        Test.startTest(); 

        SEPCouponController.handleUpdateCouponSellerStage(csId, 'Other', 'other', conId);  
       
        Test.stopTest();
        
    }

    @isTest 
    static void test_getAllPickListValue () {
        SEPCouponController.getAllPickListValue('Coupon_Seller__c', 'Seller_Declined_Reasons__c');
    }

    @isTest
    static void test_getCouponSeller2 () {
        Coupon_Seller__c cs = [SELECT ID FROM Coupon_Seller__c LIMIT 1];
        Test.startTest(); 
            SEPCouponController.getCouponSeller2(cs.Id);
        Test.stopTest();
    }

}