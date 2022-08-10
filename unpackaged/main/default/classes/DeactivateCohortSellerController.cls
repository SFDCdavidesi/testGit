/*********************************************************************************************************************************
@ Class:          DeactivateCohortSellerController
@ Version:        1.0
@ Author:         Chetra Sarom
@ Purpose:        14.07.2022/ US-0012010 - Add New Button "Deactivate Sellers" Button next to "Remove Sellers"
*********************************************************************************************************************************/
public with sharing class DeactivateCohortSellerController {
    private final static String BOB_CATEGORY_PERMISSION = 'BoB_Category_Lead';
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
    public DeactivateCohortSellerController(ApexPages.StandardSetController controller) {
        selectedCohortSeller = (List<BoB_Seller__c>)controller.getSelected();
        numSelected = selectedCohortSeller.size();
        //reUrl = controller.cancel().getUrl();
         
        hasPermis = ApexUtil.checkPermissionSet(new Set<String>{BOB_CATEGORY_PERMISSION});
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

   
   public PageReference deactivateSellers(){
       try {
            
            // US-0012010 - Amends to "Remove Sellers" Button
            List<Account> lstAcc = new List<Account>();
            List<BoB_Seller__c> lstBS = new List<BoB_Seller__c>();

            for (BoB_Seller__c bs : [SELECT Id, Seller__c,Status__c FROM BoB_Seller__c WHERE Id IN:selectedCohortSeller]) {
                lstBS.add(new BoB_Seller__c(
                    Id = bs.Id,
                    Status__c = 'Inactive'
                ));
                lstAcc.add(new Account(
                    Id = bs.Seller__c,
                    Managed_Type__c = '',
                    OwnerId = ApexUtil.INTEGRATION_USER_ID,
                    EBH_BOBManaged__c = false,
                    EBH_BOBSegment__c = '',
                    EBH_BOBVertical__c= '',
                    EBH_BOBCNTRY__c= '',
                    EBH_AccountManageName__c = ''
                ));
            }

            update lstBS;
            update lstAcc;
            
            isError = false; 
            msg = System.Label.DEACTIVATE_COHORSELLER_SUCCESS;
            severity = ApexPages.severity.CONFIRM.name();      
            isDone = true;
       } catch (DMLException dmx) {          
            isError = true;  msg = dmx.getMessage(); severity = ApexPages.severity.FATAL.name();   
       }
       
        return null;
    }
}