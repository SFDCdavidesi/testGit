@isTest
public with sharing class BatchDeactivateIneligiblePortalUsersTest {

    @TestSetup
    static void makeData(){
        User[] admins = [Select Id From User WHERE Profile.Name ='System Administrator' AND IsActive=TRUE LIMIT 2];
        RecordType recSeller = ApexUtil.getRecordTypeByName('Account', 'EBH_Seller');

        Account portalAccount1, portalAccount2,portalAccount3;
        Contact contact1,contact2,contact3;
        System.runAs(admins[0])
        {
            //Create account
            portalAccount1 = new Account(
                EBH_OracleId__c='1003293591',
                Name='Test Acc1',
                Risk_tier_manual__c=1,
                RecordTypeID = recSeller.Id,
                EBH_RevRollup__c='US',
                EBH_DealsProgram__c ='Accepted',
                EBH_VeROViolation__c = true,
                EBH_PredictedStandard__c = 'Above Standard',
                EBH_GMVLast12Months__c= 48000,
                EBH_ActualStandard__c='Below Standard',
                EBH_LastSellDate__c= Date.today().addDays(-89)
            );

            portalAccount2 = new Account(
                EBH_OracleId__c='1004444444',
                Name='Test Acc2',
                Risk_tier_manual__c=1,
                RecordTypeID = recSeller.Id,
                EBH_RevRollup__c='US',
                EBH_DealsProgram__c ='Accepted',
                EBH_VeROViolation__c =false,
                EBH_PredictedStandard__c = 'ETRS',
                EBH_GMVLast12Months__c= 58000,
                EBH_ActualStandard__c='Above Stardard',
                EBH_LastSellDate__c= Date.today().addDays(-91)
            );
            portalAccount3 = new Account(
                EBH_OracleId__c='1004444664',
                Name='Test Acc3',
                Risk_tier_manual__c=1,
                RecordTypeID = recSeller.Id,
                EBH_RevRollup__c='US',
                EBH_DealsProgram__c ='Accepted',
                EBH_VeROViolation__c =false,
                EBH_PredictedStandard__c = 'ETRS',
                EBH_GMVLast12Months__c= 58000,
                EBH_ActualStandard__c='Above Stardard',
                Below_SP_Standard_Date__c = Date.today().addDays(-100),
                EBH_LastSellDate__c= Date.today().addDays(-90)
            );
            insert new List<Account>{portalAccount1, portalAccount2, portalAccount3};
            RecordType recSP = ApexUtil.getRecordTypeByName('Contact', 'Seller_Portal');
            RecordType recDWH = ApexUtil.getRecordTypeByName('Contact', 'EBH_DWH');
            contact1 = new Contact(
                FirstName = 'Test1111111111',
                Lastname = 'AMT_TEST',
                AccountId = portalAccount1.Id,
                Email = System.now().millisecond() + 'test1@test.com',
                RecordTypeId=recSP.Id
            );
            contact2 = new Contact(
                FirstName = 'Test',
                Lastname = 'test con2',
                AccountId = portalAccount2.Id,
                Email = System.now().millisecond() + 'test2@test.com',
                RecordTypeId=recDWH.Id
            );
            contact1 = new Contact(
                FirstName = 'Test1111111111',
                Lastname = 'AMT_TEST',
                AccountId = portalAccount1.Id,
                Email = System.now().millisecond() + 'test1@test.com',
                RecordTypeId=recSP.Id
            );
            contact3 = new Contact(
                FirstName = 'Test',
                Lastname = 'test con3',
                AccountId = portalAccount3.Id,
                Email = System.now().millisecond() + 'test3@test.com',
                RecordTypeId=recDWH.Id
            );
            insert new Contact[]{contact1,contact2,contact3};

            AccountContactRelation acr =  new AccountContactRelation(ContactId=contact1.Id,AccountId=portalAccount2.Id,IsActive=True);
            insert acr;
        }
        System.runAs(admins[1])
        {
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'NA - Seller Portal' LIMIT 1];
            Profile portalProfileDE = [SELECT Id FROM Profile WHERE Name = 'DE - Seller Portal' LIMIT 1];
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
                Username = System.now().millisecond() + 'test2@test.com',
                ContactId = contact2.Id,
                ProfileId = portalProfileDE.Id,
                Alias = 'test2',
                Email = 'test2@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test2',
                CommunityNickname = 'test2',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            User user3 = new User(
                Username = System.now().millisecond() + 'test3@test.com',
                ContactId = contact3.Id,
                ProfileId = portalProfileDE.Id,
                Alias = 'test3',
                Email = 'test3@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test3',
                CommunityNickname = 'test3666',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            insert new User[]{user1,user2,user3};
        }   

    }
    static testMethod void testDeactivateIneligiblePortalUsers(){
        Test.startTest();
            Database.executeBatch(new BatchDeactivateIneligiblePortalUsers());
        Test.stopTest();
    }
}