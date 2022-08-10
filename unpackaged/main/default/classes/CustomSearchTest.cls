/**
 * @description Test unit for coverage code in CustomSearchComponentController
 * @createdDate 21/10/2021
 * @author      Samnang MUONG
 */
@isTest
 private class CustomSearchTest {
    
    @TestSetup
    static void makeData(){

        // create an account
        Account acc1 = new Account(
            RecordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Seller').getRecordTypeId(),
            Name = 'Seller',
            EBH_VATNumber__c = 'VAT1111',
            EBH_RegistrationCountry__c = 'United Kingdom'
        );
        insert acc1;

        // create deals records
        List<EBH_Deal__c> lstDeal = new List<EBH_Deal__c>();
        String stdrecId = Schema.sObjectType.EBH_Deal__c.getRecordTypeInfosByName().get('Standard Deal').getRecordTypeId();

        for(Integer i=0; i<10; i++){
          
            Date ddate = Date.newInstance(Date.today().year(), i, 1);
            lstDeal.add(new EBH_Deal__c(
                RecordTypeId = stdrecId,
                EBH_DealSiteId__c = '3',
                EBH_SellerPrice__c=1000,
                EBH_DealPrice__c=200,
                EBH_SoldItems__c=2,
                EBH_Vertical__c= i<=3 ? 'P&A' : 'Fashion',
                EBH_DealStartDate__c = ddate,
                EBH_DealEndDate__c = ddate.addDays(10),
                EBH_MaximumPurchases__c = 100,
                EBH_Status__c='Running',
                EBH_Category__c='Art',
                EBH_ProductTitle__c='test '+i,
                EBH_SellerEmail__c='sales@test.com',
                EBH_Quantity__c=5,
                EBH_DealFormat__c = 'Primary',
                EBH_BusinessName__c = acc1.Id,
                Subsidy_Running__c = 10,
                EBH_Payout_SI__c = 10
            ));
            
        }
        insert lstDeal;


        // create deal retails campaign
        List<EBH_DealRetailCampaign__c> lstDRC = new List<EBH_DealRetailCampaign__c>();

        String recId = Schema.sObjectType.EBH_DealRetailCampaign__c.getRecordTypeInfosByName().get('Standard Campaign').getRecordTypeId();

        for (Integer i=0; i<10; i++) {
            lstDRC.add(new EBH_DealRetailCampaign__c( RecordTypeId=recId, EBH_Country__c='0', EBH_DealTitle__c='test '+i, EBH_Date__c=system.today(), EPH_EndDate__c=system.today()+1, End_Retail_Week__c='1', Quarter__c='Q1'));
        }

        insert lstDRC;
    }

    @isTest static void test_searchRecords() {

        Test.startTest();

        List<SObject> result = CustomSearchController.searchRecords('test');
        System.assertEquals(10, result.size());

        Test.stopTest();

    }

    @isTest static void test_searchDealRecords() {

        Test.startTest();

        List<SObject> result = CustomSearchController.searchDealRecords('test');
        System.assertEquals(10, result.size());

        Test.stopTest();

    }

    @isTest static void test_searchDealCampaignRecords() {

        Test.startTest();

        List<SObject> result = CustomSearchController.searchDealCampaignRecords('test');
        System.assertEquals(10, result.size());

        Test.stopTest();

    }

    @isTest static void test_mappingSObjectLabel() {

        Test.startTest();

        Map<String, Object> maResult = CustomSearchController.mappingSObjectLabel(new List<String>{'EBH_Deal__c'});

        Test.stopTest();

    }
}