/*********************************************************************************************************************************
@ Class:          SEP_CustomTabControllerTest
@ Version:        1.0
@ Author:         Sambath Seng
@ Purpose:        US-0010743 - [SP - Seller Portal] [Bug] Fix how results are displayed on Global Search
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 2.12.2021 / Sambath Seng / Created test class for SEP_CustomTabController.
*********************************************************************************************************************************/
@isTest
public with sharing class SEP_CustomTabControllerTest {
    @isTest
    static void testGetGlobalSearchTabs() {
        Account eBaySeller = new Account (Name='Testing',EBH_OracleID__c='12345');
        insert eBaySeller;
        Contact contact = new Contact(MailingCountry='USA',
                                    MailingState='Test', 
                                    MailingCity='Test',
                                    FirstName='Test',
                                    Salutation='Mr.',
                                    LastName='Test',
                                    email='test1@test.com',
                                    AccountId = eBaySeller.Id
                                    );
        insert contact;
        EBH_SpotlightCategory__c spotCat = new EBH_SpotlightCategory__c(Name = 'test spotLightCat',EBH_Country__c='NA',EBH_SpotlightCategoryID__c='testSpotId');
        insert spotCat;
        Id devRecordTypeId = ApexUtil.getRecordTypeByName('EBH_Deal__c','Deal_V2').Id;
        Deal_Contract_Agreement__c ndca = new Deal_Contract_Agreement__c();
        insert ndca;
        EBH_Deal__c deal = new EBH_Deal__c(
            EBH_eBayItemID__c = '000000000012', 
            Seller_Approver_1__c = contact.Id,
            EBH_BusinessName__c = eBaySeller.Id,
            EBH_SpotlightCategory__c = spotCat.Id,
            RecordTypeId = devRecordTypeId,
            EBH_SellerPrice__c = 20,
            EBH_Quantity__c = 2,
            EBH_SoldItems__c = 2,
            Final_Sold_Items__c = 5,
            EBH_DealPrice__c = 10,
            EBH_DealStartDate__c = System.Today(),
            EBH_DealStartTime__c = System.now().time().addHours(2),
            EBH_DealEndDate__c = System.Today(),
            EBH_DealEndTime__c = System.now().time().addHours(3),
            EBH_Status__c = 'Running',
            EBH_Vertical__c = 'Home & Garden',EBH_Category__c='Home & Garden',
            Sub_Category__c = 'Bedding', EBH_ProductTitle__c='product test 1'
        );
        insert deal;
        Map<String, SEP_CustomTabController.TabWrapper> result = new Map<String, SEP_CustomTabController.TabWrapper>();
        // Actual test
        Test.startTest();
            result = SEP_CustomTabController.getGlobalSearchTabs('test 1');
        Test.stopTest();
        // Asserts
        System.assertEquals('EBH_Deal__c', result.get('EBH_Deal__c').objectApi);
        System.assertEquals('Deal_Search_Result', result.get('EBH_Deal__c').developerName);
        System.assertEquals(1, result.get('EBH_Deal__c').recordCount);
        System.assertEquals('EBH_DealRetailCampaign__c', result.get('EBH_DealRetailCampaign__c').objectApi);
        System.assertEquals('Deal_Retail_Campaign_Search_Result', result.get('EBH_DealRetailCampaign__c').developerName);
        System.assertEquals(0, result.get('EBH_DealRetailCampaign__c').recordCount);
    }
}