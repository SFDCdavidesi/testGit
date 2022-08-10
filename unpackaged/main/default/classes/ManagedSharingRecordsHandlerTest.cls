/**
 * @Description Test unit for cover code in ManagedSharingRecordsHandler class
 * @date        18/10/2021
 * @ author      Sochettra SAING
 * change :21-12-2021/ Loumang SENG /US-0010824: Depreciated.
 */
@isTest
private class ManagedSharingRecordsHandlerTest {
    
    //LA-17-12-2021:US-0010824 - [SP - EU Deals] Adjust Sharing for Deal Retail Campaign Object
   /* public static final String NA_Unsub_Deal = 'Deal_V3';
    public static final String DRC_Deal_WINDOW = 'Deal_Campaign_V2';
    public static final String DRC_Deal_WINDOW_CAMPAIGN = 'Deal_Campaign_V3';
    public static Id accId;
    @testSetup static void setup(){
        //DealRetailCampaignTriggerHandler.updateDealStatusByTimeBaseChange();
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        //Id dealRecordTypeId =  ApexUtil.getRecordTypeByName('EBH_Deal__c', NA_Unsub_Deal).Id;
        
        Account acc = new Account(Name='TestAccount',RecordTypeID = sellerRecordType.Id,NA_Deals_Subsidy_PayPal_Email__c='test@test.com',NA_Deal_Program_Vetted__c = true);
        insert acc;

        RecordType contactRecordTYpe = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
        Contact contact1 = new Contact(MailingCountry='USA',MailingState='TX',MailingCity='Dallas',
                                        FirstName='firstname',Salutation='Mr.',LastName='test1',
                                        email='test1@test.com' , AccountId = acc.Id, recordtypeId = contactRecordTYpe.Id);
        insert contact1;
        

        EBH_ActiveTriggers__c setting = new EBH_ActiveTriggers__c();
        setting.Name = 'EBH Trigger Controller';
        setting.DealRetailCampaign_Trigger__c = true;
        insert setting;
        Date startDate = System.today().addDays(20);
        Date endDate = System.today().addDays(21);
        DateTime dt = System.today();
        Time myTime = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
        // create defualt spotlight category
        EBH_SpotlightCategory__c sc = new EBH_SpotlightCategory__c();
        sc.Name = Label.US_UnSubDeal_Default_Spotlight;
        sc.EBH_Country__c = 'US';
        sc.EBH_SpotlightCategoryID__c = '123456789012';
        sc.Spotlight_End_Date__c = endDate;
        sc.Spotlight_Start_Date__c = startDate;
        insert sc;
    }

    @isTest static void testFetchRetailCampaign() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1];

        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        //UserRole ur = new UserRole(Name = 'Liny - TEST US Seller Customer User', DeveloperName= 'LinyTESTUSSellerCustomerUser', PortalType = 'CustomerPortal', PortalAccountId = acc.Id);
        //insert ur;
        //UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1]; UserRoleId = userRole.Id,
        /*Account acc = new Account( Name = 'TestAccount' );
        insert acc;

        //create a contact
        Contact con = new Contact(Accepted_Current_Deals_Agreement__c=false,
                                    FirstName='test fn', LastName='test ln', AccountId=acc.Id, Email = 'test123@test.com');
        insert con;  */
        
        /*Contact con = [SELECT Id,Email FROM Contact WHERE FirstName='firstname' AND LastName='test1' limit 1];
        User user1 = new User(
                                Username = System.now().millisecond() + 'test12345@test.com',
                                //ContactId = con.Id,
                                ProfileId = profile1.Id,
                                isActive = true,
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
        Test.startTest(); 
        System.runAs(user1) {
            Id drcRecordTypeId = ApexUtil.getRecordTypeByName('EBH_DealRetailCampaign__c', DRC_Deal_WINDOW).Id;
            List<EBH_DealRetailCampaign__c> lstDW = new List<EBH_DealRetailCampaign__c>();
            
            for(Integer i=0;i<5;i++){
                EBH_DealRetailCampaign__c dw = new EBH_DealRetailCampaign__c(
                                                                                RecordTypeId = drcRecordTypeId,
                                                                                Status__c = 'Draft',
                                                                                EBH_DealTitle__c = 'SCH Test 00'+i,
                                                                                Start_Retail_Week__c='2',
                                                                                EBH_Date__c = System.today().addDays(1),
                                                                                EPH_EndDate__c=System.today().addDays(6),
                                                                                End_Retail_Week__c = '5',
                                                                                EBH_Slots__c=3,
                                                                                EBH_Country__c = '0'
                                                                            );
                                                                                                                
                lstDW.add(dw);
            }
            insert lstDW;

            Set<Id> parentIds = new Set<Id>();
            List<EBH_DealRetailCampaign__c> lstDRC = [SELECT Id, EBH_Country__c FROM EBH_DealRetailCampaign__c WHERE EBH_DealTitle__c LIKE 'SCH Test 00%'];
            for(EBH_DealRetailCampaign__c drcShare : lstDRC) {
                parentIds.add(drcShare.Id);
                //drcShare.EBH_Country__c = '77';
            }
            
            List<EBH_DealRetailCampaign__Share> lstDRCShare = [SELECT Id FROM EBH_DealRetailCampaign__Share WHERE ParentId IN : parentIds]; //new List<EBH_DealRetailCampaign__Share>();
            
            System.assertEquals(5, lstDRCShare.size());

            
        }
        Test.stopTest();
        
    }*/
    //LA-17-12-2021:US-0010824
    static testMethod void testDepreciatedClass(){
        Test.startTest();
        	BatchManagedSharingRecords depreciated = new BatchManagedSharingRecords();
            ManagedSharingRecordsHandler depreciatedMSR = new ManagedSharingRecordsHandler();
        Test.stopTest();

    }
}