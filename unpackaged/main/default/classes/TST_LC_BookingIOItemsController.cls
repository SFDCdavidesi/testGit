/**
 * @author: MONY
 * @createdDate: 27/Dec/2019
 * @description:
 *  - test class of LC_BookingIOItemsController
 *  - coverage : 79%
 * @references:
 *  -
 * @changeLog:
 * - test class of LC_BookingQuotetemsController
 */

@IsTest(SeeAllData=false)
private class TST_LC_BookingIOItemsController {

    static testMethod void test_method () {
         // Sophal: 29/09/2021: US-0008398 deprecated
         LC_BookingIOItemsController obj = new LC_BookingIOItemsController();
    }
   

    // public static Account acc;
    // public static Opportunity opp;
    // public static Quote quote;
    // public static Media_Plan__c mediaPlan;
    // public static QuoteLineItem qli;

    // static testMethod void test_initializeData_Direct () {

    //     Id opp_direct = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('eBay Ads - Direct').getRecordTypeId();

    //     acc = TST_DataGenerator.generateAccount();
    //     insert acc;

    //     opp = TST_DataGenerator.generateOpp(acc.Id);
    //     opp.Special_Terms__c = 'New Terms - Spe';
    //     opp.Start_Date__c = Date.today();
    //     opp.End_Date__c = Date.today().addDays(1);
    //     opp.Amount = 100;
    //     opp.RecordTypeId = opp_direct;
    //     insert opp;

    //     // mediaPlan = TST_DataGenerator.generateMediaPlan(opp);
    //     // insert mediaPlan;

    //     quote = TST_DataGenerator.generateQuote(opp.Id);
    //     insert quote;

    //     Site__c site = TST_DataGenerator.generateSite();
    //     insert site;

    //     Product2 prod = TST_DataGenerator.generateProduct(site.Id);
    //     insert prod;

    //     PriceBookEntry pbe =TST_DataGenerator.generatePricebookEntry(prod.id, null);
    //     insert pbe;

    //     qli = TST_DataGenerator.generateQuoteLinItem( quote.id, prod.id, pbe.id);
    //     insert qli;

    //     // quote.Status = 'Approved';
    //     // update quote;
        
    //     RemoteResponse response = LC_BookingQuoteItemsController.initializeDataQuote(quote.Id);
    //     System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_OK);
    //     quote = (Quote) QueryUtil.queryRecord(quote.id);
        
    //     /*Button_Action_Permission__mdt btn = [select Button_Name__c, Permissionset_Name__c from Button_Action_Permission__mdt where Button_Name__c='Booking' LIMIT 1];
    //    	System.debug('btnaaa>>>'+btn);*/
    //     //Util.btnPermissions.add(btn);
    //     /*String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
    //     Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    //     User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
    //     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    //     LocaleSidKey='en_US', ProfileId = p.Id,
    //     TimeZoneSidKey='America/Los_Angeles',
    //      UserName=uniqueUserName);
    //     System.runAs(u){
    //          RemoteResponse response = LC_BookingQuoteItemsController.initializeDataQuote(quote.Id);
    //     /*Util.btnPermissions.add(btn);
    //     System.debug('Util.btnPermissions>>>'+Util.btnPermissions);*/
    //     /*System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_OK);
    //     System.assertEquals(response.validationMsg , 'You don\'t have permission to do DFP booking!');

    //     quote = (Quote) QueryUtil.queryRecord(quote.id);
    //     }*/
        
    //     /*IO__c io = (IO__c) QueryUtil.queryRecord(quote.IO__c);
    //     System.debug('#### io :: ' + io);*/

    //     /*response = LC_BookingIOItemsController.initializeDataIO(String.valueOf(io.Id));
    //     System.debug('#### response 1 :: ' + response);
    //     System.assertEquals(response.validationMsg , 'Dually Signed IO is required to do booking!');*/

    //     /*for(IO_LineItem__c ioLine : [select id from IO_LineItem__c where IO__c = :quote.IO__c limit 1]) {
    //         ioLine.Ad_Id__c = '123';
    //         ioLine.Total_Price__c = 150;
    //         ioLine.from_Date__c = Date.today();
    //         ioLine.until_Date__c = Date.today().addDays(2);
    //         update ioLine; // create Ad_Campaign, Monthly and Daily on IO_LineItem__c trigger when ad id is populated
    //     }*/

    //     /*io.Dually_Signed_IO__c = true;
    //     update io;*/

    //     /*response = LC_BookingIOItemsController.initializeDataIO(String.valueOf(io.Id));
    //     System.debug('#### response 2 :: ' + response);
    //     System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_OK);

    //     for(IO_LineItem__c ioLine : [select id from IO_LineItem__c where IO__c = :quote.IO__c limit 1]) {
    //         response = LC_BookingIOItemsController.bookingLineItemIO(String.valueOf(ioLine.Id));
    //         System.debug('#### response 3 :: ' + response);
    //     }*/


    // }

    // static testMethod void test_initializeData_Programmatic () {

    //     Id opp_direct = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('eBay Ads - Programmatic Guaranteed').getRecordTypeId();

    //     acc = TST_DataGenerator.generateAccount();
    //     insert acc;

    //     opp = TST_DataGenerator.generateOpp(acc.Id);
    //     opp.Special_Terms__c = 'New Terms - Spe';
    //     opp.Start_Date__c = Date.today();
    //     opp.End_Date__c = Date.today().addDays(1);
    //     opp.Amount = 100;
    //     opp.RecordTypeId = opp_direct;
    //     insert opp;

    //     // mediaPlan = TST_DataGenerator.generateMediaPlan(opp);
    //     // insert mediaPlan;

    //     quote = TST_DataGenerator.generateQuote(opp.Id);
    //     insert quote;

    //     Site__c site = TST_DataGenerator.generateSite();
    //     insert site;

    //     Product2 prod = TST_DataGenerator.generateProduct(site.Id);
    //     insert prod;

    //     PriceBookEntry pbe =TST_DataGenerator.generatePricebookEntry(prod.id, null);
    //     insert pbe;

    //     qli = TST_DataGenerator.generateQuoteLinItem( quote.id, prod.id, pbe.id);
    //     insert qli;

    //     RemoteResponse response = LC_BookingQuoteItemsController.initializeDataQuote(quote.Id);
    //     System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_OK);
    //     System.assertEquals(response.validationMsg , 'You can only book line items to DFP once the quote is approved');
    //     quote = (Quote) QueryUtil.queryRecord(quote.id);
        
    //     // quote.Status = 'Approved';
    //     // update quote;
        
    //     RemoteResponse responseQli = LC_BookingQuoteItemsController.bookingLineItemQuote(qli.Id);
    //     System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_OK);
        
    //     String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
    //     Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    //     User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
    //     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    //     LocaleSidKey='en_US', ProfileId = p.Id,
    //     TimeZoneSidKey='America/Los_Angeles',
    //     UserName=uniqueUserName);
        
    //     System.runAs(u){
    //         response = LC_BookingQuoteItemsController.initializeDataQuote(quote.Id);
    //         System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_ERROR);
    //     }
    //     /*RemoteResponse response = LC_NewIOController.newIOFromQuote(quote.Id);
    //     System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_OK);*/
        
    //     /*IO__c io = (IO__c) QueryUtil.queryRecord(quote.IO__c);
    //     System.debug('#### io :: ' + io);*/
        
    //     //response = LC_BookingIOItemsController.initializeDataIO(String.valueOf(quote.Id));
    //     /*response = LC_BookingIOItemsController.initializeDataIO(String.valueOf(io.Id));
    //     System.debug('#### response 1 :: ' + response);
    //     System.assertEquals(response.validationMsg , 'You cannot book line items until the IO is approved or Buyer has Accepted.');*/

    //     /*for(IO_LineItem__c ioLine : [select id from IO_LineItem__c where IO__c = :quote.IO__c limit 1]) {
    //         ioLine.Ad_Id__c = '123';
    //         ioLine.Total_Price__c = 150;
    //         ioLine.from_Date__c = Date.today();
    //         ioLine.until_Date__c = Date.today().addDays(2);
    //         update ioLine; // create Ad_Campaign, Monthly and Daily on IO_LineItem__c trigger when ad id is populated
    //     }

    //     io.Buyer_Accepted__c = true;
    //     io.IO_Status__c = 'Approved';
    //     update io;

    //     response = LC_BookingIOItemsController.initializeDataIO(String.valueOf(io.Id));
    //     System.debug('#### response 2 :: ' + response);
    //     System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_OK);

    //     for(IO_LineItem__c ioLine : [select id from IO_LineItem__c where IO__c = :quote.IO__c limit 1]) {
    //         response = LC_BookingIOItemsController.bookingLineItemIO(String.valueOf(ioLine.Id));
    //         System.debug('#### response 3 :: ' + response);
    //     }

    //     response = LC_BookingIOItemsController.bookingLineItemIO(String.valueOf(io.Id));
    //         System.debug('#### response 4 :: ' + response);*/

    // }
}