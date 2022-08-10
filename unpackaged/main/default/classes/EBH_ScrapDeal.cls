/**10/10/2017:
 vadhanak.voun@gaea-sys.com
 #12702:
   1.  Scheduled job collects all deal__c records where Status__c = “Deal Agreed” or “Running” and Deal_Start_Date__c = Today and ebay_Link__c <> “Item ID missing”
  2.  From these records use the URL in ebay_Link__c to go to the eBay Website of the deal.
  3.  Identify the price of the deal from the website (see screenshot).
     If I understand correctly there is an item on the page with ID prcIsum which contains the price.
    <span class="notranslate" id="prcIsum" itemprop="price" style="" content="439.0">EUR 439,00</span>
  4.  Compare this identified price with Deal_Price__c. If they don’t match set Price_not_matching__c = True
  
  changes:
  	+ 02/03/2018: Vadhanak: findEbayPrice(): replaced regex that unknown reason causes regex too complicate.
  				  Handle redirect in case item moved to HTTPS 
  	+ 03/03/3030: Vadhanak: US-0007241 Rework existing EBH_ScrapDeal class to use API call instead of Web Crawling approach.
*/

global without sharing class EBH_ScrapDeal implements Database.Batchable<SObject>,Database.AllowsCallouts,Schedulable {
   String query = 'Select Id,EBH_DealSiteId__c,EBH_eBayItemID__c,EBH_Status__c,EBH_ebayLink__c,EBH_DealPrice__c,EBH_Pricenotmatching__c From EBH_Deal__c ';
   
   global Database.QueryLocator start(Database.BatchableContext BC)
   {
      String sWhere = ' WHERE EBH_Status__c IN(\'Deal Agreed\',\'Running\') AND EBH_DealStartDate__c=TODAY AND EBH_ebayLink__c <> \'Item ID missing\'';
      return Database.getQueryLocator(query+sWhere);
   }
   public EBH_ScrapDeal(){}
   
   global void execute(Database.BatchableContext BC, List<EBH_Deal__c> scope)
   {
       EBH_DealTriggerHandler.doProcessDealItems(scope);
   }

   global void finish(Database.BatchableContext BC)
   {
     
   }
   
   global void execute(SchedulableContext sc) {
      EBH_ScrapDeal sdbatch = new EBH_ScrapDeal(); 
      Database.executebatch(sdbatch,50); //reduced from 100 to 50; there could be another redirect request
   }
}