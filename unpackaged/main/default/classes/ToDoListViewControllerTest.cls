@isTest
private without sharing class ToDoListViewControllerTest {
    
    private static List<EBH_Deal__c> deals = new List<EBH_Deal__c>();
    private static Deal_Statement_Setting__c setting = new Deal_Statement_Setting__c();
     @testSetup
    static void setup(){
    	setting.Initial_Payout__c=0.60;
    	setting.Amount_Held_Back__c=0.40;
    	setting.Deal_Statement_Owner__c = 'Deals_BU_team';
    	insert setting;
        Account acc = new Account(Name='Test Account Name: 1', BillingCountry='CH');
        insert acc;
        Account eBaySeller1 = new Account (Name='Trigg Digital Ltd',EBH_OracleID__c='12345', NA_Deal_Program_Vetted__c = true, NA_Deals_Subsidy_PayPal_Email__c = 'test@test.com.invalid');
        Account eBaySeller2 = new Account (Name='Test eBaySeller For Doc Approve 2',EBH_OracleID__c='12346', NA_Deal_Program_Vetted__c = true, NA_Deals_Subsidy_PayPal_Email__c = 'test@test.com.invalid');
        Account eBaySeller3 = new Account (Name='Test eBaySeller For Doc Approve 3',EBH_OracleID__c='12347', NA_Deal_Program_Vetted__c = true, NA_Deals_Subsidy_PayPal_Email__c = 'test@test.com.invalid');
        insert new List<Account>{eBaySeller1,eBaySeller2,eBaySeller3};
        Contact contact1 = new Contact(MailingCountry='USA',MailingState='TX',MailingCity='Dallas',
                                      FirstName='firstname',Salutation='Mr.',LastName='test1',
                                      email='test1@test.com' , AccountId = eBaySeller1.Id, Contact_Role__c='Deals');
        Contact contact2 = new Contact(MailingCountry='USA',MailingState='TX',MailingCity='Dallas',
                                      FirstName='firstname',Salutation='Mr.',LastName='test2',
                                      email='test2@test.com' , AccountId = eBaySeller2.Id);
        insert new List<Contact>{contact1,contact2};
        Deal_Timezone__c dealTimezone = new Deal_Timezone__c();
        dealTimezone.TimeZone__c='America/Los_Angeles';     
        insert dealTimezone;
        EBH_SpotlightCategory__c spotCat = new EBH_SpotlightCategory__c(Name = 'test spotLightCat',EBH_Country__c='NA',EBH_SpotlightCategoryID__c='testSpotId');
        insert spotCat;
        Id devRecordTypeId = ApexUtil.getRecordTypeByName('EBH_Deal__c','Deal_V2').Id;
        Deal_Contract_Agreement__c ndca = new Deal_Contract_Agreement__c();
        insert ndca;
        Time t = System.now().time();
        Date myDate = System.Today();
        integer i=0;
        Time startTime = t.addHours(2);
        Time endTime = t.addHours(3);
        deals = new List<EBH_Deal__c>();
            EBH_Deal__c d1 = new EBH_Deal__c(
            EBH_eBayItemID__c = '00000000001'+i++, 
            Seller_Approver_1__c = contact1.Id,
            EBH_BusinessName__c=eBaySeller1.ID,
            EBH_SpotlightCategory__c = spotCat.Id,
            RecordTypeId=devRecordTypeId,
            EBH_SellerPrice__c=20,
            EBH_Quantity__c=2,
            EBH_SoldItems__c=2,
            Final_Sold_Items__c=5,
            EBH_DealPrice__c =10,
            EBH_DealStartDate__c=myDate,
            EBH_DealStartTime__c =  startTime,
            EBH_DealEndDate__c=myDate,
            EBH_DealEndTime__c = endTime,
            EBH_Status__c='Running',
            EBH_Vertical__c = 'Home & Garden',EBH_Category__c='Home & Garden',
            Sub_Category__c='Bedding', EBH_ProductTitle__c='product 1',
            EBH_SellerEmail__c='sales@test.com',Deal_Contract_Agreement__c = ndca.id);

            deals.add( d1);
            
            EBH_Deal__c d2 = new EBH_Deal__c(
            EBH_eBayItemID__c = '00000000001'+i++, 
            Seller_Approver_1__c = contact1.Id,
            EBH_BusinessName__c=eBaySeller2.ID,
            EBH_SpotlightCategory__c = spotCat.Id,
            RecordTypeId=devRecordTypeId,
            EBH_SellerPrice__c=20,
            EBH_Quantity__c=5,
            EBH_DealPrice__c =10,
            EBH_DealStartDate__c=myDate,
            EBH_DealStartTime__c =  startTime,
            EBH_DealEndDate__c=myDate,
            EBH_DealEndTime__c = startTime,           
            EBH_SoldItems__c=5,
            Final_Sold_Items__c=5,
            EBH_Status__c='Running',
            EBH_Vertical__c = 'Home & Garden',EBH_Category__c='Home & Garden',
            Sub_Category__c='Bedding', EBH_ProductTitle__c='product 1',
            EBH_SellerEmail__c='sales@test.com',Deal_Contract_Agreement__c = ndca.id);
            deals.add( d2);
            
            EBH_Deal__c d3 = new EBH_Deal__c(
            EBH_eBayItemID__c = '00000000001'+i, 
            Seller_Approver_1__c = contact1.Id,
            EBH_BusinessName__c=eBaySeller3.ID,
            EBH_SpotlightCategory__c = spotCat.Id,
            RecordTypeId=devRecordTypeId,
            EBH_SellerPrice__c=20,
            EBH_Quantity__c=5,         
            EBH_SoldItems__c=5,
            Final_Sold_Items__c=5,
            EBH_DealStartDate__c=myDate,
            EBH_DealPrice__c =5,
            EBH_DealStartTime__c =  startTime,
            EBH_DealEndDate__c=myDate,
            EBH_DealEndTime__c = startTime,
            EBH_Status__c='Running',
            EBH_Vertical__c = 'Home & Garden',EBH_Category__c='Home & Garden',
            Sub_Category__c='Bedding', EBH_ProductTitle__c='product 1',
            EBH_SellerEmail__c='sales@test.com',Deal_Contract_Agreement__c = ndca.id);     
            deals.add( d3);
            
            EBH_Deal__c d4 = new EBH_Deal__c(
            EBH_eBayItemID__c = '00000000002'+i, 
            Seller_Approver_1__c = contact1.Id,
            EBH_BusinessName__c=eBaySeller3.ID,
            EBH_SpotlightCategory__c = spotCat.Id,
            RecordTypeId=devRecordTypeId,
            EBH_SellerPrice__c=1000,
            EBH_Quantity__c=5,         
            EBH_SoldItems__c=5,
            Final_Sold_Items__c=5,
            EBH_DealStartDate__c=myDate,
            EBH_DealPrice__c =11,
            EBH_DealStartTime__c =  startTime,
            EBH_DealEndDate__c=myDate,
            EBH_DealEndTime__c = startTime,
            EBH_Status__c='Running',
            EBH_Vertical__c = 'Home & Garden',EBH_Category__c='Home & Garden',
            Sub_Category__c='Bedding', EBH_ProductTitle__c='product 1',
            EBH_SellerEmail__c='sales@test.com',Deal_Contract_Agreement__c = ndca.id);
            deals.add(d4);

            EBH_Deal__c d5 = new EBH_Deal__c(
            EBH_eBayItemID__c = '00000000003'+i, 
            Seller_Approver_1__c = contact1.Id,
            EBH_BusinessName__c=eBaySeller1.ID,
            EBH_SpotlightCategory__c = spotCat.Id,
            RecordTypeId=devRecordTypeId,
            EBH_SellerPrice__c=1000,
            EBH_Quantity__c=5,         
            EBH_SoldItems__c=5,
            Final_Sold_Items__c=5,
            EBH_DealStartDate__c=myDate,
            EBH_DealPrice__c =11,
            EBH_DealStartTime__c =  startTime,
            EBH_DealEndDate__c=myDate,
            EBH_DealEndTime__c = startTime,
            EBH_Status__c='Statement Verified',
            EBH_Vertical__c = 'Home & Garden',EBH_Category__c='Home & Garden',
            Sub_Category__c='Bedding', EBH_ProductTitle__c='product 1',
            EBH_SellerEmail__c='sales@test.com');
            deals.add(d5);

            insert deals;
            
    }
    /*
    @IsTest
    static void testCountDeal(){
        
        Test.startTest();       
        
        String numberLiveDeals = ToDoListViewController.initCountLiveDeals('7');       
        System.assert(Integer.ValueOf(numberLiveDeals) > 0);

        String numberScheduledDeals = ToDoListViewController.initCountScheduledDeals('7');       
        System.assert(Integer.ValueOf(numberScheduledDeals) == 0);

        String numberCancelledDeals = ToDoListViewController.initCountCancelledDeals('7');       
        System.assert(Integer.ValueOf(numberCancelledDeals) == 0);
        
        
        Test.stopTest();
        
    }
    */
    @IsTest
    static void testCheckHasPermission(){
        
        Test.startTest();

        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name = 'DE - Seller Portal'];     
        
        Contact con = [SELECT Id,Email FROM Contact WHERE email='test1@test.com' limit 1];
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
        insert user1;

        
        System.runAs(user1){
            boolean hasPerm = ToDoListViewController.hasPermission();
            System.assertEquals(false, hasPerm,'no ps assigned yet');
        }
        PermissionSet[] psDE = [Select Id from PermissionSet Where Name='DE_Seller_Portal_Deals'];
        if(!psDE.isEmpty())
        {
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId=psDE[0].Id,AssigneeId=user1.Id);
            insert psa;
          

            System.runAs(user1){
                boolean hasPerm = ToDoListViewController.hasPermission();
                System.assertEquals(true, hasPerm,'ps assigned');
            }
        }
       


        Test.stopTest();
        
    }

    @isTest
    static void test_fetchToDoListMetadata() {

        Test.startTest();

            List<ToDoListViewController.ToDoListWrapper> result = ToDoListViewController.fetchToDoListMetadata('ToDoList');
            System.assert(!result.isEmpty(), 'There should be To-do list notification display on screen.');

        Test.stopTest();
    }
}