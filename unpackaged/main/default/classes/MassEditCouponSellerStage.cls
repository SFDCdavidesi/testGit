/*********************************************************************************************************************************
@ Class:          MassEditCouponSellerStage
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        US-0009605 - Coupon Seller: mass update of stage button
@					As any user
@					Given that I am on the related of a Coupon record (either for Category Based or Item Based)
@					and I select All or a few coupon seller names
@					When I click on the button "Mass editstage"
@					I want to be able to mass update the field Coupon_Seller_Stage__c to the value "Reached" OR "Committed" OR "Negotiation" OR "Approved".
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 15.06.2021 / Sovantheany Dim / Created the class.
*********************************************************************************************************************************/
public without sharing class MassEditCouponSellerStage {
    public String reUrl{get;set;}
    //ApexPages.StandardSetController stdSetCtlr;
    public List<Coupon_Seller__c> selectedCouponSeller{get;set;}
    public boolean isCSStageOk{get;set;}
    public MassEditCouponSellerStage(ApexPages.StandardSetController controller) {
        isCSStageOk = true;
        //stdSetCtlr = controller;
        reUrl = controller.cancel().getUrl();
        selectedCouponSeller = (List<Coupon_Seller__c>)controller.getSelected();
        selectedCouponSeller = [Select Id,Coupon_Seller_Stage__c From Coupon_Seller__c Where Id IN :selectedCouponSeller];
        //display a message saying "Only the stages before contract is sent can be updated"
        Set<String> sCoupounSellerStageOld = new Set<String>(System.label.CouponSellerStageOld.split(','));
        for (Coupon_Seller__c cs : selectedCouponSeller) {
            if(!sCoupounSellerStageOld.contains(cs.Coupon_Seller_Stage__c)){
                isCSStageOk = false;
                break;
            }
        }
    }
    public pageReference cancelAction() {
        return new Pagereference(reUrl);
    }
    public boolean isChangedSuccess{get;set;}
    public void updateStageAction() {
        try{
            List<Coupon_Seller__c> lstSelectedCs = new List<Coupon_Seller__c>();
            for (Coupon_Seller__c cs : selectedCouponSeller) {
                Coupon_Seller__c objcs = new Coupon_Seller__c(Id = cs.Id,
                                     Coupon_Seller_Stage__c = selectedStageValue);
                lstSelectedCs.add(objcs);
            }
            if(!lstSelectedCs.isEmpty()) update lstSelectedCs;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM , 'Saved successfully!'));
            isChangedSuccess=true;
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            isChangedSuccess=false;
            //return null;
        }
        
        //return new Pagereference(reUrl);
    }
    
    public string selectedStageValue {get; set;}
    public List<SelectOption> getStageSelected() { 
        Schema.DescribeFieldResult stageDescription = Coupon_Seller__c.Coupon_Seller_Stage__c.getDescribe(); 
		Set<String> sCoupounSellerStage = new Set<String>(System.label.CouponSellerStageNew.split(','));
 	 	List<SelectOption> options = new List<SelectOption>();
 	 	//options.add(new SelectOption('','--None--'));
 	 	for (Schema.Picklistentry pl : stageDescription.getPicklistValues())
        {
            if(sCoupounSellerStage.contains(pl.getValue())) options.add(new SelectOption(pl.getValue(),pl.getLabel()));
        }
 	 	return options;
  	}
    
}