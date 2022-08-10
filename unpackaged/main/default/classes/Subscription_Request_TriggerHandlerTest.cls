@isTest
private class Subscription_Request_TriggerHandlerTest {
     
    @TestSetup
    static void makeData(){
        Test.startTest();

        EBH_TestDataFactory.setUpCustomSettings();

        Account acc = new Account( Name = 'TestAccount', EBH_StoreSubscription__c = 'Anchor');//Basic
        insert acc;

        //create a contact
        Contact con = new Contact(Accepted_Current_Deals_Agreement__c=false,
                                    FirstName='test fn', LastName='test ln', AccountId=acc.Id, Email = 'test123@test.com');
        insert con;

        Test.stopTest();
    }

    @IsTest
    static void testPopulateFields(){
        


        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1];
        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name = 'DE - Seller Portal'];
        Contact con = [SELECT Id,Email FROM Contact WHERE FirstName='test fn' AND LastName='test ln' limit 1];
        RecordType rt_AM = ApexUtil.getRecordTypeByName('Subscription_Request__c', 'Account_Manager');

        Subscription_Request__c s_request = new Subscription_Request__c
        (
            Request_Date__c =  Date.today(),
            Opt_In_Effective_Date__c = Date.today().addMonths(1).toStartOfMonth(),            
            Status__c = 'New',
            Requestor__c = con.Id ,
            Seller__c = acc.Id,
            CurrencyIsoCode = 'EUR',
            RecordTypeId  = rt_AM.Id

        );

        

            insert s_request;

        Test.startTest();
            s_request.Opt_In_Date__c = Date.today().addDays(2);
            update s_request;

            Subscription_Request__c r1 = [Select Id,Earliest_Unsubscribe_Date__c,Opt_In_Effective_Date__c from Subscription_Request__c Where Id=:s_request.Id];
            System.assert(r1.Earliest_Unsubscribe_Date__c <> null ,'Earliest_Unsubscribe_Date__c populated');

            s_request.Status__c = 'Subscribed';
            update s_request;
            r1 = [Select Id,Earliest_Unsubscribe_Date__c,Opt_In_Effective_Date__c from Subscription_Request__c Where Id=:s_request.Id];
            System.assert(r1.Opt_In_Effective_Date__c <> null ,'Opt_In_Effective_Date__c populated');

         
        Test.stopTest();
        
    }
}