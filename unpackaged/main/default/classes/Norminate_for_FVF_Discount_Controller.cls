/*********************************************************************************************************************************
@ Class:          Norminate_for_FVF_Discount_Controller
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        EPH-7267 New Object: Nominated Items & Nominate for FVF Discount
Shared Controller for LC: Norminate_for_FVF_Discount and Vf page Norminate_for_FVF_Discount
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 08.05.2019 / Sovantheany Dim / Created the class.
@ 			    : 19.07.2019 / Vadhanak Voun / No update but shared this controller with page: Forward_to_Seller.
@				: purpose is to get selected id
				: 05.05.2022 / Loumang SENG /US-0011260 - TECHDEBT: Reflected XSS
*********************************************************************************************************************************/
public without sharing class Norminate_for_FVF_Discount_Controller {
	public String sellerToProductIds {get;set;}
	public String sellerId {get;set;}
	public String sellerIdParam {get;set;}
	public String recordTypeId {get;set;}
	public Boolean isError {get;set;}
    public Norminate_for_FVF_Discount_Controller(ApexPages.StandardSetController controller){
    	List<Seller_to_Product__c> selectedSellerToProduct = controller.getSelected();
		
    	//sellerIdParam = System.currentPageReference().getParameters().get('id'); //LA-04-05-2022:US-0011260
		sellerIdParam = String.escapeSingleQuotes(String.isBlank(System.currentPageReference().getParameters().get('id')) ? '' : System.currentPageReference().getParameters().get('id')); //LA-04-05-2022:US-0011260
		
    	recordTypeId = ApexUtil.getRecordTypeByName('Final_Value_Fee_FVF__c',EBH_ConstantsUtility.FVF_LISTING_RECORDTYPE).Id;
    	isError = false;
    	 
    	if(!selectedSellerToProduct.isEmpty()){
			System.debug('Hi Product');
    		sellerToProductIds = '';
    		sellerId = '';
    		for(Seller_to_Product__c sp : Database.query(EBH_ConstantsUtility.SOQL_SELLER_TO_PRODUCT + ' where ID IN: selectedSellerToProduct')){
    		sellerToProductIds += sp.ID+',';
    		sellerId = sp.Seller__c;
	    	}
	    	if(!String.isBlank(sellerToProductIds)) sellerToProductIds = sellerToProductIds.removeEnd(',');
	    }else{
	    	isError = true;
	    	sellerId = sellerIdParam;
	    }
    	
    }
    
}