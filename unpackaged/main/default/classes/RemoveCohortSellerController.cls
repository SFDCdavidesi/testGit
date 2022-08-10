/*********************************************************************************************************************************
@ Class:          RemoveCohortSellerController
@ Version:        1.0
@ Author:         Sreymeas Nao 
@ Purpose:        US-0008068: [LTTM] Bulk Removal of Cohort Sellers capability and Field Label Change
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 20.08.2020 / Sreymeas Nao / Created the class.  
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 17.09.2021 / Mony Nou / US-0010407 - [BoB] Empty Seller."Owner" when Category Leads click "Remove Sellers"
@                   21/06/2022 / Sovantheany Dim / US-0011890 - Grant "NA Standard User base" users with access to Light touch Pro-trader and aSelleration capablities
*********************************************************************************************************************************/
public without sharing class RemoveCohortSellerController {
    private final static String BOB_CATEGORY_PERMISSION = 'BoB_Category_Lead';
    private final static String NA_STANDARD_PERMISSION = 'US_CA_Standard_user';//TH:21/06/2022:US-0011890
    public List<BoB_Seller__c> selectedCohortSeller {get;set;}
    public String reUrl{get;set;}
 
    public String msg {get;set;}
    public Integer numSelected {get;set;}
    public Boolean hasPermis {get;set;}
    public Boolean isAdmin {get;set;}

    public Boolean isDone {get;set;}  //when save button already clicked
    public Boolean isError {get;set;} //warning or error 
    public String severity {get;set;} // warning,info,error,confirm

    private String bobId = null;

    public RemoveCohortSellerController(ApexPages.StandardSetController controller) {
        selectedCohortSeller = (List<BoB_Seller__c>)controller.getSelected();
        numSelected = selectedCohortSeller.size();
        //reUrl = controller.cancel().getUrl();
         
        hasPermis = ApexUtil.checkPermissionSet(new Set<String>{BOB_CATEGORY_PERMISSION, NA_STANDARD_PERMISSION});
        isAdmin = UserInfo.getProfileId().equals(EBH_ConstantsUtility.ADMIN_PROFILE_ID);
        
        bobId = ApexPages.currentPage().getParameters().get('id');
        reUrl = '/lightning/r/'+bobId+'/related/BoB_Sellers__r/view';
        isError = false;
        isDone = false;
        msg = System.Label.TEXT_MSG_FOR_DEACTIVATE_SELLER;
        severity = ApexPages.severity.INFO.name();

        if(!isAdmin && !hasPermis)
        {
            isError = true; 
            msg = System.Label.ERR_MSG_NO_BOB_CATEGORY_LEAD_PERMIS;
            severity = ApexPages.severity.WARNING.name();
        }else if(numSelected==0)
        {
            isError = true; 
            msg = System.Label.TEXT_MSG_FOR_UNABLE_TO_REMOVE_SELLER;
            severity = ApexPages.severity.WARNING.name();
        }
        
        
    }

    public PageReference backToListView(){
        PageReference pageRef = new PageReference(reUrl);
        pageRef.setRedirect(true);
        return pageRef;
   }

   
   public PageReference removeSellers(){
       try {
            
            /* MN-23092021-Move this logic into BoBSellerTriggerHandler.removeRelatedRecordWithCohortSeller() instead
            //MN-17092021-US-0010407 - Delete the related "Actions" tied to the Cohort Seller
            delete [SELECT Id FROM Action__c WHERE LTTM_Seller__c IN:selectedCohortSeller];

            //MN-17092021-US-0010407 - Reset Seller fields
            List<Account> lstAcc = new List<Account>();
            for (BoB_Seller__c bs : [SELECT Seller__c FROM BoB_Seller__c WHERE Id IN:selectedCohortSeller]) {
                lstAcc.add(new Account(
                    Id = bs.Seller__c,
                    OwnerId = ApexUtil.INTEGRATION_USER_ID,
                    Managed_Type__c = '',
                    EBH_BOBManaged__c = false,
                    EBH_BOBSegment__c = ''
                ));
            }
            //----MN-17092021-US-0010407 - Reset Seller fields
            update lstAcc; //MN-17092021-US-0010407 - Reset Seller fields
            */

            delete selectedCohortSeller;

            isError = false; 
            msg = System.Label.RM_COHORSELLER_SUCCESS;
            severity = ApexPages.severity.CONFIRM.name();      
            isDone = true;
       } catch (DMLException dmx) {          
            isError = true;  msg = dmx.getMessage(); severity = ApexPages.severity.FATAL.name();   
       }
       
        return null;
    }


}