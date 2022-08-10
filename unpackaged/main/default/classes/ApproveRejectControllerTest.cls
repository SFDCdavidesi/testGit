@isTest
private  class ApproveRejectControllerTest {

    static testMethod void testApproveReject(){
        Final_Value_Fee_FVF__c fvf1 = new Final_Value_Fee_FVF__c(Final_Value_Fee_Stage__c=EBH_ConstantsUtility.FVF_STAGE_EBAY_SENT_TO_APPROVE);
        Final_Value_Fee_FVF__c fvf2 = new Final_Value_Fee_FVF__c(Final_Value_Fee_Stage__c=EBH_ConstantsUtility.FVF_STAGE_EBAY_SENT_TO_APPROVE);
        Final_Value_Fee_FVF__c fvf3 = new Final_Value_Fee_FVF__c(Final_Value_Fee_Stage__c='Draft');
        insert new Final_Value_Fee_FVF__c[]{fvf1,fvf2,fvf3};


        Test.startTest();
            ApproveRejectController.apexInit(fvf1.Id);
            ApproveRejectController.apexDoApprove(fvf1.Id+'', 'comments1');
            ApproveRejectController.apexDoReject(fvf2.Id+'', 'comments2');
            ApproveRejectController.apexDoReject(fvf3.Id+'', 'comments3');

            Final_Value_Fee_FVF__c f1 = [Select Id,Approved_Date__c,Rejected_Date__c From Final_Value_Fee_FVF__c where Id=:fvf1.Id];
            Final_Value_Fee_FVF__c f2 = [Select Id,Approved_Date__c,Rejected_Date__c From Final_Value_Fee_FVF__c where Id=:fvf2.Id];

            System.assert(f1.Approved_Date__c<>null, 'approved date populated');
            System.assert(f2.Rejected_Date__c<>null, 'rejected date populated');
        Test.stopTest();
        
    } 
}