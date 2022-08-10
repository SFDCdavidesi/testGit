/*
@       Deprecated by       Mony Nou
@       Deprecated Date     24.08.2021
@       Reason: US-0010230 - We no longer using class LC_CopyQuoteWithItemsController because now we use new button called "Clone Quote (Clone_Quote)" on Opportunity 
                            and below old buttons that reference with that class are no longer used and Dev team will deprecated it as a part of this story.
                                + Quick Action - Opportunity.CloneQuote
                                + Quick Action - Quote.Copy_Quote_With_Items
*/

@isTest
private class TST_LC_CopyQuoteWithItemsController {

	@isTest
	static void test_method() {
		LC_CopyQuoteWithItemsController obj = new LC_CopyQuoteWithItemsController();
	}

	/*
	@isTest
	static void test_CopyQuoteWithItems() {
		Map<String, List<sObject>> data = TST_DataGenerator.setUpTargetingData();
		List<Quote> quotes = (List<Quote>) data.get('Quote');

		RemoteResponse res = LC_CopyQuoteWithItemsController.copyQuoteWithItems(quotes.get(0).Id); 
		Id newQuoteId = (Id) res.Content;

		Quote q = (Quote) QueryUtil.queryRecord(newQuoteId);
		system.assertEquals(null, q.IO__c);
	}
	
	@isTest
	static void test_FetchExistingQuotes() {
	    Map<String, List<sObject>> data = TST_DataGenerator.setUpTargetingData();
        List<Opportunity> opps = (List<Opportunity>) data.get('Opportunity');
	    
	    RemoteResponse res = LC_CopyQuoteWithItemsController.fetchExistingQuotes(opps[0].Id);
        system.assertNotEquals(null, res);


		Opportunity opp1 = TST_DataGenerator.generateOpp(opps[0].AccountId);
        insert opp1;

		res = LC_CopyQuoteWithItemsController.fetchExistingQuotes(opp1.Id);
	}
	
	@isTest
    static void test_CloneExistingQuote() {
        Map<String, List<sObject>> data = TST_DataGenerator.setUpTargetingData();
        List<Opportunity> opps = (List<Opportunity>) data.get('Opportunity');
        List<Quote> quotes = (List<Quote>) data.get('Quote');
        
        RemoteResponse res = LC_CopyQuoteWithItemsController.cloneExistingQuote(quotes[0].Id, opps[0].Id);
        system.assertNotEquals(null, res);
    }
	
	*/
}