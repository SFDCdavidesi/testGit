/**
 * @description Test unit for cover code in lwcAgreementTermsController class
 * @date        21/07/2021
 * @author      Samnang MUONG
 */
@isTest
public without sharing class lwcAgreementTermsTest {
    
    @testSetup
    static void setup(){       

        //create an account
        Account acc = new Account( Name = 'TestAccount' );
        insert acc;

        //create a contact
        Contact con = new Contact(Accepted_Current_Deals_Agreement__c=false,
                                    FirstName='test fn', LastName='test ln', AccountId=acc.Id);
        insert con;
        Profile profile = [SELECT Id FROM Profile WHERE Name ='NA - Seller Portal' Limit 1];
        User user1 = new User(
                                Username = System.now().millisecond() + 'test12345@test.com',
                                ContactId = con.Id,
                                ProfileId = profile.Id,
                                Alias = 'test123',
                                Email = 'test12345xx@test.com',
                                EmailEncodingKey = 'UTF-8',
                                LastName = 'McTesty',
                                CommunityNickname = 'test12345',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US'
                                );
        insert user1;                        
                               

    }
   
    @IsTest
    static void test_InitAgreementTerms(){
        
        Test.startTest();

        User u = [SELECT Id FROM User WHERE Email='test12345xx@test.com'];

        System.runAs(u) {
            lwcAgreementTermsController.initAgreementTerms();
        }

        
        Test.stopTest();
        
    }

    @IsTest
    static void test_acceptedAgreement(){
        EBH_TestDataFactory.setUpCustomSettings();  
        Test.startTest();

        User u = [SELECT Id, ContactId FROM User WHERE Email='test12345xx@test.com'];

        System.runAs(u) {
            
            lwcAgreementTermsController.acceptedAgreement();
        }
        
        Test.stopTest();

    }


}