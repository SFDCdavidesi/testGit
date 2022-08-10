public with sharing class DealClonePageController {
    
    private ID dealId;
    Private EBH_Deal__c deal;
    public DealClonePageController(ApexPages.StandardController controller) {
        
        if (!test.isRunningTest()){
            controller.addFields(EBH_ConstantsUtility.DEAL_CLONE_FIELDS_TO_COPY);
        }
        
        dealId = controller.getId();
        deal = (EBH_Deal__c)controller.getRecord();
        
        
    }
    
    public pageReference clonecustom(){
        
        EBH_Deal__c d = deal.clone();
        d.EBH_DealPrice__c=0;
        insert d;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Cloned Successfully.Thank you!'));
        PageReference pg = new PageReference('/'+d.Id);
        pg.setRedirect(true);
        return pg; 
    }
}