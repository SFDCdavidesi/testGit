/***
 * @author: SRONG TIN
 * @createdDate: 04/July/2018
 * @description: 
 *  - test class of LC_NewIOController
 *  - coverage : 77%
 * @references: 
 *  - 
 * @changeLog:
 *
 */
@isTest
private class TST_IO
{
    static testMethod void testNewIOs() {
        LC_NewIOController test = new LC_NewIOController();
    }
    
    /*public static Account acc;
    public static Opportunity opp;
    public static Quote quote;
    public static Media_Plan__c mediaPlan;
    public static QuoteLineItem qli;

    @testSetup static void setup(){
        //TST_DataGenerator.setupSimpleData(new Set<String>{'Account', 'Opportunity', 'Quote', 'QuoteLineItem'});
    }

    static testMethod void testNewIOs() {
        acc = TST_DataGenerator.generateAccount();
        insert acc;

        opp = TST_DataGenerator.generateOpp(acc.Id);
        opp.Special_Terms__c = 'New Terms - Spe';
        opp.Start_Date__c = Date.today();
        opp.End_Date__c = Date.today().addDays(1);
        opp.Amount = 100;
        insert opp;

        mediaPlan = TST_DataGenerator.generateMediaPlan(opp);
        insert mediaPlan;

        quote = TST_DataGenerator.generateQuote(opp.Id, mediaPlan.Id);
        insert quote;
        
        Site__c site = TST_DataGenerator.generateSite();
        insert site;
        
        Product2 prod = TST_DataGenerator.generateProduct(site.Id);
        insert prod;
        
        PriceBookEntry pbe =TST_DataGenerator.generatePricebookEntry(prod.id, null);
        insert pbe;
        qli = TST_DataGenerator.generateQuoteLinItem( quote.id, prod.id, pbe.id);
        insert qli;


        Test.startTest();

        RemoteResponse response = LC_NewIOController.newIOFromQuote(quote.Id);
        System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_ERROR);

        quote.Status = 'Approved';
        update quote;
        response = LC_NewIOController.newIOFromQuote(quote.Id); 
        System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_OK);

        opp.IO_Paper__c = 'New Terms';
        opp.Quote_Sync_In_Progress__c = true;
        update opp;
        response = LC_NewIOController.newIOFromQuote(quote.Id);
        System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_ERROR);

        quote = (Quote) QueryUtil.queryRecord(quote.id);
        update new IO__c( Id = quote.IO__c , IO_Status__c =Label.IO_STATUS_APPROVED);
        for(IO_LineItem__c ioLine : [select id from IO_LineItem__c where IO__c = :quote.IO__c limit 1]) {
            ioLine.Ad_Id__c = '123';
            ioLine.Total_Price__c = 150;
            ioLine.from_Date__c = Date.today();
            ioLine.until_Date__c = Date.today().addDays(2);
            update ioLine; // create Ad_Campaign, Monthly and Daily on IO_LineItem__c trigger when ad id is populated
        }
        IO__c io = (IO__c) QueryUtil.queryRecord(quote.IO__c);
        System.assertNotEquals(null,io.Ad_Campaign__c);
        Boolean isError = false;
        try{

            RemoteResponse responseErr = LC_NewIOController.newIOFromQuote(quote.Id + '123');
        }catch(Exception e){
            isError = true;
        }

        System.assertEquals(isError, true);

        System.debug('### io :: ' + io.IO_Status__c + ', ' + io.Buyer_Accepted__c + ', ' + io.Dually_Signed_IO__c);


        io.Buyer_Accepted__c = true;
        io.Dually_Signed_IO__c = true;
        update io;

        opp.StageName = 'Closed Won';
        update opp;

        
        Test.stopTest();
    }

    static testMethod void testRevisionIOs() {

        byPass__c bp = new byPass__c(SetupOwnerId = UserInfo.getUserId(), triggerObjects__c = 'Opportunity', byPass_Trigger__c = true);
        insert bp;

        acc = TST_DataGenerator.generateAccount();
        insert acc;

        opp = TST_DataGenerator.generateOpp(acc.Id);
        opp.Special_Terms__c = 'New Terms - Spe';
        opp.StageName = 'Qualified Meeting';
        insert opp;

        mediaPlan = TST_DataGenerator.generateMediaPlan(opp);
        insert mediaPlan;

        quote = TST_DataGenerator.generateQuote(opp.Id, mediaPlan.Id);
        insert quote;
        
        Site__c site = TST_DataGenerator.generateSite();
        insert site;
        
        Product2 prod = TST_DataGenerator.generateProduct(site.Id);
        insert prod;
        
        PriceBookEntry pbe =TST_DataGenerator.generatePricebookEntry(prod.id, null);
        insert pbe;
        qli = TST_DataGenerator.generateQuoteLinItem( quote.id, prod.id, pbe.id);
        insert qli;


        Test.startTest();

        RemoteResponse response = LC_NewIOController.newIOFromQuote(quote.Id);
        System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_ERROR);

        quote.Status = 'Approved';
        update quote;
        response = LC_NewIOController.newIOFromQuote(quote.Id);
        System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_OK);

        opp.IO_Paper__c = 'New Terms';
        update opp;
        response = LC_NewIOController.newIOFromQuote(quote.Id);
        System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_ERROR);

        quote = (Quote) QueryUtil.queryRecord(quote.id);
        update new IO__c( Id = quote.IO__c , IO_Status__c =Label.IO_STATUS_APPROVED);
        for(IO_LineItem__c ioLine : [select id from IO_LineItem__c where IO__c = :quote.IO__c limit 1]) {
            ioLine.Ad_Id__c = '123';
            ioLine.Total_Price__c = 150;
            ioLine.from_Date__c = Date.today();
            ioLine.until_Date__c = Date.today().addDays(2);
            update ioLine; // create Ad_Campaign, Monthly and Daily on IO_LineItem__c trigger when ad id is populated
        }
        IO__c io = (IO__c) QueryUtil.queryRecord(quote.IO__c);
        System.assertNotEquals(null,io.Ad_Campaign__c);
        Boolean isError = false;
        try{

            RemoteResponse responseErr = LC_NewIOController.newIOFromQuote(quote.Id + '123');
        }catch(Exception e){
            isError = true;
        }

        System.assertEquals(isError, true);

        //Create RMP
        LC_CreateMediaPlanController.createMediaPlan(opp.Id);

        Test.stopTest();
    }*/


    
}