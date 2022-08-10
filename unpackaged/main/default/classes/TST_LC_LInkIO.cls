/**
 * Author : Gaeasys
 * CreatedDate: 09-June-2018
 * Description:
 */
@isTest
public class TST_LC_LInkIO {

  @isTest
	static void test_method() {
    //Sophal:29/09/2021: US-0008418
		LC_LinkIO obj = new LC_LinkIO();
	}

	/*public static Account acc;
	public static Opportunity opp;
	public static Quote quote;
	public static Media_Plan__c mediaPlan;

	@testSetup
    static void setup(){
		System.debug('log');
	}

     static testMethod void test() {
     	acc = new Account();
		acc = TST_DataGenerator.generateAccount();
		insert acc;

		opp = TST_DataGenerator.generateOpp(acc.Id);
		insert opp;

		mediaPlan = TST_DataGenerator.generateMediaPlan(opp);
		insert mediaPlan;

		quote = TST_DataGenerator.generateQuote(opp.Id, mediaPlan.Id);
		insert quote;

     	IO__c io = new IO__c();
		io.Name = 'IO Name Test';
        io.Agency__c = acc.Id;
        insert io;

        Test.startTest();
        List<IO__c> ioList = new List<IO__c>();
        String quoteId = String.valueOf(quote.Id);
        String ioId = String.valueOf(io.Id);

       RemoteResponse response = LC_LInkIO.getData(quoteId);
       System.assertEquals(0, response.contents.size());


       response = LC_LInkIO.getData(opp.Id);
       System.assertEquals(0, response.contents.size());

       opp.Agency__c = acc.id;
       update opp;
        response = LC_LInkIO.getData(quoteId);
       System.assertEquals(1, response.contents.size());

       quote.IO__c = io.Id;
       update quote;
       RemoteResponse response1 = LC_LInkIO.linkFromQuoteToIO(ioId,quoteId);
       System.assertEquals(response1.statusCode,RemoteResponse.STATUSCODE_OK);


       response1 = LC_LInkIO.linkFromQuoteToIO(ioId,opp.Id);
       System.assertEquals(Label.ERR_REVISION_IO_OPP_ALREADY_LINKED,response1.message);

       Test.stopTest();
	}

	static testMethod void failTest(){
		RemoteResponse response = LC_LInkIO.getData(null);
		system.assertEquals(response.statusCode,  RemoteResponse.STATUSCODE_ERROR);
	}*/
}