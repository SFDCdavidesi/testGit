@isTest
public class CustomSEPUserProfileMenuControllerTest {
    @testSetup
    static void setup(){
        //create an account
        Account acc = new Account( Name = 'TestAccount', Trusted_Shop_Discount_Code__c = '12345' );
        insert acc;

        //create a contact
        Contact con = new Contact(Accepted_Current_Deals_Agreement__c=false,
                                    FirstName='test fn', LastName='test ln', AccountId=acc.Id, Email = 'test123@test.com');
        insert con;

        // EBH_TestDataFactory.setUpCustomSettings(); 
		// ActiveValidationRules__c avr = new ActiveValidationRules__c();
		// avr.All_Validation_Rules_Deactivated__c = true;
		// insert avr;

    }

    @IsTest
    static void initUserProfileMenuItems_Test() {

        

        
        
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
        insert user1;

        PermissionSet ps = Database.query('SELECT Id, Name FROM PermissionSet WHERE Name = \'DE_Seller_Portal_Deals\'');
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = user1.Id);
        insert psa;


        System.runAs(user1) {
            Test.startTest();
                Map<String, Object> result = CustomSEPUserProfileMenuController.initUserProfileMenuItems();
                System.assert(!result.isEmpty() && result.containsKey('menuItems') && result.get('menuItems') != null, 'There should be menu items information return.');
            Test.stopTest();
        }
        
    }
}