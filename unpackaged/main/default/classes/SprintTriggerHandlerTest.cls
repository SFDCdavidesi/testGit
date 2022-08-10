/*********************************************************************************************************************************
@ Class:          SprintTriggerHandlerTest
@ Version:        1.0
@ Author:         Sovantheany.Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        Handler test Class for SprintTrigger (Sprint__c)
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 16.1.2019 / Sovantheany.Dim / Created the class.
@ Change history: 04.07.2022 / Chetra Sarlom / US-0007031 - Deactivate triggers
*********************************************************************************************************************************/
@isTest
private class SprintTriggerHandlerTest {

    //@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
	static testMethod void testcompleteTestClass() { 
		SprintTriggerHandler.completeTestClass();
	} 

    //@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    /* static testMethod void testcreatedOrUpdateSprint() {
    	System.runAs(EBH_TestDataFactory.createUser('System Administrator')){
            Test.startTest();
            User businessAdm = EBH_TestDataFactory.createUser('Business Admin');
            businessAdm.IsActive = true;
            businessAdm.Competency__c = 'Copy';
            insert businessAdm;
            
            Group g = [Select id From Group g where DeveloperName =: EBH_ConstantsUtility.GROUP_MARKETING_EXC];
            GroupMember gMember = new GroupMember(GroupId = g.ID,UserOrGroupId=businessAdm.Id);
            insert gMember;
                
            List<SPRINT__c> lstSprint = new List<SPRINT__c>();
            for(Integer i = 0 ; i < 5 ; i++){
                SPRINT__c newSprint = new SPRINT__c();
                newSprint.Sprint_Name__c = 'Sprint'+i;
                newSprint.From__c = date.newInstance(2019,1,16);
                newSprint.To__c = date.newInstance(2019,1,17);
                lstSprint.add(newSprint);
            }
            insert lstSprint;
            Test.stopTest();
            List<Sprint_Capacity_Users__c> lstSprintUser = [select From__c, To__c, User__c,Available_capacity_Copy__c from Sprint_Capacity_Users__c where User__c =: businessAdm.ID];
            
            //@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
            
            System.assert(lstSprintUser.size() == 5);
            for(Sprint_Capacity_Users__c spu : lstSprintUser){
                System.assert(spu.From__c == date.newInstance(2019,1,16));
                System.assert(spu.To__c == date.newInstance(2019,1,17));
            }
            
            
            lstSprint[0].From__c = date.newInstance(2019,1,15);
            update lstSprint[0];
            
            Sprint_Capacity_Users__c sprintUser = [select From__c, To__c, User__c from Sprint_Capacity_Users__c where User__c =: businessAdm.ID and Sprint__c =: lstSprint[0].ID];
            System.assert(sprintUser.From__c == date.newInstance(2019,1,15));
            System.assert(sprintUser.To__c == date.newInstance(2019,1,17));
            
    	}
    }*/
}