/*********************************************************************************************************************************
@ Class:          SellerHealthSummaryController
@ Version:        1.0
@ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:        Controller for page: SellerHealthSummary   
@                 EPH-5212 : Create "Seller Health Summary" export pdf for seller 360 V.1.0 - Functional Export Requirment	
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 03.07.2018 / Vadhanak Voun / Created the class.
@				: 05.03.2019 / Vadhanak Voun / + without sharing for: EPH-7167
@				: 15.03.2019/ Vadhanak Voun / EPH-7167 Seller Scorecard. improve user experience in Clinics data. Rename Fields & Adjust format
*********************************************************************************************************************************/
public without sharing class SellerHealthSummaryController {
 	public Account seller{get;set;}
 	
 	public List<String> listGroup {get {return new List<String>{
					 		'Conversion funnel',
					 		'Impression-related metrics',
					 		'Conversion-related metrics',
					 		'Offer-related metrics',
					 		'International metrics',
					 		'Mobile Metrics'};
				 		} set;}
 	public Map<String,String> mapGroupToLabel {get {return new Map<String,String>{
					 		'Conversion funnel'=>'Sales funnel metrics',
					 		'Impression-related metrics'=>'Impressions and CTR-related metrics',
					 		'Conversion-related metrics'=>'Conversion-related metrics',
					 		'Offer-related metrics'=>'Offer and seller standard-related metrics',
					 		'International metrics'=>'International metrics',
					 		'Mobile Metrics'=>'Mobile Metrics'};
				 		} set;}	
 	public SellerHealthSummaryController(ApexPages.StandardController stdController)
 	{
 		seller = (Account)stdController.getRecord();
 		init();
 	}   
 	
 	private void init()
 	{
 		if(seller <> null && seller.Id <> null)
 		{
 			String sellerId = seller.Id;
 			seller = Database.query(EBH_ConstantsUtility.SOQL_SELLER_HEALTH_PDF);
 			
 		}
 	}
}