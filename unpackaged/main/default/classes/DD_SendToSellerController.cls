/**
Create VF list view button

Allows user to select Deal records from list view. 
Need to validate that all Deals records selected have been 'Internally Approved' 
once validated pass records to class created in 00201530


CR00397704
Need to update the code for both butters on sent to seller 
and Send for Approval so that if they are already sent the email to the user or the seller(s). 
This should only be possible if they are in Status 'Sent to Seller' or 'In Approval' for the respective buttons

*/
public without sharing class DD_SendToSellerController {
    
    public List<EBH_Deal__c> selectedDeal {get;set;}
    public Integer dealSize {get;set;}
    public Boolean displayPopup {get; set;}
    ApexPages.StandardSetController setCon;
    public static Deal_Timezone__c dealTimezone = Deal_Timezone__c.getInstance();
    
    public List<DD_SendToSellerHelper.ContractAgreementWrapper> dcas {get;set;}
    public Boolean isNotInternalApproved {get;set;}
    public Boolean isAfterStartDate {get;set;}
    public Boolean isError {get;set;}
    
    public static final string INTERNALLY_APPROVED = 'Internally Approved';
    public static final string EXPIRED = 'Expired';
    public static final string SENT_TO_SELLER = 'Sent to Seller';
    private static final Set<String> ALLOWED_STATUS = new Set<String> { INTERNALLY_APPROVED, SENT_TO_SELLER, EXPIRED}; // 28.05.2021 / Sophal Noch / US-0009533

    public static Boolean PROCESS_SENT_SELLER = false;
    public static final String NA_PROFILE = 'NA Standard User Base';
    public final static String US_MANAGE_DEAL_PERM='Select PermissionSet.Name, PermissionSetId, AssigneeId From PermissionSetAssignment  where PermissionSet.Name IN (\'US_Manage_Deals\') AND AssigneeId=:currentUserId  limit  1';
    //public static final string INTERNALLY_APPROVED = 'Negotiating';
    
    @TestVisible private static Integer CHUNK_SIZE_LIMIT = 25;
    // public List<Id> lstAllDealId {get{return lstAllDealId = (lstAllDealId !=null ? lstAllDealId : new List<Id>());} set;}


    public Map<String,Object> mapChunkedDeal {get{return mapChunkedDeal = (mapChunkedDeal !=null ? mapChunkedDeal : new Map<String,Object>());} set;}
    public Integer chunkIndex {get{return chunkIndex = (chunkIndex !=null ? chunkIndex : 0);} set;}
    public Integer chunkSize {get{return chunkSize = (chunkSize !=null ? chunkSize : 0);} set;}
    public Boolean canContinueSending {get;set;}
    public Boolean finishSending{get{return finishSending = (finishSending !=null ? finishSending : false);} set;}
    public String errorMessage {get;set;}

    @TestVisible private Set<Id> setDealIdToSendEmail = new Set<Id>();
    @TestVisible private Set<Id> setPrevInternally = new Set<Id>();
    // private Set<Id> setPrevSendToSeller = new Set<Id>();

    private Id dealNA;
   

    public DD_SendToSellerController(ApexPages.StandardSetController controller) { 
        isError = false;
        isNotInternalApproved = false;
        isAfterStartDate = false;
        setCon = controller;
        selectedDeal = controller.getSelected();
        Timezone tz = Timezone.getTimeZone(dealTimezone.TimeZone__c);
        Datetime dNow =  DateTime.newInstance(System.Now().getTime() + tz.getOffset(System.Now()));
        String NAprofile = ApexUtil.getProfileByName(NA_PROFILE).Id;
        Boolean isNA = UserInfo.getProfileId().equals(NAprofile);
        Boolean isAdmin = UserInfo.getProfileId().equals(EBH_ConstantsUtility.ADMIN_PROFILE_ID);
        String currentUserId = UserInfo.getUserId();

        List<Id> lstAllDealId = new List<Id>();

        dealNA = Schema.SObjectType.EBH_Deal__c.getRecordTypeInfosByName().get('NA Deal').getRecordTypeId();
    	
        
        for(EBH_Deal__c deal : [select EBH_Status__c, EBH_DealStartDate__c, EBH_DealStartTime__c, seller_approved__c, cancelled_deal__c from EBH_Deal__c where id IN: selectedDeal]){
            
            if(deal.EBH_Status__c != INTERNALLY_APPROVED && deal.EBH_Status__c != SENT_TO_SELLER && deal.EBH_Status__c != EXPIRED){
                isNotInternalApproved = true;
            }

            Boolean isExpired = DD_SendToSellerHelper.checkExpiredDeal(deal,dNow);
            
            if(deal.EBH_Status__c == EXPIRED && deal.seller_approved__c == false && deal.cancelled_deal__c == false && isExpired){ // 04.06.2021 / Sophal Noch / US-0009649
                isAfterStartDate = true;
            }
            
            // if(deal.EBH_Status__c == EXPIRED || (deal.EBH_Status__c != SENT_TO_SELLER && isExpired)){ // 28.05.2021 / Sophal Noch / US-0009533
            //     isAfterStartDate = true;
            // }

            if(deal.EBH_Status__c == INTERNALLY_APPROVED || deal.EBH_Status__c == SENT_TO_SELLER || deal.EBH_Status__c == EXPIRED){ // 28.05.2021 / Sophal Noch / US-0009533
                lstAllDealId.add(deal.Id);
            }

        }

        mapChunkedDeal = ApexUtil.chunkList(lstAllDealId,CHUNK_SIZE_LIMIT);

        chunkSize = (Integer)mapChunkedDeal.get('chunkSize');

        
        if(checkingHasNoPermission()){
            //System.debug('ERROR>>>>>');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.NA_CANCEL_FUNC_ERR2));
            isError = true;
            return;
        }

        
        dealSize = selectedDeal.size();
        if (dealSize>0) {
            displayPopup = true;
        }
    }
    


    // Sophal:27/04/2021: US-0009436 disable because we use client side to fix cpu limit
    /**
    * Send to Seller
    * we only take Internally Approved/Sent to Seller Deals
    */
    // public PageReference sentToSellerAction() {
        
    //     //try{
    //         	PROCESS_SENT_SELLER = true;
    //             Map<String,List<EBH_Deal__c>> deals = loadDeals();
                
    //             // 2 blocs 
    //             // for INTERNALLY_APPROVED do normal process
    //             // for SENT_TO_SELLER we re sent email
    //             List<EBH_Deal__c> listINTERNALLY_APPROVED = deals.get(INTERNALLY_APPROVED);
    //             if(deals.containskey(EXPIRED)&&deals.containskey(INTERNALLY_APPROVED))listINTERNALLY_APPROVED.addall(deals.get(EXPIRED));
    //             else if(deals.containsKey(EXPIRED))listINTERNALLY_APPROVED = deals.get(EXPIRED);
    //             List<EBH_Deal__c> listSENT_TO_SELLER = deals.get(SENT_TO_SELLER);
                
    //             if (listINTERNALLY_APPROVED!=null && !listINTERNALLY_APPROVED.isEmpty()) {
    //                 updateDeals(listINTERNALLY_APPROVED); 
    //                 System.debug('<<<<listINTERNALLY_APPROVED:'+listINTERNALLY_APPROVED);
    //                 dcas = DD_SendToSellerHelper.createDealContractAgreement(listINTERNALLY_APPROVED);
                    
    //                 //DD_SendToSellerHelper.sendEmail(dcas, listINTERNALLY_APPROVED, false);  
                    
    //             }
                
    //             if (listSENT_TO_SELLER!=null && !listSENT_TO_SELLER.isEmpty()) {
    //                 dcas = DD_SendToSellerHelper.convertTContractAgreementWrapper(listSENT_TO_SELLER);
    //                 updateDeals(listSENT_TO_SELLER);
    //             }
                
                
    //         	PROCESS_SENT_SELLER = false;
    //     /*}catch (Exception ex) {
    //         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
    //         DD_Utils.PROCESS_SENT_SELLER = false;
    //         return null;
    //     }*/
    //     // bring user to the Contract Agreement ?
    //     return setCon.cancel();
    // }


    
    /*********************************************************************************************************************************
    @ Method:         sentToSellerAction
    @ Version:        1.0
    @ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:        US-0009436
                      use client side to send deal to seller. this is to fix the error CPU limit
    @ Event:		  when user click button 'Send to Seller'
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	list id of deal, list id of deal to send email later,
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  27.04.2021 / Sophal Noch / Created the method.
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  24.06.2021 / Sophal Noch / US-0009754 modifed the method to be non-static method because we stop using remote action in vf page
    *********************************************************************************************************************************/  
    public PageReference sentToSellerAction() {

        canContinueSending = false;
        
        try{

                // if(checkingHasNoPermission()){ mapResult.put('status','ko'); mapResult.put('error',  System.Label.NA_CANCEL_FUNC_ERR2);return mapResult;}

                if(chunkIndex < chunkSize && !finishSending){

                    List<List<Object>> listAllDealChunk = (List<List<Object>>)mapChunkedDeal.get('listAllChunk');
                    
                    Set<Id> setDealId = new Set<Id>();
                    for(Object objId : listAllDealChunk[chunkIndex]){
                        setDealId.add((Id)objId);
                    }
        
                    Map<String,Map<Id,EBH_Deal__c>> mapDeals = loadDeals(setDealId);
    
                    Map<Id, EBH_Deal__c> mapDealInternallApproved = mapDeals.get(INTERNALLY_APPROVED); // 28.05.2021 / Sophal Noch / US-0009533 use 'internally approved' deal only
                    
                    // 04.06.2021 / Sophal Noch / US-0009649
                    if(mapDeals.containskey(EXPIRED) && mapDeals.containskey(INTERNALLY_APPROVED)) mapDealInternallApproved.putAll(mapDeals.get(EXPIRED));
                    else if(mapDeals.containsKey(EXPIRED)) mapDealInternallApproved = mapDeals.get(EXPIRED);
    
    
                    Map<Id,EBH_Deal__c> mapDealSentToSeller = mapDeals.get(SENT_TO_SELLER);
    
                    List<DD_SendToSellerHelper.ContractAgreementWrapper> dcas;
                    
                    if (mapDealInternallApproved != null && !mapDealInternallApproved.isEmpty()) {
                        
                        updateDeals(mapDealInternallApproved.values()); 
                        
                        dcas = DD_SendToSellerHelper.createDealContractAgreement(mapDealInternallApproved.values(), doQueryDeals(dealNA, ALLOWED_STATUS, setPrevInternally) );
    
                        setDealIdToSendEmail.addAll(mapDealInternallApproved.keySet());
                        setPrevInternally.addAll(mapDealInternallApproved.keySet());
                        
                    }
                    
                    if (mapDealSentToSeller != null && !mapDealSentToSeller.isEmpty()) {
                        
                        // dcas = DD_SendToSellerHelper.convertTContractAgreementWrapper(mapDealSentToSeller.values(), doQueryDeals(dealNA, ALLOWED_STATUS, listPrevSendToSeller));
                        dcas = DD_SendToSellerHelper.convertTContractAgreementWrapper(mapDealSentToSeller.values(), new List<EBH_Deal__c>()); // Sophal:29/04/2021: US-0009476 no need to check previous deal for already 'sent to seller' deals
                        // updateDeals(mapDealSentToSeller.values()); 
    
                        setDealIdToSendEmail.addAll(mapDealSentToSeller.keySet());
    
                        // setPrevSendToSeller.addAll(mapDealSentToSeller.keySet()); not used
    
                    }
                    
                    chunkIndex++;
                    if(chunkIndex >= chunkSize){
                        finishSending = true;
                    }else{
                        canContinueSending = true;
                    }
                }




        }catch (Exception ex) { isError = true;  errorMessage = ex.getMessage(); System.debug('nsp: ex == '+ex.getMessage()); ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));}

        return null;

    }

    private static Boolean checkingHasNoPermission() {

        Boolean hasNoPermission = false;

        String currentUserId = UserInfo.getUserId();
        String NAprofile = ApexUtil.getProfileByName(NA_PROFILE).Id;
        Boolean isAdmin = UserInfo.getProfileId().equals(EBH_ConstantsUtility.ADMIN_PROFILE_ID);
        Boolean isNA = UserInfo.getProfileId().equals(NAprofile);

        List<PermissionSetAssignment> listPSA = Database.query(US_MANAGE_DEAL_PERM);
        if( !isAdmin && !isNA || (isNA && listPSA.isEmpty())){
            hasNoPermission = true;
        }

        return hasNoPermission;
    }


    /*********************************************************************************************************************************
    @ Method:         sendEmailToSellerAction
    @ Version:        1.0
    @ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:        US-0009436
                      use client side to send email to seller. this is to fix the error CPU limit
    @ Event:		  when user click button 'Send to Seller'
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	list id of deal, list id of deal to send email later,
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  27.04.2021 / Sophal Noch / Created the method.
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  24.06.2021 / Sophal Noch / US-0009754 modifed the method to be non-static method because we stop using remote action in vf page
    *********************************************************************************************************************************/  
    public Pagereference sendEmailToSellerAction() {

        try{
            if(!setDealIdToSendEmail.isEmpty()){
                DD_SendToSellerHelper.sendApprovalToExternalSeller(doQueryDeals(dealNA, ALLOWED_STATUS, setDealIdToSendEmail));
            }
        }catch (Exception ex) { isError = true;  errorMessage = ex.getMessage(); System.debug('nsp: email sending err == '+ex.getMessage()); ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));}
        return null;


    }

    public Pagereference prepareToSend() {return null;}  // Sophal:28/06/2021: to make it work on firefox, call empty method first

    private static List<EBH_Deal__c> doQueryDeals(Id dealNA, Set<String> status, Set<Id> setDealId ){

        // Sophal:27/04/2021: US-0009436 query deal when send to seller and when to send email

        if(!setDealId.isEmpty()){

            return [ Select Id,EBH_Status__c,
                EBH_DealStartDate__c,
                EBH_DealStartTime__c,
                Seller_Approver_1__c, 
                Seller_Approver_2__c,
                Seller_Approver_3__c,
                Seller_Approver_4__c,
                Seller_Approver_5__c,
                Seller_Approver_1_Email__c,
                Seller_Approver_2_Email__c,
                Seller_Approver_3_Email__c,
                Seller_Approver_4_Email__c,
                Seller_Approver_5_Email__c,
                Name,
                Current_Digest__c,
                Deal_Contract_Agreement__c,
                Deal_Contract_Agreement__r.Current_Digest__c, 
                EBH_BusinessName__c,
                Deal_Contract_Seller_Name__c,
                SiteURL__c,
                OwnerId,
                Owner.Name from EBH_Deal__c 
                Where  RecordTypeId =:dealNA
                        And id in : setDealId
                        And EBH_status__c in :status
                        Order by EBH_BusinessName__c
            ];
            
        }else{return new List<EBH_Deal__c>();}


    }


    private Map<String,Map<Id, EBH_Deal__c>> loadDeals(Set<Id> setDealId) {

        // Sophal:27/04/2021: US-0009436 loadDeals to send to seller
        // Sophal:24/06/2021: US-0009754 change to non static method
        
        Map<String,Map<Id, EBH_Deal__c>> res = new  Map<String,Map<Id, EBH_Deal__c>>();
         
        for (EBH_Deal__c d : doQueryDeals(dealNA, ALLOWED_STATUS, setDealId)) {
            // 28.05.2021 / Sophal Noch / US-0009533 optimize way to store variable in collection
            if(!res.containsKey(d.EBH_Status__c)){
                res.put(d.EBH_Status__c,new Map<Id,EBH_Deal__c>());
            }
            res.get(d.EBH_Status__c).put(d.Id,d);
             
        }
                                                     
        return res;
 }
    
     // Sophal:27/04/2021: US-0009436 disable because we use client side to fix cpu limit

    // private Map<String,List<EBH_Deal__c>> loadDeals() {
    //        ID dealNA = Schema.SObjectType.EBH_Deal__c.getRecordTypeInfosByName().get('NA Deal').getRecordTypeId();
           
    //        Map<String,List<EBH_Deal__c>> res = new  Map<String,List<EBH_Deal__c>>();
    //        Set<String> status = new Set<String> {INTERNALLY_APPROVED,SENT_TO_SELLER,EXPIRED};
            
    //        for (EBH_Deal__c d : [Select Id,EBH_Status__c,
    //                                 Seller_Approver_1__c, 
    //                                 Seller_Approver_2__c,
    //                                 Seller_Approver_3__c,
    //                                 Seller_Approver_4__c,
    //                                 Seller_Approver_5__c,
    //                                 Name, 
    //                                 Deal_Contract_Agreement__c,
    //                                 Deal_Contract_Agreement__r.Current_Digest__c, 
    //                                 EBH_BusinessName__c,
    //                                 OwnerId,
    //                                 Owner.Name from EBH_Deal__c 
    //                                             where  RecordTypeId =:dealNA
    //                                                     and id in : selectedDeal
    //                                                     and EBH_status__c in :status
    //                                                     order by EBH_BusinessName__c]) 
    //                                                     {
                    
                        
    //                     List<EBH_Deal__c> l = res.get(d.EBH_Status__c);
                        
    //                     if (l==null) {
    //                         l = new List<EBH_Deal__c>();
    //                     }

    //                     l.add(d);
                        
    //                     res.put(d.EBH_Status__c,l);
                
    //         }
         
                                                        
    //          return res;
    // }
    
    // update deals to 'Sent to Seller'     
    public static void updateDeals(List<EBH_Deal__c> deals) {
    	 
    	 
          	List<EBH_Deal__c> dealstobeupdated = new List<EBH_Deal__c>();
             for (EBH_Deal__c d : deals) {
             	//if (sellersent.contains(d.EBH_BusinessName__c)) {
             		d.EBH_Status__c=SENT_TO_SELLER;
                	dealstobeupdated.add(d);
             	//}
              }
                    
             if (!dealstobeupdated.isEmpty()) {
                 update dealstobeupdated;
              }
          
    }

    public PageReference cancel(){
        return setCon.cancel();
    }
}