/*********************************************************************************************************************************
@ Class:         BatchTargetingEngineDeletionTest
@ Version:       1.0
@ Author:        Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:       Test class for: BatchTargetingEngineDeletion
@				 
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 09.01.2019 / Vadhanak Voun (vadhanak.voun@gaea-sys.com) / Created the class.
*********************************************************************************************************************************/
@isTest
private class BatchTargetingEngineDeletionTest {

    static testMethod void testDeleteTE_batch() {
        RecordType te_Manual = ApexUtil.getRecordTypeByName('EBH_Filter__c','EBH_ManualSellerList');
        EBH_Filter__c te_m1 = new EBH_Filter__c(Name='TE1',EBH_TE_Expiration_Date__c=System.Today().addDays(5),RecordtypeId=te_Manual.Id);
        EBH_Filter__c te_m2 = new EBH_Filter__c(Name='TE2',EBH_TE_Expiration_Date__c=System.Today().addDays(5),RecordtypeId=te_Manual.Id);
        EBH_Filter__c te_m3 = new EBH_Filter__c(Name='TE3',EBH_TE_Expiration_Date__c=System.Today().addDays(-2),RecordtypeId=te_Manual.Id);
        
        insert new List<EBH_Filter__c>{te_m1,te_m2,te_m3};
        
        Test.startTest();
        	BatchTargetingEngineDeletion bTE = new BatchTargetingEngineDeletion();
        	bTE.execute(null);
        Test.stopTest();
        
        List<EBH_Filter__c> listTESel = [Select Id From EBH_Filter__c];
        System.assertEquals(2,listTESel.size(),'1 expired date already deleted. 2 remains in the system.');
        
    }
}