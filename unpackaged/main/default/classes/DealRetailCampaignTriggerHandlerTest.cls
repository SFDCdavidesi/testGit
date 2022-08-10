/*********************************************************************************************************************************
@ Class:          DealRetailCampaignTriggerHandlerTest
@ Version:        1.0
@ Author:         SRONG TIN (srong.tin@gaea-sys.com)
@ Purpose:        Handler Class for DealRetailCampaign Trigger
@ Change history: 02.July.2021 / SRONG TIN / Created the class.
*********************************************************************************************************************************/
@isTest
public class DealRetailCampaignTriggerHandlerTest {
    public static final String NA_Unsub_Deal = 'Deal_V3';
    public static final String DRC_Deal_WINDOW = 'Deal_Campaign_V2';
    public static final String DRC_Deal_WINDOW_CAMPAIGN = 'Deal_Campaign_V3';
    public static Id accId;
    @testSetup static void setup(){
        //DealRetailCampaignTriggerHandler.updateDealStatusByTimeBaseChange();
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        Id dealRecordTypeId =  ApexUtil.getRecordTypeByName('EBH_Deal__c', NA_Unsub_Deal).Id;
        Id drcRecordTypeId = ApexUtil.getRecordTypeByName('EBH_DealRetailCampaign__c', DRC_Deal_WINDOW).Id;
        Account acc = new Account(Name='Test se2',RecordTypeID = sellerRecordType.Id,NA_Deals_Subsidy_PayPal_Email__c='test@test.com',NA_Deal_Program_Vetted__c = true);
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

        List<EBH_DealRetailCampaign__c> lstDW = new List<EBH_DealRetailCampaign__c>();
        EBH_DealRetailCampaign__c drc = new EBH_DealRetailCampaign__c(
            EBH_Country__c = '0',
            RecordTypeId = drcRecordTypeId,
            Status__c = 'Draft',
            EBH_DealTitle__c = 'SRO Test 001',
            Start_Retail_Week__c='2',
            EBH_Date__c = startDate,
            EPH_EndDate__c=endDate,
            End_Retail_Week__c = '5',
            EBH_Slots__c=3);

        lstDW.add(drc);

        for(Integer i=0;i<5;i++){
            EBH_DealRetailCampaign__c dw = new EBH_DealRetailCampaign__c(
                                                                            RecordTypeId = drcRecordTypeId,
                                                                            Status__c = 'Draft',
                                                                            EBH_DealTitle__c = 'SCH Test 00'+i,
                                                                            Start_Retail_Week__c='2',
                                                                            EBH_Date__c = System.today().addDays(1),
                                                                            EPH_EndDate__c=System.today().addDays(6),
                                                                            End_Retail_Week__c = '5',
                                                                            EBH_Slots__c=3
                                                                        );
                                                                                                            
            lstDW.add(dw);
        }
        insert lstDW;

        List<EBH_Deal__c> deals = new List<EBH_Deal__c>();
        for(Integer i=0;i<=9;i++){
            EBH_Deal__c d1 = new EBH_Deal__c(RecordTypeId = dealRecordTypeId, 
                                             EBH_SellerPrice__c = 1000,
                                             EBH_DealPrice__c = 11,
                                             EBH_BusinessName__c = acc.Id,
                                             EBH_SoldItems__c = 2,
                                             EBH_Vertical__c = 'CSA',
                                             EBH_DealStartDate__c = System.today(),
                                             EBH_DealEndDate__c = System.today().addDays(1),
                                             EBH_Status__c = 'Ops Review',
                                             EBH_Category__c = 'Gold',
                                             EBH_ProductTitle__c = 'product'+i,
                                             EBH_SellerEmail__c = 'sales@test.com'+i,
                                             EBH_Quantity__c = 1,
                                             EBH_DealStartTime__c = myTime,
                                             EBH_DealEndTime__c = myTime,
                                             EBH_DealFormat__c = 'Deal',
                                             EBH_eBayItemID__c = '12345678911'+i,
                                             EBH_DealSiteId__c='77',
                                             EBH_DealRetailCampaign__c = drc.Id,
                                             Seller_Contact__c = contact1.Id);
                                             
            deals.add(d1);
        }

        insert deals;
    }   
    // 2 Days at 18:00:00 PST before Deal Window Start Date:
    @isTest
    static void updateDealStatusCM_Review(){
        Test.startTest();
        EBH_DealRetailCampaign__c drc = [SELECT Id,Status__c,EBH_Date__c FROM EBH_DealRetailCampaign__c WHERE EBH_DealTitle__c = 'SRO Test 001'];
        drc.Status__c = 'CM Review';  
        update drc; 
        Test.stopTest();
        String drcId = drc.Id;
        List<EBH_Deal__c> lstDeals = [SELECT Id,EBH_Status__c FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c = :drcId ];
        if(!lstDeals.isEmpty()){
            System.assertEquals(lstDeals[0].EBH_Status__c, drc.Status__c);
        }
    }
    // When 1 Day at 18:00:00 PST before Deal Window Start Date:
    @isTest
    static void updateDealStatusScheduled(){
        Test.startTest();
        EBH_DealRetailCampaign__c drc = [SELECT Id,Status__c,EBH_Date__c FROM EBH_DealRetailCampaign__c WHERE EBH_DealTitle__c = 'SRO Test 001'];
        String drcId = drc.Id;
        List<EBH_Deal__c> lstDeals = [SELECT Id,EBH_Status__c FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c = :drcId ];
        for(EBH_Deal__c deal:lstDeals){
            deal.EBH_Status__c = 'CM Review';
        }
        update lstDeals;
        drc.Status__c = 'Scheduled';  
        update drc; 

        Test.stopTest();
        
        lstDeals = [SELECT Id,EBH_Status__c FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c = :drcId ];
        if(!lstDeals.isEmpty()){
            System.assertEquals(lstDeals[0].EBH_Status__c, drc.Status__c);
        }
    }
    // When Deal Window Start Date is reached:
    @isTest
    static void updateDealStatusRunning(){
        Test.startTest();
        EBH_DealRetailCampaign__c drc = [SELECT Id,Status__c,EBH_Date__c FROM EBH_DealRetailCampaign__c WHERE EBH_DealTitle__c = 'SRO Test 001'];
        String drcId = drc.Id;
        List<EBH_Deal__c> lstDeals = [SELECT Id,EBH_Status__c FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c = :drcId ];
        for(EBH_Deal__c deal:lstDeals){
            deal.EBH_Status__c = 'Scheduled';
        }
        update lstDeals;
        drc.Status__c = 'Running';  
        update drc; 
        Test.stopTest();
        lstDeals = [SELECT Id,EBH_Status__c FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c = :drcId ];
        if(!lstDeals.isEmpty()){
            System.assertEquals(lstDeals[0].EBH_Status__c, drc.Status__c);
        }
    }
    // When Deal Window Start Date is reached:
    @isTest
    static void updateDealStatusCompleted(){
      
        Test.startTest();
        EBH_DealRetailCampaign__c drc = [SELECT Id,Status__c,EBH_Date__c FROM EBH_DealRetailCampaign__c WHERE EBH_DealTitle__c = 'SRO Test 001'];
        String drcId = drc.Id;
        List<EBH_Deal__c> lstDeals = [SELECT Id,EBH_Status__c FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c = :drcId ];
        for(EBH_Deal__c deal:lstDeals){
            deal.EBH_Status__c = 'Running';
        }
        update lstDeals;
        drc.Status__c = 'Completed';  
        update drc; 
        Test.stopTest();
        lstDeals = [SELECT Id,EBH_Status__c FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c = :drcId ];
        if(!lstDeals.isEmpty()){
            System.assertEquals(lstDeals[0].EBH_Status__c, drc.Status__c);
        }
    }

    // When Deal Window changed status to Schedule
    @isTest
    static void test_SendEmailToDealSellerContact() {

        
        EBH_DealRetailCampaign__c drc = [SELECT Id,Status__c,EBH_Date__c FROM EBH_DealRetailCampaign__c WHERE EBH_DealTitle__c = 'SRO Test 001'];
        
        Test.startTest();
            drc.Status__c = 'Scheduled';  
            update drc; 
        Test.stopTest();

    }
    //SCH-09092021-ebay-345
    @isTest
    static void test_InsertUpdateDeleteDealRetailCampaign(){
        Id dwcRecordTypeId = ApexUtil.getRecordTypeByName('EBH_DealRetailCampaign__c', DRC_Deal_WINDOW_CAMPAIGN).Id;
        List<EBH_DealRetailCampaign__c> lstDWC = new List<EBH_DealRetailCampaign__c>(); 
        for(Integer i=0;i<2;i++){
            EBH_DealRetailCampaign__c dw = new EBH_DealRetailCampaign__c(
                                                                            RecordTypeId = dwcRecordTypeId,
                                                                            Status__c = 'Draft',
                															EBH_Country__c = '0',
                                                                            EBH_DealTitle__c = 'SCH DWC 00'+i,
                                                                            Start_Retail_Week__c='2',
                                                                            EBH_Date__c = System.today().addDays(1),
                                                                            EPH_EndDate__c=System.today().addDays(4),
                                                                            End_Retail_Week__c = '5',
                                                                            EBH_Slots__c=3
                                                                        );
                                                                                                            
                                                                        lstDWC.add(dw);
        }
        Test.startTest();
        insert lstDWC;
                        SYstem.debug('2');

        List<NA_Deal_Window_Retail_Campaign_Junction__c> listrecfordel = new List<NA_Deal_Window_Retail_Campaign_Junction__c>([Select id from NA_Deal_Window_Retail_Campaign_Junction__c where  Deal_Retail_Campaign__c =:lstDWC[0].Id OR Deal_Retail_Campaign__c =: lstDWC[1].Id]);
        
        
        System.assertEquals(10, listrecfordel.size());
                SYstem.debug('3');

        EBH_DealRetailCampaign__c updateDeal = lstDWC[0];
        updateDeal.EBH_Date__c = System.today().addDays(9);
        updateDeal.EPH_EndDate__c = System.today().addDays(10);
        DealRetailCampaignTriggerHandler.isFDRCHandler = false;
        SYstem.debug('4');
        update updateDeal;
        
        
        listrecfordel = new List<NA_Deal_Window_Retail_Campaign_Junction__c>([Select id from NA_Deal_Window_Retail_Campaign_Junction__c where  Deal_Retail_Campaign__c =:lstDWC[0].Id OR Deal_Retail_Campaign__c =: lstDWC[1].Id]);
        System.assertEquals('Total DWC:5', 'Total DWC:'+listrecfordel.size());

        DealRetailCampaignTriggerHandler.isFDRCHandler = false;
                        SYstem.debug('5');


        Test.stopTest();
        //System.debug('>>>>>>>>>>> lstDW:'+ ([SELECT Id FROM EBH_DealRetailCampaign__c WHERE RecordTypeId =: dwcRecordTypeId]).size());
        
    }

    @isTest
    static void test_DeleteDealRetailCampaign(){
        Id dwcRecordTypeId = ApexUtil.getRecordTypeByName('EBH_DealRetailCampaign__c', DRC_Deal_WINDOW_CAMPAIGN).Id;
        List<EBH_DealRetailCampaign__c> lstDWC = new List<EBH_DealRetailCampaign__c>(); 
        for(Integer i=0;i<2;i++){
            EBH_DealRetailCampaign__c dw = new EBH_DealRetailCampaign__c(
                                                                            RecordTypeId = dwcRecordTypeId,
                                                                            Status__c = 'Draft',
                															EBH_Country__c = '0',
                                                                            EBH_DealTitle__c = 'SCH DWC 00'+i,
                                                                            Start_Retail_Week__c='2',
                                                                            EBH_Date__c = System.today().addDays(1),
                                                                            EPH_EndDate__c=System.today().addDays(4),
                                                                            End_Retail_Week__c = '5',
                                                                            EBH_Slots__c=3
                                                                        );
                                                                                                            
                                                                        lstDWC.add(dw);
        }

        Test.startTest();
        
            insert lstDWC;
		DealRetailCampaignTriggerHandler.isFDRCHandler = false;

        Test.stopTest();
        delete lstDWC;

        //System.debug('>>>>>>>>>>> lstDW:'+ ([SELECT Id FROM EBH_DealRetailCampaign__c WHERE RecordTypeId =: dwcRecordTypeId]).size());
        
    }
    //Sambath Seng 25/4/2022 US-0011625 - Bugs/issues and user feedback
    @isTest
    static void testSetStartAndEndTimeDE(){
        Time defaultStartTimeDE = Time.newInstance(9, 0, 0, 0);
        Time defaultEndTimeDE = Time.newInstance(8, 59, 0, 0);
        Id dwcRecordTypeId = ApexUtil.getRecordTypeByName('EBH_DealRetailCampaign__c', DRC_Deal_WINDOW_CAMPAIGN).Id;
        EBH_DealRetailCampaign__c drc = new EBH_DealRetailCampaign__c(
            RecordTypeId = dwcRecordTypeId,
            Status__c = 'Draft',
            EBH_Country__c = '77',
            EBH_DealTitle__c = 'DRC TEST RECORD',
            Start_Retail_Week__c='2',
            EBH_Date__c = System.today().addDays(1),
            EPH_EndDate__c=System.today().addDays(4),
            End_Retail_Week__c = '5',
            EBH_Slots__c=3
        );
        Test.startTest();
            insert drc;
            list<EBH_DealRetailCampaign__c> lstDW = [SELECT Id, Start_Time__c, End_Time__c FROM EBH_DealRetailCampaign__c WHERE Id =: drc.Id];
            System.assertEquals(defaultStartTimeDE, lstDW[0].Start_Time__c);
        	System.assertEquals(defaultEndTimeDE, lstDW[0].End_Time__c);
        Test.stopTest();        
    }
}