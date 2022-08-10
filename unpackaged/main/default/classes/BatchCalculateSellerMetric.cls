/*********************************************************************************************************************************
@ Class:         BatchCalculateSellerMetric
@ Version:       1.0
@ Author:        Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:       EPH-7566 Inventory Sourcing Metrics.Changes
			- Top Products Competitiveness (%): Sum of all related Seller to Product records where competitive status (seller) ="Uncompetitive/Sum of all related Seller to Product records 
			- Number of Top Products: Sum of all related Seller to Product records 
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 30.05.2019 / Vadhanak Voun / Created the class.
@				: 20.06.2019 / Vadhaank Voun/ EPH-7677 Top Products Competitiveness (%). Correct Calculation
@							New formula for Top Products Competitiveness (%): be changed to: 
@							(Number of Top Products-Total Listings for Price Optimisation )/Number of Top Products		
@				:21.08.2019/Vadhanak Voun/ EPH-7898 Trading Engine. Seller Metrics. Changes
@				:03.02.2020/Vadhanak Voun/ US-0007155 Failed to process batch for class 'BatchCalculateSellerMetric'
@						caused by: System.LimitException: Too many query rows: 50001
@						Solution:
@							First run batch for Seller. In scope, limit seller to product: 50000. check if seller to product = 5000. then add to seller id to set, and skip
@							Finish: check if set of seller (who have been skip) then rerun batch with different constructor
@								new conctructor query only Seller To Products				
@				:19.05.2021 / Mony Nou / Retired codes / US-0009522 - [EU] [AU] Trading Engine: retire Apex	
*********************************************************************************************************************************/
global without sharing class BatchCalculateSellerMetric {

	/* MN-19/05/2021 - US-0009522 - Retired Codes
	global without sharing class BatchCalculateSellerMetric implements Database.Batchable<SObject>, Schedulable,Database.Stateful{
	
	String sellerRecordType = 'EBH_Seller';
	
    public final static string PRIMARYSITE_DE = 'Germany';
    final static String statusUncompet = EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN;
	final static String statusCompet = EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_COMPETE;
	final static String statusOutOfStock = EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK;
    final static Integer LIMIT_QUERY = 45000;
    
    //default query: Seller	
    String batchQuery = 'Select Id,EBH_PrimarySite__c,Number_of_Top_Products__c,Total_Products_for_Price_Optimisation__c,Total_Products_for_Re_Stocking__c,Top_Top_Products_Competitiveness__c From Account where RecordType.DeveloperName =:sellerRecordType ';
   	String soqlSellerToProduct = 'Select  Seller__r.EBH_PrimarySite__c, Seller__r.Number_of_Top_Products__c, Seller__r.Total_Products_for_Price_Optimisation__c, Seller__r.Total_Products_for_Re_Stocking__c, Seller__r.Top_Top_Products_Competitiveness__c,Id,Seller__c,Competitive_Status_seller__c,Competitive_Status_seller_2__c From Seller_to_Product__c ';
    
    String accId = null;
    String additionalWhere = '';	
    Set<String> setSellers = new Set<String>();  
    Boolean sellerQuery = true; //default: first query: seller. second batch: STP 
    
    //Map: SellerId, SellerCal.
    //Map store the calculated value of the seller (step2 batch)
    Map<String,SellerCal> mapCalculatedSeller = new Map<String,SellerCal>();
    
    //1,from scheduler (main query: Seller)
    public BatchCalculateSellerMetric()
    {   
    }
    
    //2,when scope(seller) has more thant 50K records of seller to products. then skip and process them in batch of STP in this constructor
    //main query : STP
    public BatchCalculateSellerMetric(Set<String> setSellers)
    {
    	this.setSellers = setSellers;
    	sellerQuery = false;
    	batchQuery = soqlSellerToProduct; //switch to STP query
    	additionalWhere = ' WHERE Seller__c IN :setSellers';
    }
    
    //3,for single test. main query Seller
    public BatchCalculateSellerMetric(String accId)
    {
    	this.accId = accId;
    	additionalWhere = ' AND Id=:accId';
    }
    */
	/* MN-19/05/2021 - US-0009522 - Retired Codes
    global Database.QueryLocator start(Database.BatchableContext BC) {
    	
    	return Database.getQueryLocator(batchQuery+additionalWhere);
    }
	*/
    /*****************************************************************************************************************************
    @ Method:         execute
    @ Version:        1.0
    @ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:        execute the scope
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.05.2019 /Vadhanak Voun (vadhanak.voun@gaea-sys.com) / Created the method.
    @				: 03.06.2019 /Vadhanak Voun/ changed to SOQL to get rid of CPU limit
    @				: 21.08.2019/ Vadhanak Voun/ EPH-7898 Trading Engine. Seller Metrics. Changes
    @				1) Number of Top Products: (Number_of_Top_Products__c)
	@					If Seller.Primary Site=DE 
	@					Sum of all related Seller to Product records
	@					WHERE Competitive Status (Seller vs. idealo 1 "Competitive_Status_seller_2__c") is not NULL
	@					ELSE Sum of all related Seller to Product records WHERE Competitive Status (Seller vs. Amazon) is not NULL
	@				2) Total Products for Price Optimisation (Total_Products_for_Price_Optimisation__c)
	@					If Seller.Primary Site=DE 
	@					Then Count( Seller to Products) where Competitive Status (Seller vs.Idealo1 "Competitive_Status_seller_2__c")= Uncompetitive
	@					ELSE Count( Seller to Products) where Competitive Status (Seller vs. Amazon)= Uncompetitive
	@				3) Total Products for Re-stocking (Total_Products_for_Re_Stocking__c)
	@					If Seller.Primary Site=DE 
	@					Then Count( Seller to Products) where Competitive Status (Seller vs.Idealo1 "Competitive_Status_seller_2__c")= Inventory-Out-of-Stock
	@					ELSE Count( Seller to Products) where Competitive Status (Seller vs. Amazon)= Inventory - Out-of Stock"
	@				4)	Top Products Competitiveness (%)  (Top_Top_Products_Competitiveness__c)
	@					If Seller.Primary Site =DE 
	@					(Seller  to Product  with Competitive Status (Seller vs.Idealo1) ="competitive") / (Seller  to Product  with Competitive Status (Seller vs.Idealo1) ="competitive" & "uncompetiive") – 1
	@					ELSE (Seller  to Product  with Competitive Status (Seller vs.Amazon) ="competitive") / (Seller  to Product  with Competitive Status (Seller vs. Amazon) ="competitive" & "uncompetiive") – 1
    *****************************************************************************************************************************/
    /* MN-19/05/2021 - US-0009522 - Retired Codes
	global void execute(Database.BatchableContext pBc, List<SObject> scope){
    	//step 1: all query: sellers
    	if(sellerQuery)
    	{
			
			String addWhereSTP = ' where Seller__c IN :scope LIMIT :LIMIT_QUERY';
			Seller_to_Product__c[] listAllSTP = Database.query(soqlSellerToProduct+addWhereSTP);
			if(listAllSTP.size() == LIMIT_QUERY)
			{
				for(Account acc: (Account[])scope)
				{
					setSellers.add(acc.Id);
				}
				//put in to Set to process in next batch 
				return;
			}
			Map<String,Seller_to_Product__c[]> mapSellerListSTP = createMapSeller_STP(listAllSTP);
			
			for(Account acc: (Account[])scope)
			{
				
				List<Seller_to_Product__c> listSTP = mapSellerListSTP.get(acc.Id);
				
				//process the calculation here
				SellerCal selCal = new SellerCal(listSTP,acc.EBH_PrimarySite__c);
				selCal.doCal();
					
				acc.Number_of_Top_Products__c = selCal.numTopProduct; 
				acc.Total_Products_for_Price_Optimisation__c = selCal.totalProductOptm;
				acc.Total_Products_for_Re_Stocking__c = selCal.totalProductRestock;
				acc.Top_Top_Products_Competitiveness__c = selCal.topProductCompet;
				
			}
			
			update scope;
		
    	}else //step 2: in case, step1 has 50K of STP, then process STP in batch from different constructor (on Finish of step1)
    	{
    		List<Account> listSellerToUpdate = new List<Account>();
    		List<Seller_to_Product__c> listAllSTP = (Seller_to_Product__c[])scope;
    		 
			Map<String,Seller_to_Product__c[]> mapSellerListSTP = createMapSeller_STP(listAllSTP);
    		for(String sellerId: mapSellerListSTP.keySet())
    		{
    			List<Seller_to_Product__c> listSTP_bySeller = mapSellerListSTP.get(sellerId);
    			 
				SellerCal selCal = new SellerCal(listSTP_bySeller,(listSTP_bySeller.isEmpty()?'':listSTP_bySeller[0].Seller__r.EBH_PrimarySite__c));
				selCal.doCal();
    			
    			//calculation from previous scope with the same seller 
    			SellerCal preCal = mapCalculatedSeller.get(sellerId);
    			
    			//accumulate the calculation into a single Cal for each Seller
    			selCal.doSum(preCal);
    			
    			listSellerToUpdate.add(
    				new Account
    				( Id=sellerId,
    				Number_of_Top_Products__c = selCal.numTopProduct,
    				Total_Products_for_Price_Optimisation__c = selCal.totalProductOptm,
    				Total_Products_for_Re_Stocking__c = selCal.totalProductRestock,
    				Top_Top_Products_Competitiveness__c = selCal.topProductCompet
    				)
    			);
    			
    			//keep for next scope calculation
    			mapCalculatedSeller.put(sellerId,selCal); 
    		}
    		
    		if(!listSellerToUpdate.isEmpty())
    		{
    			update listSellerToUpdate;
    		}
    		
    	}
		
    }
	*/
    /* MN-19/05/2021 - US-0009522 - Retired Codes
    private Map<String,Seller_to_Product__c[]> createMapSeller_STP(Seller_to_Product__c[] listAllSTP)
    {
    	Map<String,Seller_to_Product__c[]> mapSellerListSTP = new Map<String,Seller_to_Product__c[]>();
    	for(Seller_to_Product__c stp: listAllSTP)
		{
			if(!mapSellerListSTP.containsKey(stp.Seller__c))
			{
				mapSellerListSTP.put(stp.Seller__c,new List<Seller_to_Product__c>());
			}
			mapSellerListSTP.get(stp.Seller__c).add(stp);
		}
		return mapSellerListSTP;   
    }
    */

	/*
    global void finish(Database.BatchableContext pBc){
	
        if(sellerQuery && !setSellers.isEmpty())
        {
        	//process the seller that has more than 50K STP
        	BatchCalculateSellerMetric b = new BatchCalculateSellerMetric(setSellers);
        	Database.executeBatch(b);
        }
		
    }
    */
    /*****************************************************************************************************************************
    @ Method:         execute
    @ Version:        1.0
    @ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:        Allow this batch to be schedulable
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.05.2019 / Vadhanak Voun (vadhanak.voun@gaea-sys.com) / Created the method.
    *****************************************************************************************************************************/ 
    /* MN-19/05/2021 - US-0009522 - Retired Codes
	global void execute(SchedulableContext sc) { 
        BatchCalculateSellerMetric b = new BatchCalculateSellerMetric();
        Database.executeBatch(b,100);
    }
    */

	/* MN-19/05/2021 - US-0009522 - Retired Codes
    class SellerCal{
    	Decimal numTopProduct = 0;
		Decimal totalProductOptm = 0; 	
		Decimal totalProductRestock = 0; 	
		Decimal topProductCompet = 0; 	
		
		Decimal stp_DE_compet = 0;
		Decimal stp_DE_both = 0; //compet and uncompet
		
		Decimal stp_none_DE_compet = 0;
		Decimal stp_none_DE_both = 0; //compet and uncompet
		
		List<Seller_to_Product__c> listSTP;
		String primarySite;
		
    	public SellerCal(List<Seller_to_Product__c> listSTP,String primarySite)
    	{
    		this.listSTP = listSTP;
    		this.primarySite = primarySite;
    	}
    	public void doSum(SellerCal preCal)
    	{
    		if(preCal <> null)
    		{
    			numTopProduct = numTopProduct + preCal.numTopProduct;
	    		totalProductOptm = totalProductOptm + preCal.totalProductOptm;
	    		totalProductRestock = totalProductRestock + preCal.totalProductRestock;
	    		topProductCompet = topProductCompet + preCal.topProductCompet;	
    		}
    		
    	}
    	
    	public void doCal()
    	{
    		if(listSTP <> null && !listSTP.isEmpty())
    		{
	    		for(Seller_to_Product__c stp: listSTP)
				{
					if(primarySite == PRIMARYSITE_DE)
					{
						//1) Number of Top Products
						if(stp.Competitive_Status_seller_2__c <> null) numTopProduct +=1;
						
						//2) Total Products for Price Optimisation
						if(stp.Competitive_Status_seller_2__c==EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN) totalProductOptm +=1;
						
						//3) Total Products for Re-stocking
						if(stp.Competitive_Status_seller_2__c == EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK) totalProductRestock +=1;
						
						//4) 
						if(stp.Competitive_Status_seller_2__c==EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_COMPETE) stp_DE_compet +=1;
						if(stp.Competitive_Status_seller_2__c==EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_COMPETE || stp.Competitive_Status_seller_2__c==EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN ) stp_DE_both +=1;
						
					}else
					{
						if(stp.Competitive_Status_seller__c <> null) numTopProduct +=1;
						if(stp.Competitive_Status_seller__c==EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN) totalProductOptm +=1;
						if(stp.Competitive_Status_seller__c==EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK) totalProductRestock +=1;
						
						if(stp.Competitive_Status_seller__c==EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_COMPETE) stp_none_DE_compet +=1;
						if(stp.Competitive_Status_seller__c==EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_COMPETE || stp.Competitive_Status_seller__c==EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN) stp_none_DE_both +=1;
					}
				}
				if(primarySite == PRIMARYSITE_DE)
				{
					topProductCompet = ( stp_DE_both -1 )==0?0:(stp_DE_compet / ( stp_DE_both -1 ) ) * 100;
				}else
				{
					topProductCompet =  (stp_none_DE_both - 1)==0?0: (stp_none_DE_compet / (stp_none_DE_both - 1)) * 100;
				}
    		}
    	}
    }
	*/
}