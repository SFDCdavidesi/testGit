/*****************************************************************************************************************************
@ Class:          OpportunityTriggerHandlerTest
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        Test Class for OpportunityTriggerHandler
------------------------------------------------------------------------------------------------------------------------------
@ Change history:  24.08.2020 / Sophal Noch / Created the method.
@*****************************************************************************************************************************/
@isTest
private class OpportunityTriggerHandlerTest {

    public static Account account;
    public static Opportunity opp1;
    public static Opportunity opp2;
    public static Integer currentYear = System.Today().year();

    public static Date startDate;
    public static Date endDate;

    public static Quote quote1;
    public static Quote quote2;

    public static Decimal opp1DefaultAmount = 100;
    public static Decimal opp2DefaultAmount = 500;



    private static void setUpOpp(){

        byPass__c bp = new byPass__c(SetupOwnerId = UserInfo.getUserId(), triggerObjects__c = 'Opportunity Quote QuoteLineItem', byPass_Trigger__c = false,ByPass_Validation__c=true,byPass_WFRule__c=true);
        insert bp;

        account = TST_DataGenerator.generateAccount();
        insert account;

        startDate = Date.today();
        endDate = startDate.addMonths(3);

        opp1 = new Opportunity(
                Name = 'Opp 1',
                Amount = opp1DefaultAmount,
                StageName = 'Qualified Meeting',
                CloseDate = Date.newInstance( currentYear, 1, 1),
                Start_Date__c = startDate,
                End_Date__c = endDate
        );
        opp2 = new Opportunity(
                Name = 'Opp 2',
                Amount = opp2DefaultAmount,
                StageName = 'Qualified Meeting',
                CloseDate = Date.newInstance( currentYear, 1, 1),
                Start_Date__c = startDate,
                End_Date__c = endDate
        );

        insert new List<Opportunity>{opp1,opp2};

        quote1 = new Quote(Name = 'q1', OpportunityId = opp1.Id);
        quote2 = new Quote(Name = 'q2', OpportunityId = opp2.Id);

        insert new List<Quote>{quote1,quote2};

        quote1.Primary_Quote__c = false;
        quote2.Primary_Quote__c = false;
        update new List<Quote>{quote1,quote2};

    }


    /*****************************************************************************************************************************
    @ Method:       testGeneratingAdProductWithoutPrimaryQuote
    @ Author:       Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:      test method for story US-0008007
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	none
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  24.08.2020  / Sophal Noch / Created the  method.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  15.10.2020  / Sophal Noch / US-0008451 update the  method name and add test more case for US-0008451.
    @*****************************************************************************************************************************/ 
    static testMethod void testGeneratingAdProductWithoutPrimaryQuote(){
        // add start date and end date for case in US-0008451
        setUpOpp();

        List<Ad_Product__c> adProductList = [
                SELECT Id, 
                TotalPrice__c, 
                Opportunity__c,
                from_Date__c,
                until_Date__c
                FROM Ad_Product__c Where Opportunity__c =: opp1.Id OR Opportunity__c =: opp2.Id
                ORDER BY Opportunity__c ASC
        ];

        System.assertEquals(2, adProductList.size());

        System.assertEquals(opp1.Amount,adProductList[0].TotalPrice__c);
        System.assertEquals(opp1.Start_Date__c,adProductList[0].from_Date__c);
        System.assertEquals(opp1.End_Date__c,adProductList[0].until_Date__c);
        
        System.assertEquals(opp2.Amount,adProductList[1].TotalPrice__c);
        System.assertEquals(opp2.Start_Date__c,adProductList[1].from_Date__c);
        System.assertEquals(opp2.End_Date__c,adProductList[1].until_Date__c);

        opp1.Amount = 200;
        opp2.Amount = 600;

        Opportunity opp3 = new Opportunity(
                Name = 'Opp 3',
                Amount = 900,
                StageName = 'Qualified Meeting',
                CloseDate = Date.newInstance( currentYear, 1, 1),
                Start_Date__c = startDate,
                End_Date__c = endDate
        );

        upsert new List<Opportunity>{opp1,opp2,opp3};


        List<Ad_Product__c> adProductListAfterOppUpsert = [
                SELECT Id, 
                TotalPrice__c, 
                Opportunity__c,
                from_Date__c,
                until_Date__c
                FROM Ad_Product__c Where Opportunity__c =: opp1.Id OR Opportunity__c =: opp2.Id OR Opportunity__c =: opp3.Id
                ORDER BY Opportunity__c ASC
        ];

        System.assertEquals(3, adProductListAfterOppUpsert.size());

        System.assertEquals(opp1.Amount,adProductListAfterOppUpsert[0].TotalPrice__c);
        System.assertEquals(opp1.Start_Date__c,adProductListAfterOppUpsert[0].from_Date__c);
        System.assertEquals(opp1.End_Date__c,adProductListAfterOppUpsert[0].until_Date__c);

        System.assertEquals(opp2.Amount,adProductListAfterOppUpsert[1].TotalPrice__c);
        System.assertEquals(opp2.Start_Date__c,adProductListAfterOppUpsert[1].from_Date__c);
        System.assertEquals(opp2.End_Date__c,adProductListAfterOppUpsert[1].until_Date__c);

        System.assertEquals(opp3.Amount,adProductListAfterOppUpsert[2].TotalPrice__c);
        System.assertEquals(opp3.Start_Date__c,adProductListAfterOppUpsert[2].from_Date__c);
        System.assertEquals(opp3.End_Date__c,adProductListAfterOppUpsert[2].until_Date__c);

        Product2 prod2 = new Product2(Name = 'test prod');
        insert prod2;
        adProductListAfterOppUpsert[0].Product2__c = prod2.Id;
        update adProductListAfterOppUpsert[0];

        // update start date and end date for case in US-0008451
        opp1.Amount = 111;
        opp1.End_Date__c = endDate.addMonths(1);

        opp2.Amount = 222;
        opp2.End_Date__c = endDate.addMonths(1);

        opp3.Amount = 333;
        opp3.End_Date__c = endDate.addMonths(1);

        List<Opportunity> oppListToUpdate = new List<Opportunity>{opp1,opp2,opp3};

       
        // System.debug('nsp: start date debug ------' );
        Database.SaveResult[] savedList = Database.update(oppListToUpdate, false);
        // System.debug('nsp: stop date debug -------' );

        /*
        System.assertEquals(false,savedList[0].isSuccess());
        System.assertEquals('The Total Amount cannot be updated for this opportunity.',savedList[0].getErrors()[0].getMessage());

        System.assertEquals(true,savedList[1].isSuccess());

        System.assertEquals(true,savedList[2].isSuccess());
        */

        List<Ad_Product__c> adProductListAfterFinalOppUpdate = [
                SELECT Id, 
                TotalPrice__c, 
                Opportunity__c,
                from_Date__c,
                until_Date__c
                FROM Ad_Product__c Where Opportunity__c =: opp1.Id OR Opportunity__c =: opp2.Id OR Opportunity__c =: opp3.Id
                ORDER BY Opportunity__c ASC
        ];

        System.assertEquals(3, adProductListAfterFinalOppUpdate.size());

         // compare start date and end date for case in US-0008451
         /*
        System.assertNotEquals(opp1.Amount,adProductListAfterFinalOppUpdate[0].TotalPrice__c);
        System.assertNotEquals(opp1.End_Date__c,adProductListAfterFinalOppUpdate[0].until_Date__c);
        System.assertEquals(200,adProductListAfterFinalOppUpdate[0].TotalPrice__c);
        System.assertEquals(endDate,adProductListAfterFinalOppUpdate[0].until_Date__c);

        System.assertEquals(opp2.Amount,adProductListAfterFinalOppUpdate[1].TotalPrice__c);
        System.assertEquals(opp2.End_Date__c,adProductListAfterFinalOppUpdate[1].until_Date__c);

        System.assertEquals(opp3.Amount,adProductListAfterFinalOppUpdate[2].TotalPrice__c);
        System.assertEquals(opp3.End_Date__c,adProductListAfterFinalOppUpdate[2].until_Date__c);
        */

        opp1.Amount = 400;
        opp1.Quote_Sync_In_Progress__c = true;
        opp2.Amount = 500;
        opp3.Amount = 600;

        oppListToUpdate = new List<Opportunity>{opp1,opp2,opp3};

        savedList = Database.update(oppListToUpdate, false);

        System.assertEquals(true,savedList[0].isSuccess());

        System.assertEquals(true,savedList[1].isSuccess());

        System.assertEquals(true,savedList[2].isSuccess());


    }

    /*****************************************************************************************************************************
    @ Method:       testGeneratingAdProductWithPrimaryQuote
    @ Author:       Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:      test method for story US-0008451
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	none
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  15.10.2020  / Sophal Noch / Created the  method.
    @*****************************************************************************************************************************/ 
    static testMethod void testGeneratingAdProductWithPrimaryQuote(){
        setUpOpp();
        quote1.Primary_Quote__c = true;
        quote2.Primary_Quote__c = false;
        update new List<Quote>{quote1,quote2};

        Date newStartDate = Date.today().addYears(1);
        Date newEndDate = newStartDate.addMonths(5);

        opp1.Start_Date__c = newStartDate;
        opp1.End_Date__c = newEndDate;
        opp1.Amount = 111;

        opp2.Start_Date__c = newStartDate;
        opp2.End_Date__c = newEndDate;
        opp2.Amount = 222;

        update new List<Opportunity>{opp1,opp2};


        List<Ad_Product__c> adProductListAfterOppUpdate = [
                SELECT Id, 
                Opportunity__c,
                from_Date__c,
                until_Date__c,
                TotalPrice__c
                FROM Ad_Product__c Where Opportunity__c =: opp1.Id OR Opportunity__c =: opp2.Id
                ORDER BY Opportunity__c ASC
        ];


        // not equal for opp1
        System.assertNotEquals(opp1.Start_Date__c,adProductListAfterOppUpdate[0].from_Date__c);
        System.assertNotEquals(opp1.End_Date__c,adProductListAfterOppUpdate[0].until_Date__c);
        System.assertNotEquals(opp1.Amount,adProductListAfterOppUpdate[0].TotalPrice__c);

        // equal for opp1
        System.assertEquals(startDate,adProductListAfterOppUpdate[0].from_Date__c);
        System.assertEquals(endDate,adProductListAfterOppUpdate[0].until_Date__c);
        System.assertEquals(opp1DefaultAmount,adProductListAfterOppUpdate[0].TotalPrice__c);

        // equal for opp2
        System.assertEquals(opp2.Start_Date__c,adProductListAfterOppUpdate[1].from_Date__c);
        System.assertEquals(opp2.End_Date__c,adProductListAfterOppUpdate[1].until_Date__c);
        System.assertEquals(opp2.Amount,adProductListAfterOppUpdate[1].TotalPrice__c);


    }

}