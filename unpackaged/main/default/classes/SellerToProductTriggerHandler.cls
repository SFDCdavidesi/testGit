/*********************************************************************************************************************************
@ Class:          SellerToProductTriggerHandler
@ Version:        1.0
@ Author:         Vadhanak Voun
@ Purpose:        Handler Class for trigger: SellerToProduct   
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 04.07.2019 / Vadhanak Voun /Created the class
				  19.05.2021 / Mony Nou / Retired codes / US-0009522 - [EU] [AU] Trading Engine: retire Apex
*********************************************************************************************************************************/
public without sharing class SellerToProductTriggerHandler {
	
	
	/*****************************************************************************************************************************
	@ Method:        calculateProductFields
	@ Version:       1.0
	@ Author:          
	@ Purpose:       EPH-7745: 3 fields on Product object are not populated ( EPH-7364 -> EPH-7612 -> EPH-7745)
    @            - Product__c.Total_Sellers_for_Price_Optimization__c (count sum)
	@				Seller_to_Product__c.Competitive_Status_seller__c = 'Uncompetitive'
	@			 - Product__c.Total_Sellers_for_Re_stocking__c (count sum)
	@				+ Seller_to_Product__c.Competitive_Status_seller__c = 'Inventory - Out of stock'
	@			 - Product__c.Total_Sellers_on_eBay__c
	@				+ Seller_to_Product__c.Product__c (count)
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter: List new, map old	 
	@ Event	: after insert, after update, after delete, after undelete
	------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 04/07/2019 / Vadhanak Voun  / Created the  Method.
	@				: 02/10/2019 / Vadhanak Voun  / US-0015716 Change Trigger to Batch Job on Seller to Product
	*****************************************************************************************************************************/
	/* MN-19/05/2021 - US-0009522 - Retired Codes
    public static void calculateProductFields(List<Seller_to_Product__c> listNew )
    {
    	Set<String> setProduct_forAll= new Set<String>();
    	Set<String> setProduct_forUncompet = new Set<String>();
    	Set<String> setProduct_forRestock = new Set<String>();
    	Map<String,Product__c> mapProudctUpdate = new Map<String,Product__c>();
    	
		for(Seller_to_Product__c stp: listNew)
    	{
    		if(stp.Product__c <> null )
    		{
    			setProduct_forAll.add(stp.Product__c);
    			
    			if((EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN ==stp.Competitive_Status_seller__c ))
    			{
    				setProduct_forUncompet.add(stp.Product__c);
    			}else if(EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK ==stp.Competitive_Status_seller__c)
    			{
    				setProduct_forRestock.add(stp.Product__c);
    			}
    			
    			mapProudctUpdate.put(stp.Product__c,new Product__c(Id=stp.Product__c));
    			continue;
    		} 
    		
		}
		 
		if(!setProduct_forAll.isEmpty())
		{
			//NK:02/08/2019: EPH-7883: tryin to fix: 200.000 Non-selective query
			//all = currently 3 pkl
			Set<String> setPKL_all = new Set<String>{'',EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN,EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_COMPETE,EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK};
			doAggregateAndUpdateValue(mapProudctUpdate,setProduct_forAll,setPKL_all,'Total_Sellers_on_eBay__c');
		} 
		if(!setProduct_forUncompet.isEmpty())
		{
			doAggregateAndUpdateValue(mapProudctUpdate,setProduct_forUncompet,new Set<String>{EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN},'Total_Sellers_for_Price_Optimization__c');
		} 
		if(!setProduct_forRestock.isEmpty())
		{
			doAggregateAndUpdateValue(mapProudctUpdate,setProduct_forRestock,new Set<String>{EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK},'Total_Sellers_for_Re_stocking__c');
		} 
		
		if(!mapProudctUpdate.isEmpty())
		{
			 update mapProudctUpdate.values();
		}
		
    }
	*/

	/* MN-19/05/2021 - US-0009522 - Retired Codes
    //NK:12/07/2019:Switched from sub query to Aggreate to fix: Aggregate query has too many rows for direct assignment
    private static void doAggregateAndUpdateValue(Map<String,Product__c> mapProudctUpdate,Set<String> setProductIds,Set<String> pkl_status,String fieldToUpdate)
    {
    	String soql1 = EBH_ConstantsUtility.SOQL_AGGR_COUNT_SELLER_TO_PRODUCT;
		String sWhere_pkl = pkl_status==null?'':' AND Competitive_Status_seller__c IN:pkl_status ';
		soql1 = soql1 +' WHERE Product__c IN: setProductIds '+sWhere_pkl+' group by Product__c';
		
		Map<String,AggregateResult> mapAGGR = new Map<String,AggregateResult>();
		//AggregateResult[] aResultsss =  Database.query(soql1);
		//system.debug('>>>fieldToUpdate: '+fieldToUpdate+'>>.setProductIds: '+setProductIds+'>>>aResultsss: '+aResultsss);
    	//for(AggregateResult aResult: Database.query(soql1))
    	for(AggregateResult aResult: Database.query(soql1))
		{
			mapAGGR.put(aResult.get('Product__c')+'',aResult);
		}  
		for(String pId: setProductIds)
		{
			AggregateResult aResult = mapAGGR.get(pId); //in case record deleted; so no result return then considered it as 0 count
			if(aResult==null)
			{
				mapProudctUpdate.get(pId).put(fieldToUpdate,0);
			}else
			{
				mapProudctUpdate.get(aResult.get('Product__c')+'').put(fieldToUpdate,aResult.get('rowCount'));
			}
			
		}  
    }
	*/
}