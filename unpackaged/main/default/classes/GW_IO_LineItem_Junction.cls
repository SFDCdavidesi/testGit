// MN-26102021-Deprecated via US-0008416
public with sharing class GW_IO_LineItem_Junction {


    // public static List<IO_LineItem_Junction__c> getIOLineItemJunction(List<QuoteLineItem> qlis, Map<Id, IO_LineItem__c> mapQliId2IOline, Boolean isRevision){
    //     List<IO_LineItem_Junction__c> junctions = new List<IO_LineItem_Junction__c>();
    //     for( QuoteLineItem qli :qlis) {
    //     	if(!mapQliId2IOline.containsKey(qli.Id)) continue;

    //         IO_LineItem__c IOLineItem = mapQliId2IOline.get(qli.Id);

    //         IO_LineItem_Junction__c junction = new IO_LineItem_Junction__c(IO_LineItem__c = IOLineItem.id, Quote_LineItem__c = qli.id );
    //         GW_IO_LineItem_Junction.setJunctionRollupValue(junction, qli, isRevision);
    //         junctions.add(junction);

    //     }
    //     return junctions;
    // }
    // public static List<IO_LineItem_Junction__c> getIOLineItemJunction(List<QuoteLineItem> qlis, Map<Id, IO_LineItem__c> mapQliId2IOline){
    //     return GW_IO_LineItem_Junction.getIOLineItemJunction(qlis, mapQliId2IOline, false);
    // }

    // public static List<IO_LineItem_Junction__c> getRevisionIOLineItemJunction(Map<Id, QuoteLineItem> mapOldQliId2NewQli) {
    //     Set<String> oldQliIds = QueryUtil.toStringSet(mapOldQliId2NewQli.keySet());
    //     Map<Id, IO_LineItem__c> mapOldQliId2IOline = GW_QuoteLineItem.getMapQliId2IOline(oldQliIds);
    //     Map<Id, IO_LineItem__c> mapNewQliId2IOline = new Map<Id, IO_LineItem__c>();
    //     for( Id oldQliId :mapOldQliId2IOline.keySet()){
    //         if(!mapOldQliId2NewQli.containsKey(oldQliId)) continue;

    //         Id newQliId = mapOldQliId2NewQli.get(oldQliId).Id;
    //         mapNewQliId2IOline.put(newQliId, mapOldQliId2IOline.get(oldQliId));
    //     }
    //     return GW_IO_LineItem_Junction.getIOLineItemJunction(mapOldQliId2NewQli.values(), mapNewQliId2IOline, true);
    // }
    // /*
    // public static void updateJunction(List<QuoteLineItem> qlis){
    // 	if(qlis.isEmpty()) return;

    //     Set<Id> ioLineIds = new Map<Id, IO_LineItem__c>(GW_QuoteLineItem.getIOLines(qlis)).keySet();
    // 	new ConjunctionCalculator(ioLineIds).calculate();
    // }*/

    // public static void updateJunction(Set<String> qliIds){
    //     if(qliIds.isEmpty()) return;

    //     Map<Id, QuoteLineItem> mapQli = new Map<Id, QuoteLineItem>( (List<QuoteLineItem>) QueryUtil.queryRecords('QuoteLineItem', new Set<String>{'Quote.'+ Util.NS +'IO__c', 'Quote.Opportunity.Type'} , qliIds));
    //     List<IO_LineItem_Junction__c> junctionsToUpdate = new List<IO_LineItem_Junction__c>();
    //     Map<Id, IO_LineItem_Junction__c> mapQliId2Junction = GW_IO_LineItem_Junction.getMapQliId2Junction(mapQli.values());
    //     //throw new ExceptionGroup.CustomException(JSON.serialize(mapQliId2Junction));
    //     for(Id qliId: mapQliId2Junction.keySet()){
    //         //IO_LineItem_Junction__c juncQli = new IO_LineItem_Junction__c( Id=mapQliId2Junction.get(qliId).Id );
    //         IO_LineItem_Junction__c juncQli = mapQliId2Junction.get(qliId);
    //         GW_IO_LineItem_Junction.setJunctionRollupValue(juncQli, mapQli.get(qliId));
    //         junctionsToUpdate.add(juncQli);
    //     }
    //     WithoutSharing.doUpdate(junctionsToUpdate);
    // }

    // //public static void setRevisionJunctionValue(IO_LineItem_Junction__c junc, QuoteLineItem qli, IO_LineItem__c IOline){
    // //    junc.Total_Quote_Line_Item_Quantity__c = qli.Quantity - IOline.Roll_up_Summary_Total_Quantity__c;
    // //    junc.Total_Quote_Line_Item_CPU__c = qli.SalesPriceNet__c;
    // //    junc.Quote_LineItem_Total_Price__c = qli.Budget__c - IOline.Rollup_Summary_Total_Price__c;

    // //}
	
	// public static void setJunctionRollupValue(IO_LineItem_Junction__c junction, QuoteLineItem qli, Boolean isRevision ){
	// 	junction.Total_Quote_Line_Item_CPU__c = qli.SalesPriceNet__c;
	// 	junction.Quote_LineItem_Total_Price__c = qli.Budget__c; //junction.Quote_LineItem_Total_Price__c = isRevision ? 0: qli.Budget__c;
    //     junction.Total_Quote_Line_Item_Quantity__c =qli.Quantity__c; //junction.Total_Quote_Line_Item_Quantity__c =qli.Quantity;
    // }
	
	// /*
	// @ Change history: 
	// *	27-June-2019 : AMT, Task #21558 (4- Update logic for Edit Quote Line Item)
	// */
    // public static void setJunctionRollupValue(IO_LineItem_Junction__c junction, QuoteLineItem qli){
    //     Double rollTP = junction.IO_LineItem__r.Rollup_Summary_Total_Price__c == null ? 0 : junction.IO_LineItem__r.Rollup_Summary_Total_Price__c;
    //     Double rollTQ = junction.IO_LineItem__r.Roll_up_Summary_Total_Quantity__c == null ? 0 : junction.IO_LineItem__r.Roll_up_Summary_Total_Quantity__c;
    //     Double qliBudget = qli.Budget__c == null ? 0 : qli.Budget__c;
    //     Double qliQty = qli.Quantity__c == null ? 0 : qli.Quantity__c;
        
	// 	Double junctionTotalPrice = junction.Quote_LineItem_Total_Price__c == null ? 0 : junction.Quote_LineItem_Total_Price__c;
    //     Double junctionTotalQty = junction.Total_Quote_Line_Item_Quantity__c == null ? 0 : junction.Total_Quote_Line_Item_Quantity__c;
        
    //     junction.Total_Quote_Line_Item_CPU__c = qli.SalesPriceNet__c;
    //     junction.Quote_LineItem_Total_Price__c = qliBudget - (rollTP - junctionTotalPrice);
    //     junction.Total_Quote_Line_Item_Quantity__c = qliQty - (rollTQ - junctionTotalQty);
    // }
    // /*
    //  This cls is created to calculate conjuction qty as delta.
    //  It is deprecated as bussiness/design was changed. User will need to delete quote line item instead of inputting zero/negative qty
     
    // public class ConjunctionCalculator {
    // 	Map<Id, IO_LineItem_Junction__c[]> mIOLineId2JunctionsOrdered = new Map<Id, IO_LineItem_Junction__c[]>();
    	
    // 	public ConjunctionCalculator(Set<Id> ioLineIds) {
    // 		for(IO_LineItem_Junction__c con : WithoutSharing.getIOItemJunctionsForCalculate(ioLineIds)) {
    // 			if( !mIOLineId2JunctionsOrdered.containskey(con.IO_LineItem__c) ) {
    // 				mIOLineId2JunctionsOrdered.put(con.IO_LineItem__c, new List<IO_LineItem_Junction__c>() );
    // 			}
    // 			mIOLineId2JunctionsOrdered.get(con.IO_LineItem__c).add(con);
    // 		}
    // 	}
    // 	public IO_LineItem_Junction__c[] calculate() {
    // 		IO_LineItem_Junction__c[] conjunctions = new List<IO_LineItem_Junction__c>();
    		
    // 		for(Id lineId : mIOLineId2JunctionsOrdered.keyset()) {
    // 			Decimal sumQty = 0;
    			
    // 			for(IO_LineItem_Junction__c con : mIOLineId2JunctionsOrdered.get(lineId)) {
    // 				con.Total_Quote_Line_Item_Quantity__c = con.Quote_LineItem__r.Quantity - sumQty;
    // 				con.Total_Quote_Line_Item_CPU__c = con.Quote_LineItem__r.SalesPriceNet__c;
    				
    // 				Decimal factor = con.IO_LineItem__r.Product__r.Billing_Category__c == 'CPM' ? 0.001 : 1;
    // 				con.Quote_LineItem_Total_Price__c = con.Total_Quote_Line_Item_Quantity__c * con.Total_Quote_Line_Item_CPU__c * factor;
    				
    // 				// 
    // 				sumQty += con.Total_Quote_Line_Item_Quantity__c;
    // 				conjunctions.add(con);
    // 			}
    // 		}
    // 		WithoutSharing.doUpdate(conjunctions);
    // 		return conjunctions;
    // 	}
    // }
	// */
	// /*
	// @ Change history: 
	// *	27-June-2019 : AMT, Task #21558 (4- Update logic for Edit Quote Line Item)
	// 				-> Add field sIOLIJ_AddtionalField; 
	// */
    // public static Map<Id, IO_LineItem_Junction__c> getMapQliId2Junction(List<QuoteLineItem> qlis){
    //     Map<Id, QuoteLineItem> mapQli = new Map<Id, QuoteLineItem>(qlis);
    //     Set<Id> IOIds = new Set<Id>();
    //     for(QuoteLineItem qli :qlis){
    //         IOIds.add(qli.Quote.IO__c);
    //     }
        
	// 	Set<String> sIOLIJ_AddtionalField = new Set<String>{
	// 		Util.NS + 'IO_LineItem__r.'+ Util.NS +'Rollup_Summary_Total_Price__c',
	// 		Util.NS + 'IO_LineItem__r.'+ Util.NS +'Roll_up_Summary_Total_Quantity__c'
	// 	};
		
    //     Map<Id, IO_LineItem_Junction__c> mapQliId2Junction = new Map<Id, IO_LineItem_Junction__c>();
    //     //for(IO_LineItem_Junction__c junc: (List<IO_LineItem_Junction__c>) QueryUtil.queryRecords(Util.NS + 'IO_LineItem_Junction__c', Util.NS+'Quote_LineItem__c IN:value1 AND '+Util.NS+'IO_LineItem__r.'+Util.NS+'IO__c IN:value2', new Map<String, Object>{'value1'=>mapQli.keySet(), 'value2'=>IOIds}) ){
    //     for(IO_LineItem_Junction__c junc: (List<IO_LineItem_Junction__c>) QueryUtil.queryRecords(Util.NS + 'IO_LineItem_Junction__c', Util.NS+'Quote_LineItem__c IN:value1 AND '+Util.NS+'IO_LineItem__r.'+Util.NS+'IO__c IN:value2', sIOLIJ_AddtionalField, new Map<String, Object>{'value1'=>mapQli.keySet(), 'value2'=>IOIds}) ){
    //         mapQliId2Junction.put(junc.Quote_LineItem__c, junc);
    //     }

    //     return mapQliId2Junction;
    // }

}