/*
@       Deprecated by       Mony Nou
@       Deprecated Date     24.08.2021
@       Reason: US-0010230 - We no longer using class LC_CopyQuoteWithItemsController because now we use new button called "Clone Quote (Clone_Quote)" on Opportunity 
                            and below old buttons that reference with that class are no longer used.
                                + Quick Action - Opportunity.CloneQuote
                                + Quick Action - Quote.Copy_Quote_With_Items
*/

public with sharing class LC_CopyQuoteWithItemsController {
	
    /*
	@AuraEnabled
    public static RemoteResponse copyQuoteWithItems(Id quoteId) {
		RemoteResponse response = new RemoteResponse();
		try {
            Id newQuoteId = GW_Quote.copyQuoteWithItems(quoteId);
			response.content = newQuoteId;
			response.statusCode = RemoteResponse.STATUSCODE_OK;
    	} catch(Exception e) { response = new RemoteResponse(e.getMessage(), RemoteResponse.STATUSCODE_ERROR); }
		return response;
	}
	
	@AuraEnabled
    public static RemoteResponse fetchExistingQuotes(Id oppId) {
        List<Quote> quotes = (List<Quote>)QueryUtil.queryRecords('Quote', 'CreatedDate >= LAST_N_YEARS:2', new Set<String>(new List<String>{'Account.Name', 'Opportunity.Name'}), new Map<String,Object>(), 'Order By LastModifiedDate DESC');
        List<Map<String, String>> resultQuotes = new List<Map<String, String>>();
        RemoteResponse response = new RemoteResponse();
        
        Opportunity opp = [select PMP_Subtype__c, Number_of_Quotes__c, RecordType.DeveloperName from Opportunity where id =:oppId];
        if (Label.OPP_RECORDTYPEDEVNAME_PMP.equalsIgnoreCase(opp.RecordType.DeveloperName) && Label.OPP_PMPSUBTYPE_FLOOR.equalsIgnoreCase(opp.PMP_Subtype__c)) {
            response = new RemoteResponse(Label.ERR_CLONE_QUOTE_ON_OPP_PMPSUBTYPE_FLOOR, RemoteResponse.STATUSCODE_ERROR);
            return response;
        }
        if (opp.Number_of_Quotes__c > 0) {
            response = new RemoteResponse(Label.ERR_CLONE_QUOTE_ON_OPP_EXIST_QUOTE, RemoteResponse.STATUSCODE_ERROR);
            return response;
        }

        try {
            for (Quote q : quotes) {
                resultQuotes.add(new Map<String, String> {
                    'QuoteId' => q.Id,
                    'QuoteName' => q.Name,
                    'AccountName' => q.Account.Name,
                    'OpportunityName' => q.Opportunity.Name
                });
            }
            response.content = resultQuotes;
            response.statusCode = RemoteResponse.STATUSCODE_OK;
        } catch(Exception e) { response = new RemoteResponse(e.getMessage(), RemoteResponse.STATUSCODE_ERROR); }
        return response;
    }
    */

    // @AuraEnabled
    // public static RemoteResponse cloneExistingQuote(String quoteId, String opportunityId) {
    //     RemoteResponse response = new RemoteResponse();
    //     Map<String, String> resultSet  = new Map<String, String>(); 
    //     Savepoint sp = Database.setSavepoint();
    //     try {
    //         Id newQuoteId = GW_Quote.copyQuoteWithItems(quoteId, opportunityId);
    //         resultSet.put('newQuoteId', newQuoteId);
    //         /* MN-21062021-Remove deleted method createMediaPlan
    //         if (Database.countQuery('SELECT Count() FROM '+ Util.NS +'Media_Plan__c WHERE Opportunity__c =: opportunityId') == 0) {
    //             Map<String, Object> resultMediaPlan = GW_Opportunity.createMediaPlan(opportunityId);
    //             if(resultMediaPlan.containsKey('Id')){
    //                 Id newMediaPlanId = Util.getString(resultMediaPlan.get('Id'));
	//                 resultSet.put('newMediaPlanId', newMediaPlanId);
	//                 update new Quote(Id = newQuoteId, Media_Plan__c = newMediaPlanId);
	//             } else {
	//                 throw new Util.CustomException(Util.getString(resultMediaPlan.get('Message')));
	//             }
    //         }
    //         */
    //         response.content = resultSet;
    //         response.statusCode = RemoteResponse.STATUSCODE_OK;
    //     } catch(Exception e) { Database.rollback(sp); response = new RemoteResponse(e.getMessage(), RemoteResponse.STATUSCODE_ERROR); }
    //     return response;
    // }
    
    
}