// MN-26102021-Deprecated via US-0008416
/**
 * Author : Gaeasys
 * CreatedDate: 31-May-2018
 * Description:
 */
public with sharing class GW_IO {


	// static GW_IO.ApproversHandler apprHDL;
	// public static GW_IO.ApproversHandler getApprHDL(){
	// 	if(GW_IO.apprHDL == null) GW_IO.apprHDL = new GW_IO.ApproversHandler();
	// 	return GW_IO.apprHDL;
	// }

    // /**
    //  *    Related to Task #16012, #16015
    //  *  Convert a quote to IO defined in custom metadata type
    //  *  1. if default__c is check, use default value
    //  *  2. if default__c is not check, use Opportunity_Field__c, Media_Plan_Field__c or Quote_Field__c
    //  */
    // public static IO__c convertQuoteToIO(Quote quote, Boolean checkUpdateFlag){
    //     IO__c io = new IO__c();

    //     for(Q2IO_Mapping__mdt fieldMapper : (List<Q2IO_Mapping__mdt>) QueryUtil.queryRecords(Util.NS+'Q2IO_Mapping__mdt') ){

    //         // #16015, update only field update flag set to be true
    //         if (checkUpdateFlag && !fieldMapper.update__c) continue;

    //         if( fieldMapper.default__c && !checkUpdateFlag) {
    //             io.put( fieldMapper.IO_Field__c, fieldMapper.default_value__c);

    //         } else if ( String.isNotBlank(fieldMapper.Opportunity_Field__c)){

    //             //Get from Cache, avoid requery
    //             Opportunity opp = (Opportunity) Util.getCache(quote.OpportunityId );
    //             io.put( fieldMapper.IO_Field__c , opp.get(fieldMapper.Opportunity_Field__c) );

    //         }else if ( String.isNotBlank(fieldMapper.Media_Plan_Field__c) ) {

    //             Opportunity opp = (Opportunity) Util.getCache(quote.OpportunityId );
    //             if(opp.Media_Plan__c != null) {
    //                 Media_Plan__c mediaPlan = (Media_Plan__c) Util.getCache( opp.Media_Plan__c);
    //                 io.put( fieldMapper.IO_Field__c , mediaPlan.get(fieldMapper.Media_Plan_Field__c) );
    //             }

    //         }else if ( String.isNotBlank(fieldMapper.Quote_Field__c) ) {
                
    //             io.put( fieldMapper.IO_Field__c , quote.get(fieldMapper.Quote_Field__c) );
    //         }
    //     }
    //     return io;
    // }
    // /**
    //  *  Related to Task #16012, #16015
    //  *  Convert Quote line item to IO line item defined in custom metadata type
    //  */
    // public static IO_LineItem__c convertQuoteLIToIOLineItem(QuoteLineItem  qli, Boolean checkUpdateFlag) {
    //     IO_LineItem__c IOLineItem = new IO_LineItem__c();
    //     for(QLI2IOLI_Mapping__mdt fieldMapper: (List<QLI2IOLI_Mapping__mdt>) QueryUtil.queryRecords(Util.NS+'QLI2IOLI_Mapping__mdt')) {

    //         // #16015, update only field update flag set to be true
    //         if (checkUpdateFlag && !fieldMapper.update__c) continue;

    //         //System.debug('#### fieldMapper' + fieldMapper);
    //         //kSystem.debug('#### fieldMapper - val ' + qli.get( fieldMapper.Quote_LineItem_Field__c ));

    //         Object val = fieldMapper.Default__c && !checkUpdateFlag ? fieldMapper.Default_Value__c : qli.get( fieldMapper.Quote_LineItem_Field__c );
    //         IOLineItem.put(fieldMapper.IO_LineItem_Field__c, val);
    //     }
    //     return IOLineItem;
    // }

    // public static void setQliFieldToIOli(QuoteLineItem qli, IO_LineItem__c IOLineItem , Set<String> fieldsToUpdate ){
    //     for(QLI2IOLI_Mapping__mdt fieldMapper: (List<QLI2IOLI_Mapping__mdt>) QueryUtil.queryRecords(Util.NS+'QLI2IOLI_Mapping__mdt', 'Quote_LineItem_Field__c IN:value1', new Map<String,Object>{'value1'=>fieldsToUpdate} )) {
    //         IOLineItem.put(fieldMapper.IO_LineItem_Field__c, qli.get( fieldMapper.Quote_LineItem_Field__c ));
    //     }
    // }

    // /**
    //  *  Task #16012: Create IO and IO line item from Quote and Quote Line Item
    //  */
    // public static Id createIOFromQuote(Id quoteId){
    //     Quote quote=(Quote) QueryUtil.queryRecordsWithChildren('Quote',null,'QuoteLineItems',new Set<String>{quoteId}).get(0);
    //     IO__c io = GW_IO.convertQuoteToIO(quote, false);
    //     WithoutSharing.doInsert(new List<sObject>{io});
        
    //     Map<Id, IO_LineItem__c> mapQliId2IOLineItems = new Map<Id, IO_LineItem__c>();
    //     for( QuoteLineItem quoteOli : Quote.QuoteLineItems) {
    //         IO_LineItem__c IOLineItem = GW_IO.convertQuoteLIToIOLineItem(quoteOli, false);
    //         IOLineItem.IO__c = io.id;
    //         mapQliId2IOLineItems.put(quoteOli.id, IOLineItem);
    //     }
    //     WithoutSharing.doInsert(mapQliId2IOLineItems.values());

    //     List<IO_LineItem_Junction__c> junctions = GW_IO_LineItem_Junction.getIOLineItemJunction(Quote.QuoteLineItems, mapQliId2IOLineItems);
    //     WithoutSharing.doInsert(junctions);
        
    //     quote.IO__c = io.id;
    //     WithoutSharing.doUpdate(new List<sObject>{quote});
    //     return io.Id;
    // }

    // //change history : AMT, Deprecated, Task #21557, change inside logic.
    // /* 
    //     Once IO link to a new Opp
    //     - clone last quote, quote line item, media plan of quote
    //     - link clone record to IO and Opp
    //     - create IOJunction
    // */
    // /*
    // public static void revisionIO(Id ioId, Id oppId){
    //     Opportunity opp = (Opportunity) QueryUtil.queryRecord(oppId);
    //     IO__c io = (IO__c) QueryUtil.queryRecord(ioId);
    //     if(opp.IO__c!=null) throw new ExceptionGroup.customException(Label.ERR_REVISION_IO_OPP_ALREADY_LINKED);

        
    //     Map<Id, Quote> mOldQuoteId2NewRecord = new Map<Id, Quote>();
    //     Map<Id, QuoteLineItem> mapOldQliId2NewRecord = new Map<Id, QuoteLineItem>();
    //     Map<Id, Media_Plan__c> mOldMPId2NewRecord = new Map<Id, Media_Plan__c>();
    //     Map<Id, Targeting__c> mOldTgId2NewRecord = new Map<Id, Targeting__c>();
        
    //     List<Quote> quotes = (List<Quote>) QueryUtil.queryRecords('Quote', Util.NS+'IO__c=:value1 ORDER BY CreatedDate DESC',new Set<String>{Util.NS+'Media_Plan__r.Name'}, new Map<String,Object>{'value1'=>io.Id});
    //     if( quotes.isEmpty() ) throw new ExceptionGroup.CustomException(Label.ERR_NO_QUOTE_LINKED_TO_IO);
        
    //     Quote lastRevisionQuote = quotes.get(0);
    //     Quote originQuote = quotes.get( quotes.size()-1 );

    //     for(Media_Plan__c mp: (List<Media_Plan__c>) QueryUtil.queryRecords(Util.NS+'Media_Plan__c', new Set<String>{lastRevisionQuote.Media_Plan__c})){
    //         Media_Plan__c newMp = mp.clone();
    //         newMp.Name = originQuote.Media_Plan__r.Name +' .V' + quotes.size();
    //         newMp.Opportunity__c = opp.Id;
    //         mOldMPId2NewRecord.put(mp.Id, newMp);
    //     }
    //     WithoutSharing.doInsert(mOldMPId2NewRecord.values());

    //     Map<Id, Quote> cloningQuote = new Map<Id,Quote>(new List<Quote>{lastRevisionQuote});
    //     for(Quote quote: cloningQuote.values()){
    //         Quote newQuote =quote.clone();
    //         newQuote.OpportunityId = opp.Id;
    //         newQuote.IO__c = io.Id;
    //         newQuote.Name = originQuote.Name +' .V' + quotes.size();
    //         // replace newly create record id
    //         if(mOldMPId2NewRecord.get(quote.Media_Plan__c)!=null) newQuote.Media_Plan__c = mOldMPId2NewRecord.get(quote.Media_Plan__c).Id;
    //         mOldQuoteId2NewRecord.put(quote.id, newQuote);

    //     }
    //     WithoutSharing.doInsert(mOldQuoteId2NewRecord.values());

    //     Set<String> oldTargetingIds = new Set<String>();
    //     Map<Id,QuoteLineItem> oldQlis = new Map<Id,QuoteLineItem>((List<QuoteLineItem>)QueryUtil.queryRecords('QuoteLineItem', 'QuoteId IN:value1', new Set<String>{'Quote.'+Util.NS+'IO__c','PricebookEntry.UnitPrice', 'Product2.'+Util.NS+'Billing_Category__c'}, new Map<String,Object>{'value1'=>cloningQuote.keySet()}));
    //     for(QuoteLineItem qli: oldQlis.values()){
    //         oldTargetingIds.add(qli.Targeting__c);
    //     }
    //     mOldTgId2NewRecord = GW_Targeting.copyTargeting(oldTargetingIds);

    //     Map<Id, IO_LineItem__c> mapQliId2IOLineItem = GW_QuoteLineItem.getMapQliId2IOline(oldQlis.values());
    //     for(QuoteLineItem qli: oldQlis.values()){
    //         QuoteLineItem newQli = qli.clone();
    //         if(mOldTgId2NewRecord.containsKey(qli.Targeting__c)) newQli.Targeting__c = mOldTgId2NewRecord.get(qli.Targeting__c).Id;
    //          newQli.QuoteId = mOldQuoteId2NewRecord.get(qli.QuoteId).Id;
    //          newQli.Quantity = mapQliId2IOLineItem.get(qli.Id).Roll_up_Summary_Total_Quantity__c;
    //          newQli.SalesPriceNet__c = mapQliId2IOLineItem.get(qli.Id).SalesPriceNet__c;
    //          newQli.Budget__c = newQli.SalesPriceNet__c * (GW_QuoteLineItem.isCPM(qli) ? newQli.Quantity__c/1000 : newQli.Quantity__c); //newQli.Budget__c = newQli.SalesPriceNet__c * (GW_QuoteLineItem.isCPM(qli) ? newQli.Quantity/1000 : newQli.Quantity);
    //         mapOldQliId2NewRecord.put(qli.id, newQli);
    //     }
    //     WithoutSharing.doInsert(mapOldQliId2NewRecord.values());

    //     List<IO_LineItem_Junction__c> junctions = GW_IO_LineItem_Junction.getRevisionIOLineItemJunction(mapOldQliId2NewRecord);
    //     WithoutSharing.doInsert(junctions);

    //     if(!mOldMPId2NewRecord.values().isEmpty())  opp.Media_Plan__c =mOldMPId2NewRecord.values().get(0).Id;
    //     opp.IO__c = io.Id;
    //     WithoutSharing.doUpdate(new Opportunity[]{opp});
    // }
    // */
	
	// /*
	// @ Change history: 
	// *	26-June-2019 : AMT, Task #21556, 2- Update "Create Media Plan Request" Button on Opportunity
	// *						Task #21557, 3- Auto create Revision Quote whenever Revision MPR is created
	// */
    // public static Map<String, Object> revisionIO(Id ioId, Id oppId){
    // 	// add new map of return result.
    // 	Map<String, Object> mapResult = new Map<String, Object>();
    	
    //     Opportunity opp = (Opportunity) QueryUtil.queryRecord(oppId);
    //     IO__c io = (IO__c) QueryUtil.queryRecord(ioId);
    //     if (io == null) io = new IO__c();
    //     // Deprecated, Task #21557, Opportunity can link to other IO
    //     //if(opp.IO__c!=null) throw new ExceptionGroup.customException(Label.ERR_REVISION_IO_OPP_ALREADY_LINKED);
        
    //     Map<Id, Quote> mOldQuoteId2NewRecord = new Map<Id, Quote>();
    //     Map<Id, QuoteLineItem> mapOldQliId2NewRecord = new Map<Id, QuoteLineItem>();
    //     Map<Id, Media_Plan__c> mOldMPId2NewRecord = new Map<Id, Media_Plan__c>();
    //     Map<Id, Targeting__c> mOldTgId2NewRecord = new Map<Id, Targeting__c>();
        
    //     List<Quote> quotes = (List<Quote>) QueryUtil.queryRecords('Quote', Util.NS+'IO__c=:value1 ORDER BY CreatedDate DESC',new Set<String>{Util.NS+'Media_Plan__r.Name'}, new Map<String,Object>{'value1'=>io.Id});
    //     if( quotes.isEmpty() ) throw new ExceptionGroup.CustomException(Label.ERR_NO_QUOTE_LINKED_TO_IO);
        
    //     Quote lastRevisionQuote = quotes.get(0);
    //     Quote originQuote = quotes.get( quotes.size()-1 );

    //     for(Media_Plan__c mp: (List<Media_Plan__c>) QueryUtil.queryRecords(Util.NS+'Media_Plan__c', new Set<String>{lastRevisionQuote.Media_Plan__c})){
    //         Media_Plan__c newMp = mp.clone();
    //         newMp.Name = originQuote.Media_Plan__r.Name +'. V' + (quotes.size()+1);
    //         newMp.Opportunity__c = opp.Id;
    //         newMp.IsRevision__c = true;
    //         newMp.Media_Plan_Stage__c = 'New';
    //         newMp.OwnerId = UserInfo.getUserId();
    //         mOldMPId2NewRecord.put(mp.Id, newMp);
    //     }
    //     WithoutSharing.doInsert(mOldMPId2NewRecord.values());
        
    //     // @AMT : put result of media_plan, for redirect purpose.
    //     if(mOldMPId2NewRecord.get(lastRevisionQuote.Media_Plan__c) != null){
    //      	mapResult.put('mpid', mOldMPId2NewRecord.get(lastRevisionQuote.Media_Plan__c).Id);
    //     }
        
    //     Map<Id, Quote> cloningQuote = new Map<Id,Quote>(new List<Quote>{lastRevisionQuote});
    //     for(Quote quote: cloningQuote.values()){
    //         Quote newQuote =quote.clone();
    //         newQuote.OpportunityId = opp.Id;
    //         newQuote.IO__c = io.Id;
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
    //     }
    //     mOldTgId2NewRecord = GW_Targeting.copyTargeting(oldTargetingIds);

    //     Map<Id, IO_LineItem__c> mapQliId2IOLineItem = GW_QuoteLineItem.getMapQliId2IOline(oldQlis.values());
    //     for(QuoteLineItem qli: oldQlis.values()){
    //         QuoteLineItem newQli = qli.clone();
    //         if(mOldTgId2NewRecord.containsKey(qli.Targeting__c)) newQli.Targeting__c = mOldTgId2NewRecord.get(qli.Targeting__c).Id;
    //          newQli.QuoteId = mOldQuoteId2NewRecord.get(qli.QuoteId).Id;
    //          newQli.Quantity__c = mapQliId2IOLineItem.get(qli.Id) == null ? 0 : mapQliId2IOLineItem.get(qli.Id).Roll_up_Summary_Total_Quantity__c;
    //          newQli.SalesPriceNet__c = mapQliId2IOLineItem.get(qli.Id) == null ? 0 : mapQliId2IOLineItem.get(qli.Id).SalesPriceNet__c;
    //          //newQli.Budget__c = newQli.SalesPriceNet__c * (GW_QuoteLineItem.isCPM(qli) ? newQli.Quantity__c/1000 : newQli.Quantity__c); //newQli.Budget__c = newQli.SalesPriceNet__c * (GW_QuoteLineItem.isCPM(qli) ? newQli.Quantity/1000 : newQli.Quantity);
    //          newQli.Budget__c = qli.Budget__c; //MN-17092019 - As discussed with Tenzin we won't calculated it and copy from Original QLI instead
    //         mapOldQliId2NewRecord.put(qli.id, newQli);
    //     }
    //     WithoutSharing.doInsert(mapOldQliId2NewRecord.values());

    //     List<Quote> initValues = new List<Quote>();
    //     for(Quote quote: mOldQuoteId2NewRecord.values()){
    //         Quote initQuote = new Quote(Id = quote.Id);
    //         //GW_Quote.applyInitValue(initQuote);
    //         initValues.add(initQuote);
    //     }
    //     WithoutSharing.doUpdate(initValues);

    //     List<IO_LineItem_Junction__c> junctions = GW_IO_LineItem_Junction.getRevisionIOLineItemJunction(mapOldQliId2NewRecord);
    // 	// 28-June-2019 : AMT, revision io lineitem junction price and qty will set to 0;
    // 	for(IO_LineItem_Junction__c sIOLIJ : junctions){
    //         sIOLIJ.Quote_LineItem_Total_Price__c = 0;
    //         sIOLIJ.Total_Quote_Line_Item_Quantity__c = 0;
    //     }
        
    //     WithoutSharing.doInsert(junctions);

    //     if(!mOldMPId2NewRecord.values().isEmpty())  opp.Media_Plan__c =mOldMPId2NewRecord.values().get(0).Id;
    //     opp.IO__c = io.Id;
    //     WithoutSharing.doUpdate(new Opportunity[]{opp});
        
    //     // End return result
    //     return mapResult;
    // }
	
    // public static void createNotExistIOLineItemAndJuntion(List<QuoteLineItem> newQlis, Id targetIoId){
    //     Map<Id, IO_LineItem__c> mapQliId2IOLineItems = new Map<Id, IO_LineItem__c>();
    //     List<QuoteLineItem> qliToCreateJunction = new List<QuoteLineItem>();
    //     for(QuoteLineItem qli : newQlis){
    //         IO_LineItem__c IOLineItem = GW_IO.convertQuoteLIToIOLineItem(qli, false);
    //         mapQliId2IOLineItems.put(qli.Id, IOLineItem);
    //         IOLineItem.IO__c = targetIoId;
    //         qliToCreateJunction.add(qli);
    //     }
    //     WithoutSharing.doInsert(mapQliId2IOLineItems.values());
    //     List<IO_LineItem_Junction__c> junctions = GW_IO_LineItem_Junction.getIOLineItemJunction(qliToCreateJunction, mapQliId2IOLineItems);
    //     WithoutSharing.doInsert(junctions);
    // }

    // /**
    //  * Relate to #16014: map IO field to  Ad Campaign field
    //  **/
    // static Ad_Campaign__c convertIOToAdCampaign(IO__c io){
    //     Ad_Campaign__c adCampaign = new Ad_Campaign__c(IO__c = io.Id);

    //     for(IO2AdCampaign_Mapping__mdt fieldMapper : (List<IO2AdCampaign_Mapping__mdt>) QueryUtil.queryRecords(Util.NS+'IO2AdCampaign_Mapping__mdt') ){
    //         Object val = fieldMapper.default__c ? fieldMapper.default_value__c : io.get(fieldMapper.IO_Field__c);
    //         adCampaign.put( fieldMapper.Ad_Campaign_Field__c, val);
    //     }
    //     return adCampaign;
    // }
	
	// static List<FMRS__c> generateRSMonthly(Opportunity opp){
	// 	List<FMRS__c> fmrsMonthlys = new List<FMRS__c> ();
		
	// 	Date startDate = opp.Start_Date__c.toStartOfMonth();
	// 	Integer totalMonth = startDate.monthsBetween(opp.End_Date__c);
		
	// 	for(Integer m = 0; m <= totalMonth; m++) {
    //         Date rsDate = startDate.addMonths(m).toStartOfMonth();
    //         if( rsDate >= opp.Start_Date__c.toStartOfMonth() && rsDate <= opp.End_Date__c.toStartOfMonth() ){
    //             FMRS__c rsMonthly = new FMRS__c();
    //             rsMonthly.Opportunity__c = opp.Id;
    //             rsMonthly.Date__c = rsDate;
    //             rsMonthly.UniqueKey__c = GW_IO.getRSMonthlyUniqueKey(rsMonthly);
    //             fmrsMonthlys.add(rsMonthly);
    //         }
    //     }
		
	// 	return fmrsMonthlys;
	// }
	
	// static List<FDRS__c> generateRSDaily(FMRS__c fmrsMonthly, Opportunity opp){
	// 	List<FDRS__c> fmrsDailys = new List<FDRS__c> ();
		
	// 	Integer year = Integer.valueOf(fmrsMonthly.Date__c.year());
    //     Integer month = Integer.valueOf(fmrsMonthly.Date__c.month());
    //     Integer daysOfMonth = Date.daysInMonth( year, month);
        
    //     Integer startDay = Date.newInstance( year, month, 1) > opp.Start_Date__c ? 1 : opp.Start_Date__c.day();
    //     Integer endDay = Date.newInstance( year, month, daysOfMonth) < opp.End_Date__c ? daysOfMonth : opp.End_Date__c.day();
        
	// 	Decimal dayAmount = UTIL.getDecimalNotNull(opp.Amount) / (opp.Start_Date__c.daysBetween(opp.End_Date__c) + 1);
		
    //     for(Integer day = startDay; day <= endDay; day++) {
    //         FDRS__c fdrs = new FDRS__c();
    //         fdrs.FMRS__c = fmrsMonthly.Id;
    //         fdrs.Opportunity__c = opp.Id;
    //         fdrs.Amount__c = dayAmount;
    //         fdrs.Date__c = Date.newInstance( year, month, day);
    //         fdrs.UniqueKey__c = GW_IO.getRSDailyUniqueKey(fdrs);
    //         fmrsDailys.add(fdrs);
    //     }
		
	// 	return fmrsDailys;
	// }
	
    // static List<Revenue_Schedules_Monthly__c> generateRSMonthly(List<IO_LineItem__c> IOLineItems){
    //     List<Revenue_Schedules_Monthly__c> lstRSMonthly = new List<Revenue_Schedules_Monthly__c> ();
    //     for(IO_LineItem__c IOLineItem: IOLineItems) {

    //         if(IOLineItem.from_Date__c==null || IOLineItem.until_Date__c==null || String.isBlank(IOLineItem.IO__r.Ad_Campaign__c) ) continue;

    //         Date startDate =IOLineItem.from_Date__c.toStartOfMonth();
    //         Integer totalMonth = startDate.monthsBetween(IOLineItem.until_Date__c);
            
    //         for(Integer m = 0; m <= totalMonth; m++) {
    //             Date RSDate = startDate.addMonths(m).toStartOfMonth();
    //             if( RSDate >= IOLineItem.from_Date__c.toStartOfMonth() && RSDate <= IOLineItem.until_Date__c.toStartOfMonth() ){
    //                 Revenue_Schedules_Monthly__c RSMonthly = new Revenue_Schedules_Monthly__c();
    //                 RSMonthly.Campaign_Year__c = String.valueOf(RSDate.year());
    //                 RSMonthly.Campaign_Month__c = String.valueOf(RSDate.month());
    //                 RSMonthly.Product__c = IOLineItem.Product__c;
    //                 RSMonthly.Ad_Campaign__c = IOLineItem.IO__r.Ad_Campaign__c;
    //                 RSMonthly.IO_LineItem__c = IOLineItem.id;
    //                 RSMonthly.Unique_Key__c = GW_IO.getRSMonthlyUniqueKey( RSMonthly);
    //                 lstRSMonthly.add(RSMonthly);
    //             }
    //         }
    //     }
    //     return lstRSMonthly;
    // }
    // /**
    //  * Relate to #16014: generate Revenue Schedules Daily for each Revenue Schedules Monthly depends IO line item start and end date
    //  **/
    // static List<RS_Daily__c> generateRSDaily(Revenue_Schedules_Monthly__c RSMonthly, IO_LineItem__c IOLineItem){
    //     List<RS_Daily__c> lstRSDaily = new List<RS_Daily__c>();
    //     Integer year = Integer.valueOf(RSMonthly.Campaign_Year__c);
    //     Integer month = Integer.valueOf(RSMonthly.Campaign_Month__c);
    //     Integer daysOfMonth = Date.daysInMonth( year, month);
        
    //     Integer startDate = Date.newInstance( year, month, 1) > IOLineItem.from_Date__c ? 1: IOLineItem.from_Date__c.day();
    //     Integer endDate = Date.newInstance( year, month, daysOfMonth) < IOLineItem.until_Date__c ? daysOfMonth : IOLineItem.until_Date__c.day();
        
    //     for(Integer day = startDate; day <= endDate; day++) {
    //         RS_Daily__c RSDaily = new RS_Daily__c();
    //         RSDaily.Revenue_Schedule_Monthly__c = RSMonthly.id;
    //         RSDaily.Ad_Campaign__c = RSMonthly.Ad_Campaign__c;
    //         RSDaily.Sale_Price__c = IOLineItem.Sale_Price__c;
    //         //Added by Mani // 
    //         RSDaily.Sale_Price_Net__c=IOLineItem.SalesPriceNet__c;
    //         //Added by Mani//
    //         RSDaily.Contracted_Unit__c=IOLineItem.Roll_up_Summary_Total_Quantity__c;
    //         RSDaily.Product__c = RSMonthly.Product__c;
    //         RSDaily.Date__c = Date.newInstance( year, month, day);
    //         RSDaily.Unique_Key__c = GW_IO.getRSDailyUniqueKey(RSDaily);
    //         lstRSDaily.add(RSDaily);
    //     }
    //     return lstRSDaily;
    // }

    // //public static void updateIOliFromQli(List<QuoteLineItem> qlis, Set<String> fieldsToUpdate){
    // //    if(qlis.isEmpty()) return;

    // //    Set<Id> quoteIds = new Set<Id>();
    // //    for(QuoteLineItem qli :qlis) quoteIds.add(qli.QuoteId);

    // //    List<IO_LineItem__c> linkedIOlis = (List<IO_LineItem__c>) QueryUtil.queryRecords(Util.NS+'IO_LineItem__c',' IO__C IN (SELECT IO__c FROM Quote WHERE Id IN:value1 AND IO__C<>null )', new Set<String>{'IO__r.Ad_Campaign__c'}, new Map<String,Object>{'value1'=> quoteIds});
    // //    List<IO_LineItem__c> IOlis = new List<IO_LineItem__c>();
    // //    Map<Id, IO_LineItem__c> proId2IOlineItem = new Map<Id, IO_LineItem__c>();
    // //    for(IO_LineItem__c IOLineItem: linkedIOlis) {
    // //        proId2IOlineItem.put(IOLineItem.Product__c, IOLineItem );
    // //    }
    // //    for(QuoteLineItem qli : qlis ){
    // //        if( !proId2IOlineItem.containsKey(qli.Product2Id) ) continue;

    // //        IO_LineItem__c IOli = proId2IOlineItem.get(qli.Product2Id);
    // //        GW_IO.setQliFieldToIOli( qli, IOli , fieldsToUpdate);
    // //        IOlis.add(IOli);
    // //    }
    // //    if( IOlis.isEmpty() ) return;

    // //    update IOlis;
    // //    GW_IO.RevenueScheduleCreator RSCreator = new GW_IO.RevenueScheduleCreator(linkedIOlis);
    // //    RSCreator.createNonExisting();
    // //}

    // public static void setTargetingToIOLine(List<QuoteLineItem> qlis){
    //     if(qlis.isEmpty()) return;

    //     Set<Id> quoteIds = new Set<Id>();
    //     for(QuoteLineItem qli :qlis){
    //         quoteIds.add(qli.QuoteId);
    //     }

    //     Map<Id, IO_LineItem__c> proId2IOlineItemId = new Map<Id, IO_LineItem__c>();
    //     for(IO_LineItem__c IOLineItem: (List<IO_LineItem__c>) QueryUtil.queryRecords(Util.NS + 'IO_LineItem__c',Util.NS + 'IO__C in (SELECT '+ Util.NS +'IO__C FROM Quote WHERE Id IN:value1)', new Map<String,Object>{'value1'=>quoteIds})) {
    //         proId2IOlineItemId.put(IOLineItem.Product__c, IOLineItem );
    //     }

    //     List<IO_LineItem__c> IOlines = new List<IO_LineItem__c>();
    //     for(QuoteLineItem qli :qlis){
    //         IO_LineItem__c IOLine = proId2IOlineItemId.get(qli.Product2Id);
    //         if( IOLine!=null && IOLine.Targeting__c==null ) IOlines.add(new IO_LineItem__c( Id=IOLine.Id, Targeting__c=qli.Targeting__c));
    //     }

    //     update IOlines;
    // }

    // //public static void createNonExistingRSDailyAndMonthly(List<IO_LineItem__c> IOlines){
    // //    GW_IO.RevenueScheduleCreator RSCreator = new GW_IO.RevenueScheduleCreator( 
    // //        (List<IO_LineItem__c>) QueryUtil.queryRecords(Util.NS + 'IO_LineItem__c', 'Id in :value1', new Set<String>{'IO__r.Ad_Campaign__c'}, new Map<String,Object>{'value1'=>new Map<Id,IO_LineItem__c>(IOlines).keySet()}));
    // //    RSCreator.createNonExisting();
    // //}

    // //Added by Mony 
    // public static void createRSDailyAndMonthly (Set<Id> sIO) {
        
    //     if (sIO.isEmpty()) return;

    //     //filtering to keep only IO that has dual signed
    //     for ( IO__c io : (List<IO__c>) QueryUtil.queryRecords(Util.NS+'IO__c', 'Id IN:value1 ', new Set<String>{}, new Map<String,Object>{'value1'=>sIO}) ) {
    //         if (!io.Dually_Signed_IO__c) sIO.remove(io.Id);
    //     }

    //     if (sIO.isEmpty()) return;

    //     List<IO_Revenue_Schedule_Monthly__c> rsMonthly2Upsert = new List<IO_Revenue_Schedule_Monthly__c>();
    //     Map<Id, IO_LineItem__c> mIOLI = new Map<Id, IO_LineItem__c>();

    //     //new Set<String>{Util.NS + 'Product__c', Util.NS + 'from_Date__c', Util.NS + 'until_Date__c', Util.NS + 'Total_Price__c'}

    //     //Query all IOLI based on the above filtered IO
    //     for ( IO_LineItem__c ioli : (List<IO_LineItem__c>) QueryUtil.queryRecords(Util.NS+'IO_LineItem__c', Util.NS+'IO__c IN:value1 ', new Set<String>{Util.NS+'IO__r.'+Util.NS+'Most_Recent_Opportunity__c'}, new Map<String,Object>{'value1'=>sIO}) ) {
            
    //         if( ioli.from_Date__c==null || ioli.until_Date__c==null ) continue;

    //         rsMonthly2Upsert.addAll(GW_IO.generateRSMonthly(ioli));
    //         mIOLI.put(ioli.Id, ioli);
    //     }

    //     if(!rsMonthly2Upsert.isEmpty()) {
    //         WithoutSharing.doUpsert(rsMonthly2Upsert);
    //         /* MN-10092019 - Temporary Disable
    //         List<IO_Revenue_Schedule_Daily__c> rsDaily2Upsert = new List<IO_Revenue_Schedule_Daily__c>();

    //         for(IO_Revenue_Schedule_Monthly__c rsMonthly : rsMonthly2Upsert){
    //             IO_LineItem__c ioli = mIOLI.get(rsMonthly.IO_LineItem__c);
    //             rsDaily2Upsert.addAll(GW_IO.generateRSDaily(rsMonthly, ioli));    
    //         }
            
    //         if(!rsDaily2Upsert.isEmpty()) WithoutSharing.doUpsert(rsDaily2Upsert);
    //         */
    //         WithoutSharing.doDelete([SELECT id FROM IO_Revenue_Schedule_Monthly__c WHERE Id NOT IN :rsMonthly2Upsert AND IO_LineItem__c IN :mIOLI.keySet()]);
    //         /* MN-10092019 - Temporary Disable
    //         WithoutSharing.doDelete([SELECT id FROM IO_Revenue_Schedule_Daily__c WHERE Id NOT IN :rsDaily2Upsert AND IO_LineItem__c IN :mIOLI.keySet()]);
    //         */
    //     }
        

    // }
    // //Added by Mony 
    
    // static List<IO_Revenue_Schedule_Monthly__c> generateRSMonthly(IO_LineItem__c ioli){

    //     List<IO_Revenue_Schedule_Monthly__c> rsMonthlys = new List<IO_Revenue_Schedule_Monthly__c> ();
        
    //     Date startDate = ioli.from_Date__c.toStartOfMonth();
    //     Integer totalMonth = startDate.monthsBetween(ioli.until_Date__c);

    //     Decimal dayAmount = ioli.Total_Price__c / (ioli.from_Date__c.daysBetween(ioli.until_Date__c) + 1);
        
    //     for(Integer m = 0; m <= totalMonth; m++) {
    //         Date rsDate = startDate.addMonths(m).toStartOfMonth();
    //         if( rsDate >= ioli.from_Date__c.toStartOfMonth() && rsDate <= ioli.until_Date__c.toStartOfMonth() ){
    //             IO_Revenue_Schedule_Monthly__c rsMonthly = new IO_Revenue_Schedule_Monthly__c();
    //             rsMonthly.IO__c             = ioli.IO__c;
    //             rsMonthly.IO_LineItem__c    = ioli.Id;
    //             rsMonthly.Product__c        = ioli.Product__c;
    //             rsMonthly.Date__c           = rsDate;
    //             rsMonthly.Unique_Key__c     = GW_IO.getRSMonthlyUniqueKey(rsMonthly);
    //             rsMonthly.Opportunity__c    = ioli.IO__r.Most_Recent_Opportunity__c;
    //             Decimal mAmount = dayAmount * getDaysPerMonth(rsDate, ioli.from_Date__c, ioli.until_Date__c);
    //             rsMonthly.Amount_Currency__c = mAmount;

    //             rsMonthlys.add(rsMonthly);
    //         }
    //     }
        
    //     return rsMonthlys;
    // }

    // //Added by Mony (This method is need for now because we disable the IOLI Daily Revenue Schedule logic)
    // static private Integer getDaysPerMonth (Date startOfMonth, Date ioliStartDate, Date ioliEndDate) {

    //     /*Find the exact number of days for IOLI.StartDate.StartMonth and IOLI.EndDate.StartMonth. The months in between will be get full days/month
    //         EX: IOLI.StartDate = 15/Sep/2019 -> IOLI.EndDate = 15/Nov/2019 => 
    //             - September = 15 days (need to calculate the exact number of days)
    //             - October = 31 days (full no need to calculate)
    //             - November = 15 days (need to calculate the exact number of days)
    //     */

    //     Integer numOfDays = 0;
    //     Integer daysInMonth = Date.daysInMonth(startOfMonth.year(), startOfMonth.month());
    //     Date endOfMonth = Date.newInstance(startOfMonth.year(), startOfMonth.month(), daysInMonth);

    //     //Check if IOLI.StartDate is the same month as IOLI.EndDate
    //     if (ioliStartDate.month() == ioliEndDate.month()) numOfDays = ioliStartDate.daysBetween(ioliEndDate) + 1;
    //     //Check if it is the StartMonth of IOLI.StartDate
    //     else if (startOfMonth.month() == ioliStartDate.month()) numOfDays = ioliStartDate.daysBetween(endOfMonth) + 1;
    //     //Check if it is the StartMonth of IOLI.EndDate
    //     else if (startOfMonth.month() == ioliEndDate.month()) numOfDays = startOfMonth.daysBetween(ioliEndDate) + 1;
    //     //For middle months
    //     else numOfDays = startOfMonth.daysBetween(endOfMonth) + 1;
        
    //     return numOfDays;

    // }

    // //Added by Mony 
    // static List<IO_Revenue_Schedule_Daily__c> generateRSDaily(IO_Revenue_Schedule_Monthly__c rsMonthly, IO_LineItem__c ioli){

    //     List<IO_Revenue_Schedule_Daily__c> rsDailys = new List<IO_Revenue_Schedule_Daily__c> ();
        
    //     Integer year = Integer.valueOf(rsMonthly.Date__c.year());
    //     Integer month = Integer.valueOf(rsMonthly.Date__c.month());
    //     Integer daysOfMonth = Date.daysInMonth( year, month);
        
    //     Integer startDay = Date.newInstance( year, month, 1) > ioli.from_Date__c ? 1 : ioli.from_Date__c.day();
    //     Integer endDay = Date.newInstance( year, month, daysOfMonth) < ioli.until_Date__c ? daysOfMonth : ioli.until_Date__c.day();
        
    //     Decimal dayAmount = ioli.Total_Price__c / (ioli.from_Date__c.daysBetween(ioli.until_Date__c) + 1);
        
    //     for(Integer day = startDay; day <= endDay; day++) {
    //         IO_Revenue_Schedule_Daily__c rsDaily = new IO_Revenue_Schedule_Daily__c();
    //         rsDaily.Revenue_Schedule_Monthly__c = rsMonthly.Id;
    //         rsDaily.IO__c = ioli.IO__c;
    //         rsDaily.IO_LineItem__c = ioli.Id;
    //         rsDaily.Amount__c = dayAmount;
    //         rsDaily.Date__c = Date.newInstance( year, month, day);
    //         rsDaily.Unique_Key__c = GW_IO.getRSDailyUniqueKey(rsDaily);
    //         rsDailys.add(rsDaily);
    //     }
        
    //     return rsDailys;
    // }
    
    // public static void createRSDailyAndMonthly(Opportunity opp){
		
	// 	List<FDRS__c> fdrs2Insert = new List<FDRS__c>();
    // 		List<FDRS__c> fmrs2Insert = new List<FDRS__c>();
    		
    		
    		
    // 		if(fdrs2Insert.isEmpty()) WithoutSharing.doInsert(fdrs2Insert);
    // 		if(fmrs2Insert.isEmpty()) WithoutSharing.doInsert(fmrs2Insert);
    // }

    // public static void createRSDailyAndMonthly(List<IO_LineItem__c> IOlines){
    //     if(IOlines.isEmpty()) return;
    //     Set<String> IOIds = new Set<String>();
    //     for(IO_LineItem__c IOLine :IOlines){
    //         IOIds.add(IOLine.IO__c);
    //     }
    //     Map<Id,IO__c> mapIOs = new Map<Id,IO__c>((List<IO__c>) QueryUtil.queryRecords(Util.NS + 'IO__c', IOIds));
    //     List<Ad_Campaign__c> newAdCampaigns = new List<Ad_Campaign__c>();
    //     Set<String> adCampaignIds = new Set<String>();

    //     Map<Id, quote> mapIO2Quote = new Map<Id, quote>();
    //     for(Quote quote : (List<Quote>) QueryUtil.queryRecords('Quote', 
    //                                                         Util.NS+'IO__c IN :value1 ORDER BY CreatedDate ASC LIMIT 1',
    //                                                         new Map<String,Object>{'value1'=>IOIds})){
    //         //Query with ASC, since we need the last created quote
    //         mapIO2Quote.put(quote.IO__c, quote);
    //     }

    //     // Create Ad Campaign for IO in case IO have no Ad Campaign yet
    //     for(IO__c io:  mapIOs.values()) {
    //         if(io.Ad_Campaign__c==null){
    //             Ad_Campaign__c adCampaign = GW_IO.convertIOToAdCampaign(io);
    //             if(mapIO2Quote.containsKey(io.Id)) adCampaign.Media_Plan__c = mapIO2Quote.get(io.Id).Media_Plan__c;
    //             newAdCampaigns.add(adCampaign);
    //         }
    //     }
    //     WithoutSharing.doInsert(newAdCampaigns);
    //     //Link adCampaign back to IO
    //     List<IO__c> IOs = new List<IO__c>(); 
    //     for(Ad_Campaign__c adCampaign : newAdCampaigns) {
    //         IO__c io = mapIOs.get(adCampaign.IO__c); 
    //         io.Ad_Campaign__c = adCampaign.Id;
    //         IOs.add(io);
    //     }
    //     WithoutSharing.doUpdate(IOs);

    //     for(IO__c io:  mapIOs.values()) {
    //         adCampaignIds.add(io.Ad_Campaign__c);
    //     }

    //     //List<Ad_Campaign__c> adCampaigns =  (List<Ad_Campaign__c>) QueryUtil.queryRecords( Util.NS + 'Ad_Campaign__c', adCampaignIds);

    //     String queryCreatedIOlineIds = '(select ' + Util.NS  + 'IO_LineItem__c from ' + Util.NS + 'Revenue_Schedules_Monthly__c where ' + Util.NS + 'Ad_Campaign__c in :value1 )';
    //     List<IO_LineItem__c> IOlinesToCreateRS = (List<IO_LineItem__c>) QueryUtil.queryRecords(Util.NS + 'IO_LineItem__c', 'id not in ' + queryCreatedIOlineIds + ' and id in :value2', new Set<String>{'IO__r.Ad_Campaign__c'}, new Map<String,Object>{'value1'=>adCampaignIds,'value2'=>new Map<Id,IO_LineItem__c>(IOlines).keySet()});
    //     //GW_IO.insertRSDailyAndMonthly(mapIOs, new Map<Id,IO_LineItem__c>(IOlinesToCreateRS), adCampaigns);
    //     new GW_IO.RevenueScheduleCreator( IOlinesToCreateRS).create();
    // }

	// static String getRSMonthlyUniqueKey(FMRS__c fmrs){
    //     return fmrs.Opportunity__c + '_' + fmrs.Date__c.year() + '_' + fmrs.Date__c.month();
    // }

    // static String getRSMonthlyUniqueKey(Revenue_Schedules_Monthly__c RSMonthly){
    //     return RSMonthly.Ad_Campaign__c + '_' + RSMonthly.Product__c + '_' + RSMonthly.IO_LineItem__c + '_' + RSMonthly.Campaign_Year__c + '_' + RSMonthly.Campaign_Month__c;
    // }

    // static String getRSDailyUniqueKey(FDRS__c fdrs){
    //     return fdrs.FMRS__c + '_' + fdrs.Date__c.year() + '_' + fdrs.Date__c.month() + '_' + fdrs.Date__c.day();
    // }
    
    // static String getRSDailyUniqueKey(RS_Daily__c RSDaily){
    //     String uniqueKey = RSDaily.Ad_Campaign__c + '_' + RSDaily.Revenue_Schedule_Monthly__c + '_';
    //     if( RSDaily.Date__c == null ) return uniqueKey;
    //     return  uniqueKey +  RSDaily.Date__c.day();
    // }

    // //Added by Mony
    // static String getRSMonthlyUniqueKey(IO_Revenue_Schedule_Monthly__c RSMonthly){
    //     return RSMonthly.Product__c + '_' + RSMonthly.IO_LineItem__c + '_' + RSMonthly.Date__c.year() + '_' + RSMonthly.Date__c.month();
    // }

    // static String getRSDailyUniqueKey(IO_Revenue_Schedule_Daily__c rsDaily){
    //     return rsDaily.Revenue_Schedule_Monthly__c + '_' + rsDaily.Date__c.year() + '_' + rsDaily.Date__c.month() + '_' + rsDaily.Date__c.day();
    // }

    // public class ApproversHandler {
    // 	// Init in constructor
    // 	Map<String, Approvers__c> mApprovers;
    // 	Map<String, String> mUserName2Id;
    	
    // 	// Init by method
    // 	Map<String, Approvers__c[]> mSortedByType;
    	
    	
    // 	public ApproversHandler() {
    // 		mApprovers = Approvers__c.getAll();
    // 		mUserName2Id = new Map<String, String>();
	//         for(Approvers__c app : mApprovers.values()) {
	//             if(app.UserName__c != null) mUserName2Id.put(app.UserName__c, null);
	//         }
    // 		if(!mUserName2Id.isEmpty()) {
	// 	        for(User u : [select Id, UserName from User where UserName in :mUserName2Id.keyset()]) {
	// 	            mUserName2Id.put(u.UserName, u.Id); 
	// 	        }
    // 		}
    // 	}
    // 	private Approvers__c[] getSortedByType(String typ) {
    // 		if(mSortedByType == null) mSortedByType = new Map<String, List<Approvers__c>>();
    // 		if(!mSortedByType.containskey(typ)) {
    // 			mSortedByType.put(typ, new List<Approvers__c>());
    			
    // 			Map<Decimal, Approvers__c> mapAppr = new Map<Decimal, Approvers__c>();
	// 	        for(Approvers__c s : mApprovers.values()) {
	// 	            if(s.Name.containsIgnoreCase(typ)) {
	// 	                mapAppr.put(s.Amount__c, s);
	// 	            }
	// 	        }
    // 			List<Decimal> keys =  new List<Decimal>();
	// 	        keys.addall(mapAppr.keyset());
	// 	        keys.sort(); // Example: (null, 500, 10000)
		        
	// 	        for(Integer i = keys.size()-1; i >= 0; i--) {
	// 	        	mSortedByType.get(typ).add(mapAppr.get(keys[i]));
	// 	        }
    // 		}
    // 		return mSortedByType.get(typ);
    // 	}
    	
    // 	private Approvers__c getByAmount(Decimal amount, Approvers__c[] apprsSorted) {
    // 		Approvers__c defaultApp;
    // 		Approvers__c matchedApp;
    // 		for(Approvers__c ap : apprsSorted) {
    // 			if(ap.Amount__c == null) {
    // 				defaultApp = ap;
    // 			} else if(amount <= ap.Amount__c ) {
    // 				matchedApp = ap;
    // 			}
    // 		}
    // 		matchedApp = matchedApp == null ? defaultApp : matchedApp;
    // 		return  matchedApp == null ? new Approvers__c() : matchedApp;
    // 	}
    	
    // 	public void setLegal(IO__c io) {
    // 		Approvers__c ap = this.getByAmount(io.Rollup_Summary_Total_Order_Amount__c, this.getSortedByType('Legal Approver'));
    // 		io.Legal_Approver__c = mUserName2Id.get(ap.UserName__c);
    // 	}
    // 	public void setFinance(IO__c io) {
    // 		Approvers__c ap = this.getByAmount(io.Rollup_Summary_Total_Order_Amount__c, this.getSortedByType('Finance Approver'));
    // 		io.Finance_Approver__c = mUserName2Id.get(ap.UserName__c);
    // 	}
    // 	public void setContractSinger(IO__c io) {
    // 		Approvers__c ap = this.getByAmount(io.Rollup_Summary_Total_Order_Amount__c, this.getSortedByType('Contract Signer'));
    // 		io.IO_Contract_Signer__c = mUserName2Id.get(ap.UserName__c);
    // 	}
    // }
    
    // // After update we need to re-select and update it again (as we are working on rollup summary fields)
    // public static void setApprovers(Set<Id> ioIDsNeedApprovers, Set<Id> ioIDsLegal) {
    // 	if(!ioIDsNeedApprovers.isempty() || !ioIDsLegal.isempty()) {
    // 		Set<Id> allIds = new Set<Id>();
    // 		allIds.addall(ioIDsNeedApprovers);
    // 		allIds.addall(ioIDsLegal);
    		
	//     	Map<Id, IO__c> mIOs = new Map<Id, IO__c>([select Rollup_Summary_Total_Order_Amount__c, Legal_Approval_Required__c from IO__c where Id IN :allIds]);
	//     	for(Id id : ioIDsNeedApprovers) {
	//     		IO__c io = mIOs.get(id);
	//     		GW_IO.getApprHDL().setFinance(io);
	//     		GW_IO.getApprHDL().setContractSinger(io);
	//     	}
	//     	for(Id id : ioIDsLegal) {
	//     		IO__c io = mIOs.get(id);
	//     		if(io.Legal_Approval_Required__c == Label.APPROVAL_REQUIRED) GW_IO.getApprHDL().setLegal(io);
	//     	}
	//     	WithoutSharing.doUpdate(mIOs.values());
    // 	}
    // }

    // public static void syncRec(List<IO__c> requiredSyncRecs){
    //     if(requiredSyncRecs.isEmpty()) return ;

    //     List<Opportunity> oppToSyncs = new List<Opportunity>();
    //     String termField =  Util.NS +'IO_Paper__c';
    //     for(Opportunity opp : (List<Opportunity>) QueryUtil.queryRecords('Opportunity', Util.NS+'IO__c IN:value1  ', new Set<String>{Util.NS+'IO__r.'+termField}, new Map<String,Object>{'value1'=> new Map<Id,IO__c>(requiredSyncRecs).values() })  ){
    //         IO__c io = opp.IO__r;
    //         opp.put( termField, io.get(termField) );
    //         oppToSyncs.add(opp);

    //     }

    //     WithoutSharing.doUpdate(oppToSyncs);
    // }


    // public class RevenueScheduleCreator {
    //     Set<String> adCampaignIds = new Set<String>();
    //     List<RS_Daily__c> lstRSDaily = new List<RS_Daily__c>();
    //     List<Revenue_Schedules_Monthly__c> lstRSMonthly = new List<Revenue_Schedules_Monthly__c>();
    //     Map<Id, IO_LineItem__c> mapIOLineItem = new Map<Id, IO_LineItem__c>();
    //     public Boolean deleteShortenRSDailyAndMonthly = false;

    //     public RevenueScheduleCreator(List<IO_LineItem__c> IOlines){
    //         for(IO_LineItem__c IOLineItem: IOlines){
    //             if(isReadyToCreateRS(IOLineItem)){
    //                 mapIOLineItem.put(IOLineItem.Id, IOLineItem);
    //                 adCampaignIds.add(IOLineItem.IO__r.Ad_Campaign__c);
    //             }
    //         }
    //     }
		
	// 	public RevenueScheduleCreator(Opportunity opp){
	// 		this(new List<Opportunity>{opp});				
	// 	}
		
	// 	public RevenueScheduleCreator(List<Opportunity> opps){
			
	// 		List<FMRS__c> fmrs2Upsert = new List<FMRS__c>();
	// 		Map<Id, Opportunity> mapOpps = new Map<Id, Opportunity>();
	// 		for(Opportunity opp : opps){
	// 			fmrs2Upsert.addAll(GW_IO.generateRSMonthly(opp));
	// 			mapOpps.put(opp.Id, opp);	
	// 		}
			
	// 		if(!fmrs2Upsert.isEmpty()) {
	// 			WithoutSharing.doUpsert(fmrs2Upsert);
			
	// 			List<FDRS__c> dailyRS2Upsert = new List<FDRS__c>();
	// 			for(FMRS__c fmrs : fmrs2Upsert){
	// 				Opportunity opp = mapOpps.get(fmrs.Opportunity__c);
	// 				dailyRS2Upsert.addAll(GW_IO.generateRSDaily(fmrs, opp));	
	// 			}
				
	// 			if(!dailyRS2Upsert.isEmpty()) WithoutSharing.doUpsert(dailyRS2Upsert);
				
	// 			WithoutSharing.doDelete([SELECT id FROM FMRS__c WHERE Id NOT IN :fmrs2Upsert AND Opportunity__c IN :mapOpps.keySet()]);
	// 			WithoutSharing.doDelete([SELECT id FROM FDRS__c WHERE Id NOT IN :dailyRS2Upsert AND Opportunity__c IN :mapOpps.keySet()]);
	// 		}
	// 	}

    //     public RevenueScheduleCreator(IO_LineItem__c IOline){
    //         this(new List<IO_LineItem__c>{IOline});
    //     }

    //     private Boolean isReadyToCreateRS(IO_LineItem__c IOLineItem){
    //         return String.isNotBlank(IOLineItem.Ad_Id__c ) && String.isNotBlank(IOLineItem.IO__r.Ad_Campaign__c);
    //     }

    //     public void createNonExisting(){
    //         this.createRSDailyAndMonthly();
    //         this.deleteShortenRSDailyAndMonthly();
    //         this.updateAdCampaignStartEndDate();
    //     }

    //     private void create(){
    //         this.createRSDailyAndMonthly();
    //         this.updateAdCampaignStartEndDate();
    //     }

    //     private void createRSDailyAndMonthly(){
    //         this.createRSMonthly();
    //         // Create revenue schedule daily
    //         for(Revenue_Schedules_Monthly__c RSMonthly: lstRSMonthly) {
    //             IO_LineItem__c IOLineItem = mapIOLineItem.get(RSMonthly.IO_LineItem__c);
    //             lstRSDaily.addAll(GW_IO.generateRSDaily(RSMonthly,IOLineItem ));
    //         }
    //         WithoutSharing.doUpsert(lstRSDaily);
    //     }

    //     private void createRSMonthly(){
    //         lstRSMonthly.addAll(GW_IO.generateRSMonthly(mapIOLineItem.values()));
    //         WithoutSharing.doUpsert(lstRSMonthly);
    //     }

    //     private void updateAdCampaignStartEndDate(){
    //         List<Ad_Campaign__c> adCampaigns = new List<Ad_Campaign__c>();
    //         for(AggregateResult result: [SELECT min(Date__c) StartDate, max(Date__c) EndDate, Ad_Campaign__c FROM RS_Daily__c  WHERE Ad_Campaign__c IN:adCampaignIds GROUP BY Ad_Campaign__c]){
    //             Ad_Campaign__c adCampaign = new Ad_Campaign__c();
    //             adCampaign.Id = (Id) result.get(Util.NS + 'Ad_Campaign__c');
    //             adCampaign.Start_Date__c = (Date) result.get('StartDate');
    //             adCampaign.End_Date__c = (Date) result.get('EndDate');
    //             adCampaigns.add( adCampaign );
    //         }
    //         WithoutSharing.doUpdate(adCampaigns);
    //     }

    //     // delete modified line item RS daily and monthly
    //     private void deleteShortenRSDailyAndMonthly(){
    //         Set<String> RSMonthlyUniqueKeys = new Set<String>();
    //         for(Revenue_Schedules_Monthly__c RSMonthly: lstRSMonthly){
    //             String uniqueKey = GW_IO.getRSMonthlyUniqueKey(RSMonthly);
    //             if(String.isNotBlank(uniqueKey)) RSMonthlyUniqueKeys.add(uniqueKey);
    //         }
    //         WithoutSharing.doDelete([SELECT id FROM Revenue_Schedules_Monthly__c WHERE Unique_Key__c NOT IN:RSMonthlyUniqueKeys AND Ad_Campaign__c IN:adCampaignIds AND IO_LineItem__c IN:mapIOLineItem.values() ]);

    //         Set<String> RSDailyUniqueKeys = new Set<String>();
    //         for(RS_Daily__c RSDaily: lstRSDaily){
    //             String uniqueKey = GW_IO.getRSDailyUniqueKey(RSDaily);
    //             if(String.isNotBlank(uniqueKey)) RSDailyUniqueKeys.add(uniqueKey);
    //         }
    //         WithoutSharing.doDelete([SELECT id FROM RS_Daily__c WHERE Unique_Key__c NOT IN:RSDailyUniqueKeys AND Ad_Campaign__c IN:adCampaignIds AND Revenue_Schedule_Monthly__r.IO_LineItem__c IN:mapIOLineItem.values()]);
            
    //     }

    // }

}