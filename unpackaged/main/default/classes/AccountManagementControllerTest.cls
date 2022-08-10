/*********************************************************************************************************************************
@ Class:          AccountManagementControllerTest
@ Version:        1.0
@ Author:         Sochettra Saing
@ Purpose:        Ability to run test the logic in class AccountManagementController(EBAY-749)
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 22.10.2021 / Sochettra Saing / Created the class.
*********************************************************************************************************************************/

@isTest 
public with sharing class AccountManagementControllerTest {
    @testSetup
    static void setup(){
        //create an account
        Account acc = new Account( Name = 'TestAccount', EBH_StoreSubscription__c = 'Anchor');//Basic
        insert acc;
        Account acc2 = new Account( Name = 'TestAccount2', EBH_StoreSubscription__c = 'Anchor');//Basic
        insert acc2;

        //create a contact
        Contact con = new Contact(Accepted_Current_Deals_Agreement__c=false,
                                    FirstName='test fn', LastName='test ln', AccountId=acc.Id, Email = 'test123@test.com');
        insert con;

        //create Custom Setting record for EBH_ActiveTriggers__c
        insert new EBH_ActiveTriggers__c(Name = 'EBH Trigger Controller', Subscription_Request_Trigger__c = false);

        Profile adminProfile = [select Id,Name from Profile where Name = 'System Administrator'];
        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name = 'DE - Seller Portal'];

        User adminUser = new User();
        adminUser.Alias='admin';
        adminUser.Email='admintest@ebay.com';
        adminUser.EmailEncodingKey='UTF-8';
        adminUser.LastName='AdminUser';
        adminUser.LanguageLocaleKey='en_US';
        adminUser.LocaleSidKey='en_US';
        adminUser.ProfileId = adminProfile.Id;
        adminUser.TimeZoneSidKey='America/Los_Angeles';
        adminUser.UserName='adminprofile@ebay.com';
        
        User currentUser = [Select Id,Name from User where Id=: UserInfo.getUserId()];
        
        User user1 = new User(
                                Username = System.now().millisecond() + 'test12345@test.com',
                                ContactId = con.Id,
                                ProfileId = profile1.Id,
                                Alias = 'testU',
                                Email = 'test12345xx@test.com',
                                EmailEncodingKey = 'UTF-8',
                                LastName = 'McTesty',
                                CommunityNickname = 'test12345',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'de_DE',
                                LanguageLocaleKey = 'de'
                                );
        System.runAs(currentUser) {
            insert new List<User>{adminUser,user1};
        }
    }

    @IsTest
    static void testMethod1(){

        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1];
        Contact con = [SELECT Id,Email FROM Contact WHERE FirstName='test fn' AND LastName='test ln' limit 1];
        /*User user1 = new User(
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
                                );*/
        User user1 = [SELECT Id,name From User WHERE Alias='testU' limit 1];
        
        Test.startTest(); 

        System.runAs(user1) {
            Account acc1 = AccountManagementController.getStoreSubscription();
            System.assertEquals('Store Subscription Level:Anchor','Store Subscription Level:'+ acc1.EBH_StoreSubscription__c);
            Account accName = AccountManagementController.getAccountName();
            System.assertEquals('Account Name:TestAccount','Account Name:'+ accName.Name);

            Map<String,Object> mapResult1 =  AccountManagementController.getSellerInfo();

            Map<String,Object> mapResult2 = AccountManagementController.createSubscription();
            Subscription_Request__c[] srequest = [Select Id from Subscription_Request__c];
            System.assert(!srequest.isEmpty(),'subscription request created');
        }
        Test.stopTest();
    }

    @IsTest
    static void testMethod2(){

        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1];

        //Create Active Initial Cohort Seller
        BoB__c bob = new BoB__c(Status__c='Draft',EBH_BOBCNTRY__c='3',EBH_BOBVertical__c='Fashion',Managed_Type__c ='Others Managed');
        insert bob;
        RecordType bobSellerRecordTypeManaged = ApexUtil.getRecordTypeByName('BoB_Seller__c','Managed');
        BoB_Seller__c bs = new BoB_Seller__c(
            RecordTypeId = bobSellerRecordTypeManaged.Id,
            Account_Manager__c = UserInfo.getUserId(),
            Status__c = 'New',
            Seller__c = acc.Id,
            BoB__c = bob.Id,
            EBH_BOBSegment__c = 'MSO',
            BoB_Subsegment__c = 'Platin'
        );

        insert new List<BoB_Seller__c>{bs};  
        bob.Status__c = 'BoB Active';
        update bob;

        List<Subscription_Request__c> srequest = new List<Subscription_Request__c>();
        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name = 'DE - Seller Portal'];

        Contact con = [SELECT Id,Email FROM Contact WHERE FirstName='test fn' AND LastName='test ln' limit 1];
        User admin = [SELECT Id,name From User WHERE Alias='admin' limit 1];
       	User user1 = [SELECT Id,name From User WHERE Alias='testU' limit 1];
        Test.startTest(); 

        System.runAs(user1) {
            Account acc1 = AccountManagementController.getStoreSubscription();
            System.assertEquals('Store Subscription Level:Anchor','Store Subscription Level:'+ acc1.EBH_StoreSubscription__c);
            Account accName = AccountManagementController.getAccountName();
            System.assertEquals('Account Name:TestAccount','Account Name:'+ accName.Name);

            Map<String,Object> mapResult1 =  AccountManagementController.getSellerInfo();

            Map<String,Object> mapResult2 = AccountManagementController.createSubscription();
            srequest = [Select Id, Seller__c from Subscription_Request__c];
            System.assert(!srequest.isEmpty(),'subscription request created');

        }
        System.runAs(admin) {

            for (Subscription_Request__c sr : srequest) { sr.Initial_Cohort_Seller__c = bs.Id; }
    
            update srequest;
        }
        System.runAs(user1) {
            Map<String,Object> mapResult1 =  AccountManagementController.getActiveCohortSeller();

            User usr = (User) mapResult1.get('accountMgmtInfo');

            System.assert( usr != null && usr.Id != null, 'There is an Account Manager');
        }

        Test.stopTest();
        
    }

    @IsTest
    static void testMethod3(){

        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1];

        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name = 'DE - Seller Portal'];

        Contact con = [SELECT Id,Email FROM Contact WHERE FirstName='test fn' AND LastName='test ln' limit 1];
        List<Subscription_Request__c> srequest = new List<Subscription_Request__c>();
        
        User admin = [SELECT Id,name From User WHERE Alias='admin' limit 1];
        User user1 = [SELECT Id,name From User WHERE Alias='testU' limit 1];
        
        Test.startTest(); 

        System.runAs(user1) {
            Account acc1 = AccountManagementController.getStoreSubscription();
            System.assertEquals('Store Subscription Level:Anchor','Store Subscription Level:'+ acc1.EBH_StoreSubscription__c);
            Account accName = AccountManagementController.getAccountName();
            System.assertEquals('Account Name:TestAccount','Account Name:'+ accName.Name);

            Map<String,Object> mapResult1 =  AccountManagementController.getSellerInfo();

            Map<String,Object> mapResult2 = AccountManagementController.createSubscription();
            srequest = [Select Id,Seller__c,Status__c from Subscription_Request__c];
        }
        System.runAs(admin) {
        
            for (Subscription_Request__c sr : srequest) { sr.Status__c = 'Subscribed';} 
            update srequest;
        }
        System.runAs(user1) {
            Map<String,Object> mapResult1 =  AccountManagementController.requestUnsubscription();
             
            Subscription_Request__c[] srequest1 = [Select Id,Status__c from Subscription_Request__c];
            System.assert(!srequest1.isEmpty(),'Unsubscribe Request');
        }
        
        Test.stopTest();
    }

   
}