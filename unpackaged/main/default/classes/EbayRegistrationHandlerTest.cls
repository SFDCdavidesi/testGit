/**
 * change log:
 *  11/04/2022: US-0010870 - Auto Provisioning of Sellers (Deals) - NA, DE
 */
@isTest
private class EbayRegistrationHandlerTest {
    @TestSetup
    private static void makeData(){

        User[] admins = [Select Id From User WHERE Profile.Name ='System Administrator' AND IsActive=TRUE LIMIT 2];
        RecordType recSeller = ApexUtil.getRecordTypeByName('Account', 'EBH_Seller');
        RecordType recSellerGroup = ApexUtil.getRecordTypeByName('Account', 'Seller_Portal_Group');
        Account portalAccount1;
        Contact contact1, contact2,contact3,contact4,contact5,contact6,contact7,contactGroup;
        System.runAs(admins[0])
        {
            //SP_Deals__c IN ('Full Access', 'Read Only')
            //Create account
            portalAccount1 = new Account(
                Name = 'AMT_TEST',
                eBay_API_User_Id__c = 'test_test_test',
                RecordTypeId = recSeller.Id,
                SP_Deals__c = 'Full Access'
            );
            //Seller_Portal_Setting__mdt :
            // EBH_DealsProgram__c IN ('Allow','Accepted') AND EBH_RevRollup__c = 'DE' AND Seller_Portal_Beta_User__c = TRUE
            Account portalAccount2 = new Account(
                Name = 'seller1DE',
                eBay_API_User_Id__c = 'seller1DE',
                RecordTypeId = recSeller.Id,
                EBH_DealsProgram__c = 'Accepted',
                EBH_RevRollup__c  = 'DE',
                Seller_Portal_Beta_User__c =true,
                SP_Deals__c = 'Full Access'
            );
            //Seller_Portal_Setting__mdt : 
            //EBH_RevRollup__c IN ('US','CA') AND EBH_PredictedStandard__c = 'ETRS' AND EBH_PositiveFeedback__c >= 98 AND EBH_VeROViolation__c = FALSE AND EBH_LastSellDate__c >= LAST_90_DAYS AND EBH_FeedbackScore__c > 2000 AND EBH_StoreSubscription__c IN ('Anchor','Platinum') AND EBH_ActualStandard__c IN ('Above Standard','ETRS') AND EBH_GMVLast12Months__c >= 60000
            Account portalAccount3 = new Account(
                Name = 'seller2NA',
                eBay_API_User_Id__c = 'seller2NA',
                RecordTypeId = recSeller.Id,
                EBH_RevRollup__c  = 'US',
                EBH_PredictedStandard__c = 'ETRS',
                EBH_PositiveFeedback__c = 100,
                EBH_VeROViolation__c = false,
                EBH_LastSellDate__c = System.today().addDays(-5),
                EBH_FeedbackScore__c = 3000,
                EBH_StoreSubscription__c = 'Anchor',
                EBH_ActualStandard__c = 'ETRS',
                EBH_GMVLast12Months__c = 70000,
                SP_Deals__c = 'Full Access'

            );
            Account portalAccount4 = new Account(
                Name = 'seller2NA2',
                eBay_API_User_Id__c = 'seller2NA2',
                RecordTypeId = recSeller.Id,
                EBH_RevRollup__c  = 'US',
                EBH_PredictedStandard__c = 'ETRS',
                EBH_PositiveFeedback__c = 100,
                EBH_VeROViolation__c = false,
                EBH_LastSellDate__c = System.today(),
                EBH_FeedbackScore__c = 3000,
                EBH_StoreSubscription__c = 'Anchor',
                EBH_ActualStandard__c = 'ETRS',
                EBH_GMVLast12Months__c = 70000,
                SP_Deals__c = 'Full Access'

            );
            Account portalAccount5 = new Account(
                Name = 'seller2AU',
                eBay_API_User_Id__c = 'seller2AU',
                RecordTypeId = recSeller.Id,
                EBH_RevRollup__c  = 'AU',
                EBH_PredictedStandard__c = 'ETRS',
                EBH_PositiveFeedback__c = 100,
                EBH_VeROViolation__c = false,
                EBH_LastSellDate__c = System.today(),
                EBH_FeedbackScore__c = 3000,
                EBH_StoreSubscription__c = 'Anchor',
                EBH_ActualStandard__c = 'ETRS',
                EBH_GMVLast12Months__c = 70000,
                SP_Deals__c = 'Full Access'

            );
            // Account for SSO
            Account portalSSOAccountGroup = new Account(
                Name = 'TestGroup',
                RecordTypeId = recSellerGroup.Id
            );
            insert portalSSOAccountGroup;
            Account portalSSOAccount1 = new Account(
                Name = 'apiSSOid',
                eBay_API_User_Id__c = 'apiSSOid',
                RecordTypeId = recSeller.Id,
                EBH_DealsProgram__c = 'Accepted', 
                EBH_RevRollup__c  = 'DE',
                Seller_Portal_Beta_User__c =true,
                Seller_Portal_Group__c = portalSSOAccountGroup.Id,
                SP_Deals__c = 'Full Access'
            );
            Account portalSSOAccount2 = new Account(
                Name = 'apiSSOid2',
                //eBay_API_User_Id__c = 'apiSSOid2',
                RecordTypeId = recSeller.Id,
                EBH_DealsProgram__c = 'Accepted',
                EBH_RevRollup__c  = 'DE',
                Seller_Portal_Beta_User__c =true,
               /// Seller_Portal_Group__c = portalSSOAccountGroup.Id,
                SP_Deals__c = 'Full Access'
            );
            
            
            insert new List<Account>{portalAccount1,portalAccount2,portalAccount3,portalAccount4,portalAccount5,portalSSOAccount1,portalSSOAccount2};

            //Create contact
            contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'AMT_TEST',
                AccountId = portalAccount1.Id,
                Email = System.now().millisecond() + 'test@test.com'
            );
            contact2 = new Contact(
                FirstName = 'Test',
                Lastname = 'test contact 002',
                AccountId = portalAccount2.Id,
                Email = System.now().millisecond() + 'test002@test.com'
            );
            contact3 = new Contact(
                FirstName = 'Test',
                Lastname = 'test contact 003',
                AccountId = portalAccount3.Id,
                Email = System.now().millisecond() + 'test003@test.com'
            );
            contact4 = new Contact(
                FirstName = 'Test',
                Lastname = 'test contact 004',
                AccountId = portalAccount4.Id,
                Email = System.now().millisecond() + 'test004@test.com'
            );
            contact5 = new Contact(
                FirstName = 'de',
                Lastname = 'testSSO',
                AccountId = portalSSOAccount1.Id,
                Email = System.now().millisecond() + 'testsso1@test.com'
            );
            contact6 = new Contact(
                FirstName = 'de',
                Lastname = 'testSSO2',
                AccountId = portalSSOAccount2.Id,
                Email = System.now().millisecond() + 'testsso2@test.com'
            );
            contact7 = new Contact(
                FirstName = 'Test',
                Lastname = 'test contact 007',
                AccountId = portalAccount5.Id,
                Email = System.now().millisecond() + 'test007@test.com'
            );
            contactGroup = new Contact(
                FirstName = 'de',
                Lastname = 'testSSO',
                AccountId = portalSSOAccountGroup.Id,
                Email = System.now().millisecond() + 'testsso2@test.com'
            );
            insert new Contact[]{contact1,contact2,contact3,contact4,contact5,contact6,contact7,contactGroup};
        }

        System.runAs(admins[1])
        {
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'NA - Seller Portal' LIMIT 1];
            Profile portalProfileAU = [SELECT Id FROM Profile WHERE Name = 'AU - Seller Portal' LIMIT 1];

            User user1 = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = contact1.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'AMT_TEST',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            User user2 = new User(
                Username = System.now().millisecond() + 'test12345_002@test.com',
                ContactId = contact3.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test1402',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'user003',
                CommunityNickname = 'user003',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US' 
            );
            User user3 = new User(
                Username = System.now().millisecond() + 'test12345_003@test.com',
                ContactId = contact4.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test1203',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'user004',
                CommunityNickname = 'user004',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                IsActive= False
            );
            User user4 = new User(
                Username = System.now().millisecond() + 'testsso@test.com',
                ContactId = contactGroup.Id,
                ProfileId = portalProfile.Id,
                Alias = 'TestSSO',
                Email = 'testsso@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'testsso',
                CommunityNickname = 'testsso',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                IsActive= False
            );
            User user5 = new User(
                Username = System.now().millisecond() + 'testsso2@test.com',
                ContactId = contact6.Id,
                ProfileId = portalProfile.Id,
                Alias = 'testsso2',
                Email = 'testsso2@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'testsso2',
                CommunityNickname = 'testsso2',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                IsActive= False
            );

            
            insert new User[]{user1,user2,user3};
        }        
    }
    /*
    @isTest
    private static void ebayRegistrationHandlerTest() {
        EbayRegistrationHandler handler = new EbayRegistrationHandler();
        Auth.UserData sampleData = new Auth.UserData('test_test_test', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{'language' => 'en_US'});

        Auth.UserData sampleDataError = new Auth.UserData('test_123', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{'language' => 'en_US'});
        handler.createUser(null, sampleData);
        handler.updateUser(null, null, sampleData);
        
        try {
            handler.createUser(null, sampleDataError);
            system.assert(false);
        } catch (Exception ex) {
            
        }
        
    }
    */
    @isTest
    private static void ebayRegistrationHandlerTest2() {
        EbayRegistrationHandler handler = new EbayRegistrationHandler();

        //create user DE
        Auth.UserData sampleData = new Auth.UserData('seller1DE', 'testFirst2', 'seller1DE','testFirst testLast', 'testuser2_seller1DE@example2.org', 'seller1DE', 'seller1DE', 'en_US', 'facebook',null, new Map<String, String>{'language' => 'en_US'});
        User newUser = handler.createUser(null, sampleData);
        System.assert(newUser.Permission_Sets__c.contains('Seller_Portal_DE'),'user is eligible for portal');

        //create user NA
        Auth.UserData sampleDataNA = new Auth.UserData('seller2NA', 'testFirst2', 'seller2NA','testFirst testLast', 'testuser2_seller1DE@example2.org', 'seller2NA', 'seller2NA', 'en_US', 'facebook',null, new Map<String, String>{'language' => 'en_US'});
        User newUserNA = handler.createUser(null, sampleDataNA);  
        
        //create user AU
        Auth.UserData sampleDataAU = new Auth.UserData('seller2AU', 'testFirst2', 'seller2AU','testFirst testLast', 'testuser2_seller1AU@example2.org', 'seller2AU', 'seller2AU', 'en_US', 'facebook',null, new Map<String, String>{'language' => 'en_US'});
        User newUserAU = handler.createUser(null, sampleDataAU);  
        
        //reactivate user NA
        Auth.UserData sampleDataNA2 = new Auth.UserData('seller2NA2', 'testFirst2', 'seller2NA2','testFirst testLast', 'testuser2_seller1DE@example2.org', 'seller2NA2', 'seller2NA2', 'en_US', 'facebook',null, new Map<String, String>{'language' => 'en_US'});
        User newUserNA2 = handler.createUser(null, sampleDataNA2);
        
         
    }
    @isTest
    private static void ebayRegistrationHandlerTestAC1() {
        EbayRegistrationHandler handler = new EbayRegistrationHandler();

        //create user DE
        Auth.UserData sampleData = new Auth.UserData('apiSSOid1', 'test', 'apiSSOid1','test', 'testsso_apiSSOid1@example2.org', 'apiSSOid1', 'apiSSOid1', 'en_US', 'facebook',null, new Map<String, String>{'language' => 'en_US'});
        // AC1
        try{
            User newUser = handler.createUser(null, sampleData);
        }catch(Exception e){
            System.assertEquals('Sorry your Account was not found! Please ensure you are using a Business Account to use the Seller Portal.',e.getMessage());
        }
    }
    @isTest
    private static void ebayRegistrationHandlerTest3() {
        EbayRegistrationHandler handler = new EbayRegistrationHandler();
        List<Account> lstAcc = new List<Account>();
        for(Account acc: [Select Id,Name,eBay_API_User_Id__c,Seller_Portal_Group__c FROM Account Where Name = 'apiSSOid' or Name = 'apiSSOid2' or Name ='TestGroup']){
            acc.eBay_API_User_Id__c = acc.Name;  
            lstAcc.add(acc);
        }
        update lstAcc;
        //create user DE
        Auth.UserData sampleData = new Auth.UserData('apiSSOid2', 'test', 'apiSSOid2','test', 'testsso_apiSSOid2@example2.org', 'apiSSOid2', 'apiSSOid2', 'en_US', 'facebook',null, new Map<String, String>{'language' => 'en_US'});
        User newUser = handler.createUser(null, sampleData);
    }
}