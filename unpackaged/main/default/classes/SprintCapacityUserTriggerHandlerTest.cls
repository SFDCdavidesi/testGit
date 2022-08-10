/*********************************************************************************************************************************
@ Class:          SprintCapacityUserTriggerHandlerTest
@ Version:        1.0
@ Author:         Sovantheany.Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        Handler test Class for SprintCapacityUserTrigger (Sprint_Capacity_Users__c)
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 17.1.2019 / Sovantheany.Dim / Created the class.
@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
*********************************************************************************************************************************/
@isTest
private class SprintCapacityUserTriggerHandlerTest {

	//@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
	static testMethod void testcompleteTestClass() { 
		SprintCapacityUserTriggerHandler.completeTestClass();
	} 
	
	//@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
	/*
	static testMethod void testupdatedSprintCapacityUser() {
    	System.runAs(EBH_TestDataFactory.createUser('System Administrator')){
    		Test.startTest();
    	
    		User businessAdm = EBH_TestDataFactory.createUser('Business Admin');
    		businessAdm.IsActive = true;
    		businessAdm.Competency__c = 'Copy';
    		insert businessAdm;
    		
    		Day__c d = new Day__c();
    		d.User__c = businessAdm.Id;
    		d.Day__c = date.newInstance(2019,1,16);
    		d.Available_capacity_of_your_work_time__c = 10;
    		d.OwnerId = businessAdm.Id;
    		insert d;
    		
    		Group g = [Select id From Group g where DeveloperName =: EBH_ConstantsUtility.GROUP_MARKETING_EXC];
    		GroupMember gMember = new GroupMember(GroupId = g.ID,UserOrGroupId=businessAdm.Id);
    		insert gMember;
        	SPRINT__c newSprint = new SPRINT__c();
        	newSprint.Sprint_Name__c = 'Sprint1';
        	newSprint.From__c = date.newInstance(2019,1,15);
        	newSprint.To__c = date.newInstance(2019,1,17);
        	insert newSprint;
        	
        	Sprint_Capacity_Users__c sprintUser = [select From__c, To__c, User__c,Available_capacity_Copy__c from Sprint_Capacity_Users__c where User__c =: businessAdm.ID];
        	System.assert(sprintUser.From__c == date.newInstance(2019,1,15));
        	System.assert(sprintUser.To__c == date.newInstance(2019,1,17));  
        	System.debug('<<<<<sprintUser='+sprintUser);
        	System.assert(sprintUser.Available_capacity_Copy__c == 0.8);  
        	
        	User businessAdm1 = EBH_TestDataFactory.createUser('Business Admin');
    		businessAdm1.IsActive = true;
    		businessAdm1.Competency__c = 'Creative';
    		User businessAdm2 = EBH_TestDataFactory.createUser('Business Admin');
    		businessAdm2.IsActive = true;
    		businessAdm2.Competency__c = 'Targeting';
    		User businessAdm3 = EBH_TestDataFactory.createUser('Business Admin');
    		businessAdm3.IsActive = true;
    		businessAdm3.Competency__c = 'Journey';
    		User businessAdm4 = EBH_TestDataFactory.createUser('Business Admin');
    		businessAdm4.IsActive = true;
    		businessAdm4.Competency__c = 'Scripting';
    		insert new List<User>{businessAdm1,businessAdm2,businessAdm3,businessAdm4};
    		
    		Day__c d1 = new Day__c();
    		d1.User__c = businessAdm1.Id;
    		d1.Day__c = date.newInstance(2019,1,16);
    		d1.Available_capacity_of_your_work_time__c = 20;
    		d1.OwnerId = businessAdm.Id;
    		Day__c d2 = new Day__c();
    		d2.User__c = businessAdm2.Id;
    		d2.Day__c = date.newInstance(2019,1,16);
    		d2.Available_capacity_of_your_work_time__c = 20;
    		d2.OwnerId = businessAdm.Id;
    		Day__c d3 = new Day__c();
    		d3.User__c = businessAdm3.Id;
    		d3.Day__c = date.newInstance(2019,1,16);
    		d3.Available_capacity_of_your_work_time__c = 20;
    		d3.OwnerId = businessAdm.Id;
    		Day__c d4 = new Day__c();
    		d4.User__c = businessAdm4.Id;
    		d4.Day__c = date.newInstance(2019,1,16);
    		d4.Available_capacity_of_your_work_time__c = 20;
    		d4.OwnerId = businessAdm.Id;
    		insert new List<Day__c>{d1,d2,d3,d4};
    		
        	newSprint.From__c = date.newInstance(2019,1,14);
        	update newSprint;
        	
        	sprintUser = [select From__c, To__c, User__c,
        	Available_capacity_Copy__c,
        	Available_capacity_Creative__c,
        	Available_capacity_Targeting__c,
        	Available_capacity_Journey__c,
        	Available_capacity_Scripting__c from Sprint_Capacity_Users__c where User__c =: businessAdm.ID];
        	
        	System.assert(sprintUser.From__c == date.newInstance(2019,1,14));
        	System.assert(sprintUser.To__c == date.newInstance(2019,1,17));
        	System.debug('<<<<<sprintUser.Available_capacity_Copy__c='+sprintUser.Available_capacity_Copy__c);  
        	System.assert(sprintUser.Available_capacity_Copy__c == 0.8);
        	System.assert(sprintUser.Available_capacity_Creative__c == 1.6); 
        	System.assert(sprintUser.Available_capacity_Targeting__c == 1.6); 
        	System.assert(sprintUser.Available_capacity_Journey__c == 1.6); 
        	System.assert(sprintUser.Available_capacity_Scripting__c == 1.6); 
        	Test.stopTest();
    	}
    }
	*/
}