/*****************************************************************************************************************************
@ Class:          OpportunityTriggerHandler
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        Handler Class for opportunityMain.trigger
------------------------------------------------------------------------------------------------------------------------------
@ Change history:  24.08.2020 / Sophal Noch / Created the method.
@*****************************************************************************************************************************/
public without sharing class OpportunityTriggerHandler {

    /*****************************************************************************************************************************
    @ Method:       manageAdsProduct
    @ Author:       Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:      US-0008007
    @               Summary: Create a Ad Product record for an Opportunity whenever a new Opportunity is created.
    @               AC 1) When a new Opportunity is created, a new Ad Product record (without a Product) is created where the 'Total Price' value is automatically populated based on the Opportunity Amount.
    @               AC 2) A roll-up summary field is created on the Opportunity to count the number of (Ad Products with Products)
    @               AC 3) When an Opportunity is updated and the amount is changed and the roll-up summary count = 0, than update the total price to the new amount.
    @               AC 4) Create a new checkbox 'Quote Sync In Progress' on Opportunity that does not appear on any page layouts, default is 'False' Field Level Security should be read/write to System Admin Profile
    @               AC 5) Validation Rule to prevent changing the Opportunity Amount when the Amount is changed, the roll-up summary count >0 and the checkbox 'Quote' Is Syncing is False'
    @               Validation Rule Error Message: "The Total Amount cannot be updated for this opportunity"
    @ Event:		after insert, after update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	Opportunity Trigger.New, Trigger.oldMap, Trigger.isInsert
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  24.08.2020 / Sophal Noch / Created the method.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  15.10.2020  / Sophal Noch / US-0008451 allow field populating logic to run when opp start and end date changed.
    @*****************************************************************************************************************************/
    public static void manageAdsProduct(List<Opportunity> listNewOpp, Map<Id, Opportunity> mapOldOpp){

        if(mapOldOpp == null){
            // US-0008007 insert default Ad_Product__c when Opportunity is inserted
            createDefaultProduct(listNewOpp);

        }else{
             // US-0008007 update Ad_Product__c.TotalPrice__c when Opportunity.Amount is updated and Opportunity.Ad_Products_with_Products__c == 0
            Map<Id,Opportunity> mapOppToRecal = new  Map<Id,Opportunity>();
            for(Opportunity eachOpp : listNewOpp){

                if(
                    (
                        eachOpp.Amount != mapOldOpp.get(eachOpp.Id).Amount
                        // US-0008451 allow fields below to trigger the populating ad product
                        || eachOpp.Start_Date__c != mapOldOpp.get(eachOpp.Id).Start_Date__c
                        || eachOpp.End_Date__c != mapOldOpp.get(eachOpp.Id).End_Date__c
                        || eachOpp.CurrencyISOCode != mapOldOpp.get(eachOpp.Id).CurrencyISOCode //MN-22062021-Sync CurrencyISOCode from Opp to Default AP
                    )
                    // US-0008451 the one line below can be removed later if we need to update some other fields beside Amount,Start_Date__c,End_Date__c.
                    && (eachOpp.Number_of_Primary_Quotes__c == 0 && !eachOpp.Quote_Sync_In_Progress__c)
                ){
                    mapOppToRecal.put(eachOpp.Id,eachOpp);
                }
            }

            if(!mapOppToRecal.isEmpty()){
                updateProduct(mapOppToRecal);
            }

        }

    }

    private static void createDefaultProduct(List<Opportunity> listNewOpp){

        List<Ad_Product__c> listAdProdToInsert = new List<Ad_Product__c>();

        for(Opportunity eachOpp : listNewOpp){

                Ad_Product__c initAdProd = new Ad_Product__c(Opportunity__c = eachOpp.Id , Quantity__c = 0, CurrencyISOCode=eachOpp.CurrencyISOCode); //MN-22062021-Sync Currency from OPP to Default AP

                // US-0008451 populating field "from and until date" of ad product when opp init
                updateAdProdFromAndUntilDate(initAdProd,eachOpp);

                listAdProdToInsert.add(initAdProd);
        }

        insert listAdProdToInsert;


    }

    private static void updateProduct(Map<Id,Opportunity> mapOppToRecal){
        
        List<Ad_Product__c> listAdProdToUpdate = new List<Ad_Product__c>();

        for(Ad_Product__c eachAdProd : [SELECT Id, TotalPrice__c, Quote_Line_Item__c, Opportunity__c From Ad_Product__c Where Opportunity__c IN : mapOppToRecal.keySet()]){
                
            if(eachAdProd.Quote_Line_Item__c == null){ // only intial ad product can be updated from opp

                Opportunity eachOpp = mapOppToRecal.get(eachAdProd.Opportunity__c);

                // US-0008451 populating field "from and until date" of ad product when opp start and end date are changed
                updateAdProdFromAndUntilDate(eachAdProd,eachOpp);
    
                listAdProdToUpdate.add(eachAdProd);
            }

        }


        if(!listAdProdToUpdate.isEmpty()){
            update listAdProdToUpdate;
        }

    }


    private static void updateAdProdFromAndUntilDate(Ad_Product__c eachAdProd, Opportunity eachOpp){
        // US-0008451 populating field "from and until date" of ad product
        
        // eachOpp.Number_of_Primary_Quotes__c is roll-up summary field, having no child records is equal to 0
        if(eachOpp.Number_of_Primary_Quotes__c == 0 && !eachOpp.Quote_Sync_In_Progress__c){

            eachAdProd.from_Date__c = eachOpp.Start_Date__c;
            eachAdProd.until_Date__c = eachOpp.End_Date__c;

            // eachOpp.Ad_Products_with_Products__c is roll-up summary field, having no child records is equal to 0
            if(eachOpp.Ad_Products_with_Products__c == 0){ eachAdProd.TotalPrice__c = eachOpp.Amount; }

            //MN-22062021-Sync CurrencyISOCode from Opp to Default AP
            eachAdProd.CurrencyISOCode = eachOpp.CurrencyISOCode;

        }

    }

}