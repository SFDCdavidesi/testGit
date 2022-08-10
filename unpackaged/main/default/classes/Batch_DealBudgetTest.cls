/************************************************************************************************************************************
@ Class:          Batch_DealBudgetTest
@ Version:        1.0
@ Author:         Acmatac SEING (acmatac.seing@gaea-sys.com)
@ Purpose:        US-0009132 - [EU Deals] Deals Budget & Deal Budget Month Batch Process
--------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 23.04.2021 / Acmatac SEING / Created the test class.
**************************************************************************************************************************************/


@isTest
private class Batch_DealBudgetTest {
    private static Id dealRT_V1 = ApexUtil.getRecordTypeByName('EBH_Deal__c','Deal_V1').Id;
    private static Id accountRT_Seller = ApexUtil.getRecordTypeByName('Account','EBH_Seller').Id;

    @TestSetup
    static void makeData(){

        EBH_DealsBudget__c db1 = new EBH_DealsBudget__c(
            Deal_Site__c='3', 
            EBH_Vertical__c='P&A', 
            EBH_Quarter__c = 'Q1',
            Year__c = String.valueOf(Date.today().year()),
            Non_Payout_Items_Estimate__c = 20
        );
        EBH_DealsBudget__c db2 = new EBH_DealsBudget__c(
            Deal_Site__c = '3', 
            EBH_Vertical__c = 'Fashion', 
            EBH_Quarter__c = 'Q2',
            Year__c = String.valueOf(Date.today().year()),
            Non_Payout_Items_Estimate__c = 10
        );
        insert new List<EBH_DealsBudget__c>{db1,db2};

        Account acc1 = new Account(
            RecordTypeId = accountRT_Seller,
            Name = 'Seller',
            EBH_VATNumber__c = 'VAT1111',
            EBH_RegistrationCountry__c = 'United Kingdom'
        );
        insert acc1;
        
        List<EBH_Deal__c> lstDeal = new List<EBH_Deal__c>();
        for(Integer i=1;i<=6;i++){
            for(Integer j=1;j<=2;j++){
                Date ddate = Date.newInstance(Date.today().year(), i, 1);
                lstDeal.add(new EBH_Deal__c(
                    RecordTypeId = dealRT_V1,
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
                    EBH_ProductTitle__c='product 1',
                    EBH_SellerEmail__c='sales@test.com',
                    EBH_Quantity__c=5,
                    EBH_DealFormat__c = 'iji',
                    EBH_BusinessName__c = acc1.Id,
                    Subsidy_Running__c = 10,
                    EBH_Payout_SI__c = 10
                ));
            }
        }
        insert lstDeal;
    }
	
    @isTest
    static void Batch_DealBudgetTest() {
        Test.startTest();
            Set<Id> dIds = new Set<Id>();
            for(EBH_Deal__c oD: [SELECT EBH_SubsidyMax__c, VAT_N__c, Subsidy_Running__c,EBH_DealTrackingEndDate__c , EBH_DealStartDate__c,  EBH_SubsidyForecast__c, Subsidy_Final_Net__c, EBH_StartDateMonthYear__c FROM EBH_Deal__c]){
                // System.debug('EBH_Deal__c ::: '+oD);
                dIds.add(oD.Id);
            }
            
            Database.executeBatch(new Batch_DealBudget());
            Database.executeBatch(new Batch_DealBudget(dIds));
            
        Test.stopTest();
        
        // for(EBH_DealsBudgetMonth__c dbm : [SELECT Tracking_End_Date__c, Month__c, Subsidy_Planned__c, Subsidy_Running__c, EBH_SubsidyForecast__c, Subsidy_Final__c FROM EBH_DealsBudgetMonth__c]){
        //     System.debug('EBH_DealsBudgetMonth__c ::: '+dbm);
        // }
        // System.debug('EBH_DealsBudget__c ::: '+[SELECT Subsidy_Planned__c, Subsidy_Forecast__c, Subsidy_Final__c FROM EBH_DealsBudget__c]);
        
    }
}