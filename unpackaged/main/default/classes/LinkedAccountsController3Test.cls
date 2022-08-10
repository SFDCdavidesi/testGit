@isTest
private class LinkedAccountsController3Test {


    @testSetup
    static void setup(){

        Account eBaySeller1,eBaySeller2;
        Contact contact1,contact2;
        User user1;
        User user2;
        Profile deProfile = ApexUtil.getProfileByName('DE - Seller Portal');
        User[] admins = [Select Id,Name From User Where Profile.Name='System Administrator' AND isActive=TRUE and UserRoleId <> null LIMIT 2];

        System.runAs(admins[0]) {
            eBaySeller1 = new Account (Name='Test eBaySeller For Doc Approve 1',EBH_OracleID__c='12345',NA_Deal_Program_Vetted__c=true);
            eBaySeller2 = new Account (Name='Test eBaySeller For Doc Approve 2',EBH_OracleID__c='12346',NA_Deal_Program_Vetted__c=true);
            insert new List<Account>{eBaySeller1,eBaySeller2};
            contact1 = new Contact(MailingCountry='USA',MailingState='TX',MailingCity='Dallas',
                                          FirstName='firstname',Salutation='Mr.',LastName='test1',
                                            email='test1@test.com' , AccountId = eBaySeller1.Id);
            contact2 = new Contact(MailingCountry='USA',MailingState='TX',MailingCity='Dallas',
                                          FirstName='firstname',Salutation='Mr.',LastName='test2',
                                          email='test2@test.com' , AccountId = eBaySeller2.Id);
            insert new List<Contact>{contact1,contact2};
    
            user1 = new User(
                Username = System.now().millisecond() + 'test_12345@testbb.com',
                ContactId = contact1.Id,
                ProfileId = deProfile.Id,
                Alias = 'test123',
                Email = 'test12345xx@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
                );
    
            user2 = new User(
                Username = System.now().millisecond() + 'test_qq@testqq.com',
                ContactId = contact2.Id,
                ProfileId = deProfile.Id,
                Alias = 'testQ123',
                Email = 'testQ123@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty2',
                CommunityNickname = 'texxst12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
                );
        }

        System.runAs(admins[1]) {   
            insert new User[]{user1,user2};
        }

    }
    
    @isTest
    static void testRemoveLinkedAccountWithNoGroup() {
        // 09.04.2022 / Sophal Noch / US-0010902
        User user1 = [Select id, name, ContactId, Contact.AccountId from User where Alias = 'test123'];
        User user2 = [Select id, name, ContactId, Contact.AccountId from User where Alias = 'testQ123'];
        AccountContactRelation acr2 = new AccountContactRelation(ContactId=user1.ContactId, AccountId=user2.Contact.AccountId);
        insert acr2;
        Test.startTest();
            System.runAs(user1) {
                Map<String,Object> mapResult = LinkedAccountsController3.removeLinkedAccount(acr2.AccountId);
                System.assertEquals(null,mapResult.get('error'));
                System.assertEquals('ok', String.valueOf(mapResult.get('status')));
            }
        Test.stopTest();
    }

    @isTest
    static void testRemoveLinkedAccountWithGroup() {
        // 09.04.2022 / Sophal Noch / US-0010902
        RecordType recAccGroup = ApexUtil.getRecordTypeByName('Account', 'Seller_Portal_Group');
        Account accGroup = new Account (Name='Test Seller Group',EBH_OracleID__c='12347',NA_Deal_Program_Vetted__c=true, RecordTypeId=recAccGroup.Id);
        insert accGroup;
        User user1 = [Select id, name, ContactId, Contact.AccountId from User where Alias = 'test123'];
        User user2 = [Select id, name, ContactId, Contact.AccountId from User where Alias = 'testQ123'];


        Account eBaySeller1 = new Account (Id=user1.Contact.AccountId, Seller_Portal_Group__c = accGroup.Id);
        Account eBaySeller2 = new Account (Id=user2.Contact.AccountId, Seller_Portal_Group__c = accGroup.Id);
        update new List<Account>{eBaySeller1,eBaySeller2};

        RecordType recContGroup = ApexUtil.getRecordTypeByName('Contact', 'Seller_Portal');
        Contact contact1 = new Contact(Id=user1.ContactId, AccountId= accGroup.Id, RecordTypeId=recContGroup.Id);
        Contact contact2 = new Contact(Id=user2.ContactId,  RecordTypeId=recContGroup.Id);
        update new List<Contact>{contact1,contact2};
        
        RecordType reContactDWH = ApexUtil.getRecordTypeByName('Contact', 'EBH_DWH');
        contact1 = [Select Id, FirstName, LastName, Email, MailingCountry, MailingState,MailingCity, Salutation From Contact Where Id =: contact1.Id];
        Contact clonedContact1 = contact1.clone(false, true,false, false);
        clonedContact1.RecordTypeId = reContactDWH.Id;
        clonedContact1.AccountId = eBaySeller1.Id;
        insert clonedContact1;

        Test.startTest();
            AccountContactRelation contact1Acr1 = [Select Id,ContactId, AccountId, IsDirect From AccountContactRelation Where ContactId =:contact1.Id and AccountId=: accGroup.Id];
            System.assertEquals(true, contact1Acr1.IsDirect);
            AccountContactRelation contact1Acr2 = [Select Id,ContactId, AccountId From AccountContactRelation Where ContactId =:contact1.Id and AccountId=: eBaySeller1.Id];
            AccountContactRelation contact1Acr3 = new AccountContactRelation(ContactId=contact1.Id, AccountId = eBaySeller2.Id);
            AccountContactRelation contact2Acr2 = new AccountContactRelation(ContactId=contact2.Id, AccountId = eBaySeller1.Id);
            insert new List<AccountContactRelation>{contact1Acr3, contact2Acr2};

            List<AccountContactRelation> listAcrContact1 = [Select Id, AccountId From AccountContactRelation Where ContactId =: contact1.Id];
            System.assertEquals(3, listAcrContact1.size());

            List<AccountContactRelation> listAcrContact2 = [Select Id, AccountId From AccountContactRelation Where ContactId =: contact2.Id];
            System.assertEquals(2, listAcrContact2.size());

            System.runAs(user1) {
                Map<String,Object> mapResult = LinkedAccountsController3.removeLinkedAccount(contact1Acr2.AccountId);
                System.assertEquals(null,mapResult.get('error'));
                System.assertEquals('ok', String.valueOf(mapResult.get('status')));

            }
            listAcrContact1 = [Select Id, AccountId From AccountContactRelation Where ContactId =: contact1.Id];
            System.assertEquals(2, listAcrContact1.size());
    
            listAcrContact2 = [Select Id, AccountId From AccountContactRelation Where ContactId =: contact2.Id];
            System.assertEquals(1, listAcrContact2.size());

            System.runAs(user1) {
                Map<String,Object> mapResult = LinkedAccountsController3.removeLinkedAccount(contact1Acr3.AccountId);
                System.assertEquals(null,mapResult.get('error'));
                System.assertEquals('ok', String.valueOf(mapResult.get('status')));
            }
            listAcrContact1 = [Select Id, AccountId From AccountContactRelation Where ContactId =: contact1.Id];
            System.assertEquals(2, listAcrContact1.size());

        Test.stopTest();

        


    }
}