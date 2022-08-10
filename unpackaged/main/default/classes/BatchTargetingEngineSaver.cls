/********************************************************************************************************************************
@ Class:          BatchTargetingEngineSaver
@ Version:        1.0
@ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:        EPH-7373 argeting Engine: Trading Engine -Product List & Item List
@                  Then in the related tab I see two new lists under "Targeted Sellers"
@		"Targetted Products" - input comes from "Product" record that is connected to "Sellers" via "Product to "Sellers"
@		"Targetted Listings" - input comes from "Product to Sellers" record
@                   
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 19.05.2019 / Vadhanak Voun (vadhanak.voun@gaea-sys.com) / Created the class.
*/
global without sharing class BatchTargetingEngineSaver  implements Database.Batchable<SObject>{
	public final static String TE_RELATED_PRODUCT = 'Product__c';
	public final static String TE_RELATED_SELLER_TO_PRODUCT = 'Seller_to_Product__c';
	
    private String soql = 'Select Id From ';
    private String te_Id;
    private String sobjectToSellect;
    private List<String> listIds;
    
    /*****************************************************************************************************************************
    @ Constructor:    BatchTargetingEngineSaver
    @ Version:        1.0
    @ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:        constructor
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:    te_Id: Targetting Engine ID
    @				sobjectToSellect: sobject to run the query FROM (Product__c/Seller_to_Product__c)
    @				listIds: set of Id of the record to select
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 19.05.2019 / Vadhanak Voun (Vadhanak.voun@gaea-sys.com) / Created the constructor.
    *****************************************************************************************************************************/
    public BatchTargetingEngineSaver(String te_Id, String sobjectToSellect,List<String> listIds)
    {
    	soql = soql + sobjectToSellect + ' WHERE Id IN: listIds';
    	this.listIds = listIds;
    	this.te_Id = te_Id;
    	this.sobjectToSellect  = sobjectToSellect;
    }
    
    public BatchTargetingEngineSaver(String te_Id)
    {
    	this.te_Id = te_Id;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(soql);
    }
    
    global void execute(Database.BatchableContext pBc, List<SObject> scope)
    {
     	 if(TE_RELATED_PRODUCT == sobjectToSellect)
     	 {
     	 	saveProducts(scope);
     	 }else if(TE_RELATED_SELLER_TO_PRODUCT == sobjectToSellect)
     	 {
     	 	saveSellerToProduct(scope);
     	 }
     	
    }
    
    public void saveProducts(List<Product__c> scope)
    {
    	List<Targetted_Product__c> listProduct = new List<Targetted_Product__c>();
    	for(Product__c p: scope)
    	{
    		listProduct.add(new Targetted_Product__c(Trading_Engine__c=te_Id,Product__c=p.Id,Ext_Id__c=te_Id+'_'+p.Id));
    	}	
    	
    	upsert listProduct Ext_Id__c;
    } 
    public void saveSellerToProduct(List<Seller_to_Product__c> scope)
    {
    	List<Targetted_Listing__c> listListingProduct = new List<Targetted_Listing__c>();
    	for(Seller_to_Product__c stp: scope)
    	{
    		listListingProduct.add(new Targetted_Listing__c(Trading_Engine__c=te_Id,Seller_to_Product__c=stp.Id,Ext_Id__c=te_Id+'_'+stp.Id));
    	}	
    	
    	upsert listListingProduct Ext_Id__c;
    } 
    
     global void finish(Database.BatchableContext pBc){
        
    }
}