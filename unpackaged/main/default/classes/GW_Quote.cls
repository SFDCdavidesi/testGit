// MN-25102021-Deprecated via US-0008416
public with sharing class GW_Quote {
	
	// public static Map<String, Object> initValue = new Map<String, Object>{
	// 	'Status' => 'Draft',
	// 	Util.NS + 'Total_Budget_Change__c' => false,
	// 	Util.NS + 'Total_Impressions_Change__c' => false
	// };

	// public static void copyQlinesToIOLines(Set<Id> approvingIds){
	// 	if(approvingIds.isEmpty()) return;
	// 	GW_Quote.copyQli2IOli(approvingIds);
	// 	List<IO_LineItem__c> ioItems2Update = new List<IO_LineItem__c>();
		
	// 	for(IO_LineItem_Junction__c junc : [select id, IO_LineItem__c, Quote_LineItem__r.Description__c, Quote_LineItem__r.from_Date__c, Quote_LineItem__r.until_Date__c, Quote_LineItem__r.SalesPriceNet__c, Quote_LineItem__r.Quantity__c, Quote_LineItem__r.Budget__c
	// 										from IO_LineItem_Junction__c 
	// 										where Quote_LineItem__r.QuoteId IN : approvingIds and 
	// 											Quote_LineItem__r.Quote.Media_Plan__r.IsRevision__c = true]) {
	// 		IO_LineItem__c ioItem = new IO_LineItem__c(Id=junc.IO_LineItem__c, from_Date__c = junc.Quote_LineItem__r.from_Date__c, until_Date__c = junc.Quote_LineItem__r.until_Date__c, 
	// 								SalesPriceNet__c = junc.Quote_LineItem__r.SalesPriceNet__c, Quantity__c = junc.Quote_LineItem__r.Quantity__c, Total_Price__c=junc.Quote_LineItem__r.Budget__c, Description__c = junc.Quote_LineItem__r.Description__c);
	// 		ioItems2Update.add(ioItem);	
	// 	}
	// 	WithoutSharing.doUpdate(ioItems2Update);

	// 	//MN-07102019 - Check if there are some QLI that deleted => need to delete the associated IOLI as well.
	// 	List<IO_LineItem__c> lstIOLI2delete = new List<IO_LineItem__c>();
	// 	for(IO_LineItem__c ioli : [SELECT Id, Name, Product__r.Name FROM IO_LineItem__c WHERE IO__r.Most_Recent_Quote__c IN:approvingIds AND Id NOT IN (SELECT IO_LineItem__c FROM IO_LineItem_Junction__c WHERE Quote_LineItem__r.QuoteId IN : approvingIds)]) lstIOLI2delete.add(ioli);
	// 	if (!lstIOLI2delete.isEmpty()) delete lstIOLI2delete;
	// }
	
	// public static Id copyQuoteWithItems(Id quoteId){
    //     return copyQuoteWithItems(quoteId, null);
	// }
	
	// // Task #25030: PG/PMP opportunity RT Does not use IO, Quote on Opportunity
    // public static Map<String, Object> revisionQuote(Id oppId){
    //     Map<String, Object> mapResult = new Map<String, Object>();
    	
    //     Opportunity opp = (Opportunity) QueryUtil.queryRecord(oppId);
    //     List<Quote> quotes = (List<Quote>) QueryUtil.queryRecords('Quote', Util.NS+'Media_Plan__c <> null And OpportunityId=:value1 ORDER BY CreatedDate DESC',new Set<String>{Util.NS+'Media_Plan__r.Name'}, new Map<String,Object>{'value1'=>opp.Id});
    //     if( quotes.isEmpty() ) throw new ExceptionGroup.CustomException(Label.ERR_NO_QUOTE_LINKED_TO_MEDIAPLAN);
        
    //     Quote lastRevisionQuote = quotes.get(0);
    //     Quote originQuote = quotes.get( quotes.size()-1 );
	// 	Map<Id, Media_Plan__c> mOldMPId2NewRecord = new Map<Id, Media_Plan__c>();
    //     for(Media_Plan__c mp: (List<Media_Plan__c>) QueryUtil.queryRecords(Util.NS+'Media_Plan__c', new Set<String>{lastRevisionQuote.Media_Plan__c})){
    //         Media_Plan__c newMp = mp.clone();
    //         newMp.Name = originQuote.Media_Plan__r.Name +'. V' + (quotes.size()+1);
    //         newMp.Opportunity__c = opp.Id;
    //         newMp.IsRevision__c = true;
    //         newMp.Media_Plan_Stage__c = 'New';
    //         newMp.OwnerId = UserInfo.getUserId();
    //         mOldMPId2NewRecord.put(mp.Id, newMp);
    //     }
	// 	WithoutSharing.doInsert(mOldMPId2NewRecord.values());
		
    //     if(mOldMPId2NewRecord.get(lastRevisionQuote.Media_Plan__c) != null){
    //      	mapResult.put('mpid', mOldMPId2NewRecord.get(lastRevisionQuote.Media_Plan__c).Id);
	// 	}
		
    //     Map<Id, Quote> mOldQuoteId2NewRecord = new Map<Id, Quote>();
    //     Map<Id, Quote> cloningQuote = new Map<Id,Quote>(new List<Quote>{lastRevisionQuote});
    //     for(Quote quote: cloningQuote.values()){
    //         Quote newQuote =quote.clone();
    //         newQuote.OpportunityId = opp.Id;
    //         newQuote.Status = Label.QUOTE_STATUS_DRAFT;
    //         newQuote.Name = originQuote.Name +'. V' + (quotes.size()+1);
    //         // replace newly create record id
    //         if(mOldMPId2NewRecord.get(quote.Media_Plan__c)!=null) newQuote.Media_Plan__c = mOldMPId2NewRecord.get(quote.Media_Plan__c).Id;
    //         mOldQuoteId2NewRecord.put(quote.id, newQuote);

    //     }
    //     WithoutSharing.doInsert(mOldQuoteId2NewRecord.values());

    //     Set<String> oldTargetingIds = new Set<String>();
    //     Map<Id,QuoteLineItem> oldQlis = new Map<Id,QuoteLineItem>((List<QuoteLineItem>)QueryUtil.queryRecords('QuoteLineItem', 'QuoteId IN:value1', new Set<String>{'Quote.'+Util.NS+'IO__c','PricebookEntry.UnitPrice', 'Product2.'+Util.NS+'Billing_Category__c'}, new Map<String,Object>{'value1'=>cloningQuote.keySet()}));
    //     for(QuoteLineItem qli: oldQlis.values()){
    //         oldTargetingIds.add(qli.Targeting__c);
	// 	}
		
    //     Map<Id, Targeting__c> mOldTgId2NewRecord = GW_Targeting.copyTargeting(oldTargetingIds);
	// 	Map<Id, QuoteLineItem> mapOldQliId2NewRecord = new Map<Id, QuoteLineItem>();
    //     Map<Id, IO_LineItem__c> mapQliId2IOLineItem = GW_QuoteLineItem.getMapQliId2IOline(oldQlis.values());
    //     for(QuoteLineItem qli: oldQlis.values()){
    //         QuoteLineItem newQli = qli.clone();
    //         if(mOldTgId2NewRecord.containsKey(qli.Targeting__c)) newQli.Targeting__c = mOldTgId2NewRecord.get(qli.Targeting__c).Id;
    //          newQli.QuoteId = mOldQuoteId2NewRecord.get(qli.QuoteId).Id;
    //          newQli.Quantity__c = qli.Quantity__c;
    //          newQli.SalesPriceNet__c = qli.SalesPriceNet__c;
    //          newQli.Budget__c = qli.Budget__c;
    //         mapOldQliId2NewRecord.put(qli.id, newQli);
    //     }
    //     WithoutSharing.doInsert(mapOldQliId2NewRecord.values());

    //     List<Quote> initValues = new List<Quote>();
    //     for(Quote quote: mOldQuoteId2NewRecord.values()){
    //         Quote initQuote = new Quote(Id = quote.Id);
    //         GW_Quote.applyInitValue(initQuote);
    //         initValues.add(initQuote);
    //     }
    //     WithoutSharing.doUpdate(initValues);

    //     if(!mOldMPId2NewRecord.values().isEmpty())  opp.Media_Plan__c = mOldMPId2NewRecord.values().get(0).Id;
    //     WithoutSharing.doUpdate(new Opportunity[]{opp});
        
    //     // End return result
    //     return mapResult;
	// }
	
    // public static Id copyQuoteWithItems(Id quoteId, Id opportunityId){
    //     Quote q = (Quote) QueryUtil.queryRecord(quoteId);
    //     Quote clonedQuote =q.clone();
    //     clonedQuote.IO__c = null;
    //     if (opportunityId != null) {
    //         Opportunity opp = (Opportunity) QueryUtil.queryRecord(opportunityId);
    //         clonedQuote.OpportunityId = opportunityId;
    //         clonedQuote.Name = opp.Name;
    //     }
        
	// 	WithoutSharing.doInsert(new List<Quote>{clonedQuote});
		
    //     Map<Id, QuoteLineItem> mapOldQliId2NewRecord = new Map<Id, QuoteLineItem>();
    //     Set<String> oldTargetingIds = new Set<String>();
    //     Map<Id,QuoteLineItem> oldQlis = new Map<Id,QuoteLineItem>((List<QuoteLineItem>)QueryUtil.queryRecords('QuoteLineItem', 'QuoteId =:value1',  new Map<String,Object>{'value1'=>quoteId}));
    //     for(QuoteLineItem qli: oldQlis.values()){
    //         oldTargetingIds.add(qli.Targeting__c);
    //     }
    //     Map<Id, Targeting__c> mOldTgId2NewRecord = GW_Targeting.copyTargeting(oldTargetingIds);

    //     for(QuoteLineItem qli: oldQlis.values()){
    //         QuoteLineItem newQli = qli.clone();
    //         newQli.QuoteId = clonedQuote.Id;
    //         if(mOldTgId2NewRecord.containsKey(qli.Targeting__c)) newQli.Targeting__c = mOldTgId2NewRecord.get(qli.Targeting__c).Id;
    //         mapOldQliId2NewRecord.put(qli.id, newQli);
    //     }
	// 	WithoutSharing.doInsert(mapOldQliId2NewRecord.values());
		
	// 	applyInitValue(clonedQuote);
	// 	WithoutSharing.doUpdate(new List<Quote>{clonedQuote});

    //     return clonedQuote.Id;
	// }

	// public static void applyInitValue(Quote newQuote) {
	// 	for (String fldName : initValue.keySet()) {
	// 		newQuote.put(fldName, initValue.get(fldName));
	// 	}
	// }

	// public static boolean isRevision(Quote q){
	// 	//return q.Opportunity.Type == Label.OPP_TYPE_DIRECT_REVISION; //MN-01072019 - We no longer use Direct Revision RecordType or any picklist value anymore
	// 	return q.Media_Plan__r.IsRevision__c;
	// }

	// public static boolean isLock(Quote q){
	// 	return GW_Quote.isRevision(q) && q.IO__r.Dually_Signed_IO__c && q.IO__r.IO_Status__c == Label.IO_STATUS_APPROVED;
	// }
	
	// public static void assignDefaultPricebook(Quote quote) {
	// 	if (quote.Pricebook2Id != null) return;
	// 	for(Pricebook2 pricebook : [SELECT Id, Name FROM Pricebook2 WHERE Name = :Label.QUOTE_DEFAULT_PRICEBOOK LIMIT 1]){
	// 		quote.Pricebook2Id = pricebook.Id;
	// 	}
	// 	update quote;
	// }

	// /*
	// @ Change history: 
	// *	Author 		: AMT
	// *	Description : Bug. Every time a quote line item is added on the 2nd, 3rd, 4TH, 5TH quote, the line item automatically gets added to the IO. We need the quote to be first approved before the QLI gets added to the IO.
	// *	History 	: 5-July-2019 : Code creation.
	// */
	// private static void copyQli2IOli(Set<Id> approvingIds){
	// 	Set<String> sAllQLIIds = new Set<String>();
	// 	Map<String, List<QuoteLineItem>> mApprQuote = new Map<String, List<QuoteLineItem>>();
	// 	// select all quotelineitem form quote
	// 	for(Quote sQ : [SELECT (SELECT Id FROM QuoteLineItems) FROM Quote WHERE Id IN: approvingIds AND Media_Plan__r.IsRevision__c = true]){
	// 		mApprQuote.put(sQ.Id, sQ.QuoteLineItems);
	// 		for(QuoteLineItem sQLI : sQ.QuoteLineItems){
	// 			// this will use for udpate iolineitemjunction at the end
	// 			sAllQLIIds.add(sQLI.Id);
	// 		}
	// 	}
		
	// 	Set<String> sQLId4InsertIOLI = sAllQLIIds.clone();
	// 	// filter the quotelineitem that already existing in iolineitem or not
	// 	for(IO_LineItem_Junction__c sIOLI : [SELECT Quote_LineItem__c 
	// 												FROM IO_LineItem_Junction__c 
	// 												WHERE Quote_LineItem__r.QuoteId IN : mApprQuote.keySet()]){
	// 		// this will use to insert iolineitem that not yet syn form quotelineitem														
	// 		sQLId4InsertIOLI.remove(sIOLI.Quote_LineItem__c);
	// 	}
		
	// 	Map<Id, List<QuoteLineItem>> mQQLI = new Map<Id, List<QuoteLineItem>>();
	// 	// Store all Quotelineitem id for updateJunction later
	// 	for(QuoteLineItem sQLI : (List<QuoteLineItem>) QueryUtil.queryRecords('QuoteLineItem', 'Id IN:value1', new Set<String>{'Quote.'+Util.NS+'IO__c'}, new Map<String,Object>{'value1'=>sQLId4InsertIOLI})){

	// 		if(mQQLI.containsKey(sQLI.QuoteId)){
	// 			mQQLI.get(sQLI.QuoteId).add(sQLI);
	// 		}else{
	// 			mQQLI.put(sQLI.QuoteId, new List<QuoteLineItem>{sQLI});
	// 		}
	// 	}
		
	// 	Map<Id, IO_LineItem__c> mIOLI = new Map<Id, IO_LineItem__c>();
	// 	List<QuoteLineItem> lstQLI4InsertJunct = new List<QuoteLineItem>();
	// 	for(Id sQId : mQQLI.keySet()){
	//         for(QuoteLineItem sQLI : mQQLI.get(sQId)){
	//             IO_LineItem__c IOLineItem = .convertQuoteLIToIOLineItem(sQLI, false);
	//             IOLineItem.IO__c = sQLI.Quote.IO__c;
	            
	//             mIOLI.put(sQLI.Id, IOLineItem);
	//             // this will use for insert iolineitemjunction after iolineitem created
	//             lstQLI4InsertJunct.add(sQLI);
	//         }
	// 	}
		
	// 	// Insert IOLineItem
    //     WithoutSharing.doInsert(mIOLI.values());
        
    //     // Insert IOLineItemJunction
    //     WithoutSharing.doInsert(GW_IO_LineItem_Junction.getIOLineItemJunction(lstQLI4InsertJunct, mIOLI));
        
    //     // Update IOLineItemJunction
    //     GW_IO_LineItem_Junction.updateJunction(sAllQLIIds);
	// }
}