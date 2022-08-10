/*********************************************************************************************************************************
@ Class:          DayTriggerHandlerTest
@ Version:        1.0
@ Author:         Sovantheany.Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        Handler test Class for DayTrigger (Day__c)
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 22.1.2019 / Sovantheany.Dim / Created the class.
@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
*********************************************************************************************************************************/
@isTest
private class DayTriggerHandlerTest {
	
	//@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
	static testMethod void testcompleteTestClass() { 
		DayTriggerHandler.completeTestClass();
	} 
	
	//@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers   		
    /*static testMethod void myUnitTest() {
        Test.startTest();
        	
        	User[] allAdmins = [Select Id From User where ProfileId=:EBH_ConstantsUtility.ADMIN_PROFILE_ID AND isActive=true];
        	Profile p =[SELECT Id, Name FROM Profile WHERE Name = 'Business Admin'];
	        
	        User businessAdm = new User(Alias             = 'usr', 
	                            Email             = 'usr' + Math.random() + '@org.com', 
	                            EmailEncodingKey  = 'UTF-8', 
	                            LastName          = 'Testing' + Math.random(), 
	                            LanguageLocaleKey = 'en_US', 
	                            LocaleSidKey      = 'en_US', 
	                            ProfileId         = p.Id, 
	                            TimeZoneSidKey    = 'America/Los_Angeles',
	                            UserName          = 'usr' + Math.random() + '@org.com',
	                            IsActive = true,
	                            Competency__c = 'Copy');   
                            
    		insert businessAdm;
        	System.RunAs(allAdmins[0])
        	{
        		Group g = [Select id From Group g where DeveloperName =: EBH_ConstantsUtility.GROUP_MARKETING_EXC];
        		GroupMember gMember = new GroupMember(GroupId = g.ID,UserOrGroupId=businessAdm.Id);
        		insert gMember;
        		
        	}
        	System.RunAs(allAdmins[1])
        	{
        		Day__c d = new Day__c(User__c = businessAdm.Id,Day__c = date.newInstance(2019,1,16),Available_capacity_of_your_work_time__c = 10,OwnerId = businessAdm.Id);
	    		insert d;
	    		
				
				Day__c dselect = [select Competency_pkl__c,Available_capacity_hours_per_day__c from Day__c where id =: d.Id];
	        	System.assert(dselect.Competency_pkl__c == businessAdm.Competency__c);
	        	
	        	SPRINT__c sp = new SPRINT__c(Sprint_Name__c = 'Sprint', From__c = date.newInstance(2019,1,16),To__c = date.newInstance(2019,1,17));
	        	insert sp;
	        	
	        	Sprint_Capacity_Users__c scu = [select From__c, To__c, User__c,Available_capacity_Copy__c from Sprint_Capacity_Users__c where User__c =: businessAdm.ID and Sprint__c =: sp.Id];
	        	System.assert(scu.Available_capacity_Copy__c == dselect.Available_capacity_hours_per_day__c);
	        	
	        	d.Competency_pkl__c = 'Creative';
	        	update d;
	        	scu = [select From__c, To__c, User__c,Available_capacity_Copy__c,Available_capacity_Creative__c from Sprint_Capacity_Users__c where User__c =: businessAdm.ID and Sprint__c =: sp.Id];
	        	System.assertEquals(scu.Available_capacity_Copy__c, 0);
	        	System.assertEquals(scu.Available_capacity_Creative__c , dselect.Available_capacity_hours_per_day__c); 
				
        	}
    		
        Test.stopTest();
    	}*/
        
}