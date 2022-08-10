@isTest
private class LinkedAccountsControllerTest {
    

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
                Name = 'AMT_TEST',
                SP_Deals__c = 'Full Access',
                eBay_API_User_Id__c = 'test_test_test',
                RecordTypeId = recSeller.Id
            );

            portalAccount2 = new Account(
                Name = 'test_seller007',
                SP_Deals__c = 'Full Access',
                eBay_API_User_Id__c = 'test_test_test2',
                RecordTypeId = recSeller.Id
            );
            portalAccount3 = new Account(
                Name = 'test_seller008',
                SP_Deals__c = 'Full Access',
                eBay_API_User_Id__c = 'test_test_test3',
                RecordTypeId = recSeller.Id
            );
            insert new List<Account>{portalAccount1, portalAccount2,portalAccount3};
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
                Email = System.now().millisecond() + 'srotest2@test.com',
                RecordTypeId=recDWH.Id
            );
            contact3 = new Contact(
                FirstName = 'Test3',
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
                LanguageLocaleKey = 'en_US',
                Federated_Login__c = false
            );
            User user2 = new User(
                Username = System.now().millisecond() + 'srotest2@test.com',
                ContactId = contact2.Id,
                ProfileId = portalProfileDE.Id,
                Alias = 'test2',
                Email = 'srotest2@test.com',
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
                CommunityNickname = 'test3_sp',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            insert new User[]{user1,user2,user3};
        }   

    }

    @IsTest
    static void test_getAccounts(){
        
        Test.startTest();
        
        User[] userPortals = [Select Id From User Where Email='test12345@test.com'];
        Contact cont1 = [Select Id,FirstName,LastName,Email From Contact Where FirstName='Test1111111111'];
        
        System.runAs(userPortals[0])
        {

            Map<String,Object> mapResult = LinkedAccountsController.getAccounts();
            System.assert(mapResult != null && !mapResult.isEmpty(), 'There should be linked accounts result return.');
            
        }
        
            
        Test.stopTest();
        
    }

    //28/04/2022:vadhanak: US-0011082 - Allow Sellers to link Accounts
    static testMethod void testLinkingAccount()
    {
        User usr1 = [Select Id,Email From User where Email='test12345@test.com'];
        User deUser = [Select Id,Email From User where Email='srotest2@test.com'];
        Account accToLink1 = [Select Id From Account Where eBay_API_User_Id__c = 'test_test_test'];
        Account accToLink2 = [Select Id From Account Where eBay_API_User_Id__c = 'test_test_test2'];
        Account accToLink3 = [Select Id From Account Where eBay_API_User_Id__c = 'test_test_test3'];
        Test.startTest();

            System.runAs(deUser)
            {
                Map<String,Object> mapResultAccList = LinkedAccountsController.getAccounts();
                List<Object> accs = (List<Object>)mapResultAccList.get('accRelation');
                System.assertEquals(1,accs.size(),'1 accounts visible');

                Map<String,Object> sessionResult = LinkedAccountsController.apexGetEbaySessionId();
                
                System.assertEquals('ok', sessionResult.get('status')+'',' result no error');
                System.assert(String.isNotBlank(sessionResult.get('ebaySessionId')+''),'session returns');

                Account accResult = [Select Id,ebay_session_id_tmp__c From Account Where eBay_API_User_Id__c = 'test_test_test2'];
                System.assertEquals(accResult.ebay_session_id_tmp__c, sessionResult.get('ebaySessionId')+'',' sesstion temporarily saved to field');                

                Map<String,Object> confirmIdResult = LinkedAccountsController.apexEbayConfirmIdentity();
                String mainAccId = confirmIdResult.get('mainAccId')+'';

                Map<String,Object> resultCreateGeroup = LinkedAccountsController.apexManageGroup('Group Test999','',mainAccId,accToLink1.Id,'a');
                //system.debug('--resultCreateGeroup: '+resultCreateGeroup);
                String groupId = confirmIdResult.get('mainGroupId')+'';

                // mapResultAccList = LinkedAccountsController.getAccounts();
                // accs = (List<Object>)mapResultAccList.get('accRelation');
                // System.assertEquals(2,accs.size(),'2 accounts visible');


                Map<String,Object>  resultCreateGeroup2 = LinkedAccountsController.apexManageGroup('',groupId,mainAccId,accToLink2.Id,'a');
                					resultCreateGeroup2 = LinkedAccountsController.apexManageGroup('',groupId,mainAccId,accToLink3.Id,'a');
            }
             

        Test.stopTest();
         //User deactivated and disconnected from Portal
         //usr1 = [Select Id,Email,IsActive,ContactId From User where Id=:usr1.Id];
         //System.assertEquals(False,usr1.IsActive,'user deactivated');
    }

    @isTest
    static void testRemoveLinkedAccountWithNoGroup() {
        // 09.04.2022 / Sophal Noch / US-0010902
        User deUser = [Select Id,ContactId, Email From User where Email='srotest2@test.com'];
        Account accToLink1 = [Select Id From Account Where eBay_API_User_Id__c = 'test_test_test'];
        AccountContactRelation acr = new AccountContactRelation(ContactId=deUser.ContactId, AccountId=accToLink1.Id);
        insert acr;
        Test.startTest();
            System.runAs(deUser) {
                Map<String,Object> mapResult = LinkedAccountsController.removeLinkedAccount(accToLink1.Id);
                System.assertEquals(null,mapResult.get('error'));
                System.assertEquals('ok', String.valueOf(mapResult.get('status')));
            }
        Test.stopTest();
    }

    @isTest
    static void testRemoveLinkedAccountWithGroup()
    {
        // 09.04.2022 / Sophal Noch / US-0010902
        User deUser = [Select Id, ContactId,Email From User where Email='srotest2@test.com'];
        Account accToLink1 = [Select Id From Account Where eBay_API_User_Id__c = 'test_test_test'];
        Test.startTest();

            System.runAs(deUser)
            {
                Map<String,Object> sessionResult = LinkedAccountsController.apexGetEbaySessionId();
                
                System.assertEquals('ok', sessionResult.get('status')+'',' result no error');
                System.assert(String.isNotBlank(sessionResult.get('ebaySessionId')+''),'session returns');

                Account accResult = [Select Id,ebay_session_id_tmp__c From Account Where eBay_API_User_Id__c = 'test_test_test2'];
                System.assertEquals(accResult.ebay_session_id_tmp__c, sessionResult.get('ebaySessionId')+'',' sesstion temporarily saved to field');                

                Map<String,Object> confirmIdResult = LinkedAccountsController.apexEbayConfirmIdentity();
                String mainAccId = confirmIdResult.get('mainAccId')+'';

                Map<String,Object> resultCreateGeroup = LinkedAccountsController.apexManageGroup('Group Test999','',mainAccId,accToLink1.Id,'a');

            }


            List<AccountContactRelation> listAcr = [Select Id, AccountId From AccountContactRelation Where ContactId =: deUser.ContactId];
            System.assertEquals(3, listAcr.size());

            System.runAs(deUser) {
                Map<String,Object> mapResult = LinkedAccountsController.removeLinkedAccount(accToLink1.Id);
                System.assertEquals(null,mapResult.get('error'));
                System.assertEquals('ok', String.valueOf(mapResult.get('status')));
            }

            listAcr = [Select Id, AccountId From AccountContactRelation Where ContactId =: deUser.ContactId];
            System.assertEquals(2, listAcr.size());

        Test.stopTest();

    }

}