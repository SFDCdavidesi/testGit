/*****************************************************************************************************************************************************************
@ Class:          IntellumUserTriggerHandler
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
----------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history:  17.08.2021 / Sophal Noch / Created the class.
***********************************************************************************************************************************************************/
public class IntellumUserTriggerHandler {

    public final static string TRIGGERCONTROLLER = 'EBH Trigger Controller'; //custom setting name
    private static final String ACC_SELLER_RT = 'EBH_Seller';

    /*********************************************************************************************************************************
    @ Method:         prePopulateFields
    @ Version:        1.0
    @ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
    @ Event:		  before insert, before update
    @ Purpose:        US-0010060 - [Intellum] Implement base integration with Intellum
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  17.08.2021 / Sophal Noch / US-0010060 Created the method.
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  03.09.2021 / Sophal Noch / US-0010284 modified the method.
    *********************************************************************************************************************************/
    public static void prePopulateFields(List<intellumapp__IntellumUser__c> listNewIuser, Map<Id,intellumapp__IntellumUser__c> mapOldIUser){
        
        Boolean isInsert = mapOldIUser == null ? true : false;

        Set<String> setAppCode = new Set<String>();
        Set<String> setAppLogin = new Set<String>();
        List<intellumapp__IntellumUser__c> listIUserToPopulateSeller = new List<intellumapp__IntellumUser__c>();
       
        for(intellumapp__IntellumUser__c iUser : listNewIuser){

            if(isInsert && iUser.Seller__c == null && !iUser.DoNotMatchWithSeller__c){

                if(iUser.intellumapp__code__c != null || iUser.intellumapp__login__c != null) listIUserToPopulateSeller.add(iUser);

                // Sophal / 03.09.2021 / US-0010284 : use in querying Seller
                if(iUser.intellumapp__code__c != null)  setAppCode.add(iUser.intellumapp__code__c);
                if(iUser.intellumapp__login__c != null)  setAppLogin.add(iUser.intellumapp__login__c);

            }

        }

        if(!listIUserToPopulateSeller.isEmpty()){ // Sophal / 03.09.2021 / US-0010284

            Map<String,Id> mapApiUserIdToSellerId = new Map<String,Id>();
            Map<String,Id> mapSellerNameToSellerId = new Map<String,Id>();

            for(Account seller : [Select Id, eBay_API_User_Id__c, Name From Account 
                                Where RecordType.DeveloperName =: ACC_SELLER_RT
                                AND(eBay_API_User_Id__c IN: setAppCode OR Name IN: setAppLogin) 
                                Order By Id Desc]
            ){

                if(seller.eBay_API_User_Id__c != null) mapApiUserIdToSellerId.put(seller.eBay_API_User_Id__c, seller.Id);
                mapSellerNameToSellerId.put(seller.Name, seller.Id); // Sophal / 03.09.2021 / US-0010284 : Account.Name is never empty, so need to check field null or not

            }

            if(!mapApiUserIdToSellerId.isEmpty() || !mapSellerNameToSellerId.isEmpty()){

                for(intellumapp__IntellumUser__c iUser : listIUserToPopulateSeller){
    
                    Id sellerId = mapApiUserIdToSellerId.get(iUser.intellumapp__code__c);
                    if(sellerId == null) sellerId = mapSellerNameToSellerId.get(iUser.intellumapp__login__c);
                    
                    iUser.Seller__c = sellerId != null ? sellerId : iUser.Seller__c;
                    
                }
            }


        }
    }

}