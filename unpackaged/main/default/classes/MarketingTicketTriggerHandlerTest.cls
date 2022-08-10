/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
//@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
@isTest
private class MarketingTicketTriggerHandlerTest {

	//@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
	static testMethod void testcompleteTestClass() { 
		MarketingTicketTriggerHandler.completeTestClass();
	} 

	// @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
	/* static testMethod void testSubtractDays() {
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
    		//Select s.To__c, s.Sprint_Name__c, s.From__c, s.Estimated_Effort_Targeting__c, s.Estimated_Effort_Scripting__c, s.Estimated_Effort_Journey__c, s.Estimated_Effort_Creative__c, s.Estimated_Effort_Copy__c From SPRINT__c s
	    	SPRINT__c sp1 = new SPRINT__c();
	    	sp1.Sprint_Name__c = 'Sprint1';
	    	sp1.From__c = date.newinstance(2019, 1, 14);
	    	sp1.To__c = date.newinstance(2019, 1, 15);
	    	
	    	SPRINT__c sp2 = new SPRINT__c();
	    	sp2.Sprint_Name__c = 'Sprint2';
	    	sp2.From__c = date.newinstance(2019, 1, 14);
	    	sp2.To__c = date.newinstance(2019, 1, 15);
	    	List<SPRINT__c> lstSp = new List<SPRINT__c>{sp1,sp2};
	    	insert lstSp;
	    	
	    	RecordType rCopyCreative = EBH_TestDataFactory.getRecordTypeByName('Marketing_Ticket__c','Copy_Creative');
	    	List<Campaign> campaigns = EBH_TestDataFactory.createCampaigns(1, 'Request', 'UK', 'EBH_CampaignRequest'); 
	    	Marketing_Ticket__c mtA1 = new Marketing_Ticket__c(RecordTypeId=rCopyCreative.Id,Campaign__c=campaigns[0].Id,Sprint_Name__c = sp1.ID,Competency_s__c='Copy',Estimated_Effort__c=10,Specialist__c=businessAdm.Id);
			Marketing_Ticket__c mtA2 = new Marketing_Ticket__c(RecordTypeId=rCopyCreative.Id,Campaign__c=campaigns[0].Id,Sprint_Name__c = sp1.ID,Competency_s__c='Creative',Estimated_Effort__c=10,Specialist__c=businessAdm.Id); 
			List<Marketing_Ticket__c> listTicktes = new List<Marketing_Ticket__c>{mtA1,mtA2};
			insert listTicktes;
	    	
			
    	}
		Test.startTest();
		Integer substractDay = 7;
		Date StartDate = Date.newInstance(2022, 04, 8);
		MarketingTicketTriggerHandler.subtractDays(StartDate,substractDay);
		Test.stopTest();
	}   
	*/

	// @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
	/*
    static testMethod void testSetCounterandDueDate() {
        
        RecordType rCopyCreative = EBH_TestDataFactory.getRecordTypeByName('Marketing_Ticket__c','Copy_Creative');
        RecordType rTargeting = EBH_TestDataFactory.getRecordTypeByName('Marketing_Ticket__c','Targeting');
        RecordType rJourney = EBH_TestDataFactory.getRecordTypeByName('Marketing_Ticket__c','Journey');
		List<Campaign> campaigns = EBH_TestDataFactory.createCampaigns(2, 'Request', 'UK', 'EBH_CampaignRequest');   
		
		Marketing_Ticket__c mtA1 = new Marketing_Ticket__c(RecordTypeId=rCopyCreative.Id,Campaign__c=campaigns[0].Id);
		Marketing_Ticket__c mtA2 = new Marketing_Ticket__c(RecordTypeId=rCopyCreative.Id,Campaign__c=campaigns[0].Id);
		Marketing_Ticket__c mtB1 = new Marketing_Ticket__c(RecordTypeId=rTargeting.Id,Campaign__c=campaigns[1].Id);
		Marketing_Ticket__c mtB2 = new Marketing_Ticket__c(RecordTypeId=rTargeting.Id,Campaign__c=campaigns[1].Id);
		Marketing_Ticket__c mtB3 = new Marketing_Ticket__c(RecordTypeId=rJourney.Id,Campaign__c=campaigns[1].Id);
		List<Marketing_Ticket__c> listTicktes = new List<Marketing_Ticket__c>{mtA1,mtA2,mtB1,mtB2,mtB3};
		
		Test.startTest();
		for(Campaign cam : campaigns){
			cam.StartDate = date.newInstance(2018,12,16);
		}
		update campaigns;
		
		insert listTicktes;
		
		Map<Id,Marketing_Ticket__c> mapResult = new Map<Id,Marketing_Ticket__c>([Select Id,Name,Count__c,Due_Date__c From Marketing_Ticket__c Where Id IN:listTicktes]);
		
		System.assertEquals(1,mapResult.get(mtA1.Id).Count__c,'counter as 1');
		System.assertEquals(2,mapResult.get(mtA2.Id).Count__c,'counter as 2');
		System.assertEquals(1,mapResult.get(mtB1.Id).Count__c,'counter as 1');
		System.assertEquals(2,mapResult.get(mtB2.Id).Count__c,'counter as 2');
		
		//System.assertEquals(date.newInstance(2018,12,12),mapResult.get(mtA1.Id).Due_Date__c,'Due date = campaign start date - 2 Working Day');
		//System.assertEquals(date.newInstance(2018,12,12),mapResult.get(mtA2.Id).Due_Date__c,'Due date = campaign start date - 2 Working Day');
		//System.assertEquals(date.newInstance(2018,12,11),mapResult.get(mtB1.Id).Due_Date__c,'Due date = campaign start date - 3 Working Day');
		//System.assertEquals(date.newInstance(2018,12,11),mapResult.get(mtB2.Id).Due_Date__c,'Due date = campaign start date - 3 Working Day');
		//System.assertEquals(date.newInstance(2018,12,13),mapResult.get(mtB3.Id).Due_Date__c,'Due date = campaign start date - 1 Working Day');
		
		Marketing_Ticket__c mtA3 = new Marketing_Ticket__c(RecordTypeId=rCopyCreative.Id,Campaign__c=campaigns[0].Id);
		Marketing_Ticket__c mtA4 = new Marketing_Ticket__c(RecordTypeId=rCopyCreative.Id,Campaign__c=campaigns[0].Id);
		listTicktes = new List<Marketing_Ticket__c>{mtA3,mtA4};
		
		insert listTicktes;
		
		mapResult = new Map<Id,Marketing_Ticket__c>([Select Id,Name,Count__c From Marketing_Ticket__c Where Id IN:listTicktes]);
		
		System.assertEquals(3,mapResult.get(mtA3.Id).Count__c,'counter as 3');
		System.assertEquals(4,mapResult.get(mtA4.Id).Count__c,'counter as 4');
		
		
		Test.stopTest();
        
    }
	*/
	
	// @ Change history: 04.07.2022 /Chetra Sarlom/ destructive US-0007031 - Deactivate triggers
	/* 
	static testMethod void testsumEstimatedEffortOnSprintAndSprintCapacityUser() {
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
    		//Select s.To__c, s.Sprint_Name__c, s.From__c, s.Estimated_Effort_Targeting__c, s.Estimated_Effort_Scripting__c, s.Estimated_Effort_Journey__c, s.Estimated_Effort_Creative__c, s.Estimated_Effort_Copy__c From SPRINT__c s
	    	SPRINT__c sp1 = new SPRINT__c();
	    	sp1.Sprint_Name__c = 'Sprint1';
	    	sp1.From__c = date.newinstance(2019, 1, 14);
	    	sp1.To__c = date.newinstance(2019, 1, 15);
	    	
	    	SPRINT__c sp2 = new SPRINT__c();
	    	sp2.Sprint_Name__c = 'Sprint2';
	    	sp2.From__c = date.newinstance(2019, 1, 14);
	    	sp2.To__c = date.newinstance(2019, 1, 15);
	    	List<SPRINT__c> lstSp = new List<SPRINT__c>{sp1,sp2};
	    	insert lstSp;
	    	
	    	RecordType rCopyCreative = EBH_TestDataFactory.getRecordTypeByName('Marketing_Ticket__c','Copy_Creative');
	    	List<Campaign> campaigns = EBH_TestDataFactory.createCampaigns(1, 'Request', 'UK', 'EBH_CampaignRequest'); 
	    	Marketing_Ticket__c mtA1 = new Marketing_Ticket__c(RecordTypeId=rCopyCreative.Id,Campaign__c=campaigns[0].Id,Sprint_Name__c = sp1.ID,Competency_s__c='Copy',Estimated_Effort__c=10,Specialist__c=businessAdm.Id);
			Marketing_Ticket__c mtA2 = new Marketing_Ticket__c(RecordTypeId=rCopyCreative.Id,Campaign__c=campaigns[0].Id,Sprint_Name__c = sp1.ID,Competency_s__c='Creative',Estimated_Effort__c=10,Specialist__c=businessAdm.Id); 
			List<Marketing_Ticket__c> listTicktes = new List<Marketing_Ticket__c>{mtA1,mtA2};
			insert listTicktes;
	    	
			SPRINT__c spSel1 = [select id, Estimated_Effort_Copy__c, Estimated_Effort_Creative__c, Estimated_Effort_Targeting__c, Estimated_Effort_Journey__c, Estimated_Effort_Scripting__c from SPRINT__c where id =: sp1.ID];
	    	System.assert(spSel1.Estimated_Effort_Copy__c == 10);
	    	System.assert(spSel1.Estimated_Effort_Creative__c == 10);
	    	
	    	for(Sprint_Capacity_Users__c scu : [select Estimated_Effort_Copy__c, Estimated_Effort_Creative__c from Sprint_Capacity_Users__c where Sprint__c =: sp1.ID and User__c =: businessAdm.Id]){
	    		System.debug('<<<scu.Estimated_Effort_Copy__c='+scu.Estimated_Effort_Copy__c);
	    		System.debug('<<<Estimated_Effort_Creative__c='+scu.Estimated_Effort_Copy__c);
	    		System.assert(scu.Estimated_Effort_Copy__c == 10);
	    		System.assert(scu.Estimated_Effort_Creative__c == 10);
	    	}
	    	
	    	mtA2.Sprint_Name__c = sp2.ID;
	    	mtA2.Competency_s__c = 'Copy';
	    	update mtA2;
	    	for(SPRINT__c spSel2 : [select id, Estimated_Effort_Copy__c, Estimated_Effort_Creative__c, Estimated_Effort_Targeting__c, Estimated_Effort_Journey__c, Estimated_Effort_Scripting__c from SPRINT__c where id IN: lstSp ]){
				System.assert(spSel2.Estimated_Effort_Copy__c == 10);
	    	}
	    	
	    	for(Sprint_Capacity_Users__c scu : [select Estimated_Effort_Copy__c, Estimated_Effort_Creative__c from Sprint_Capacity_Users__c where Sprint__c IN: lstSp and User__c =: businessAdm.Id]){
	    		System.assert(scu.Estimated_Effort_Copy__c == 10);
	    	}
	    	
	    	delete listTicktes;
	    	
	    	for(SPRINT__c spSel3 : [select id, Estimated_Effort_Copy__c, Estimated_Effort_Creative__c, Estimated_Effort_Targeting__c, Estimated_Effort_Journey__c, Estimated_Effort_Scripting__c from SPRINT__c where id IN: lstSp]){
				System.assert(spSel3.Estimated_Effort_Copy__c == 0);
	    	}
	    	
	    	for(Sprint_Capacity_Users__c scu : [select Estimated_Effort_Copy__c, Estimated_Effort_Creative__c from Sprint_Capacity_Users__c where Sprint__c IN: lstSp and User__c =: businessAdm.Id]){
	    		System.assert(scu.Estimated_Effort_Copy__c == 0);
	    	} 
    	}
    	Test.stopTest();
    	
    }
	*/
}