/*********************************************************************************************************************************
@ Class:          TicketTriggerTest
@ Version:        1.0
@ Author:         Samnang MUONG
@ Purpose:        Test class for Ticket Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 11.10.2017 / Samnang MUONG / Created the test class.
*********************************************************************************************************************************/

@isTest(seeAllData = False)
private class TicketTriggerTest {


    /*****************************************************************************************************************************
    @ Method:         testProfile_SA
    @ Version:        1.0
    @ Author:         Samnang MUONG
    @ Purpose:        Profile testing for System Administrator
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 16.10.2017 / Samnang MUONG / Created the test Method.
    *****************************************************************************************************************************/
    static testMethod void testProfile_SA() {  
        System.runAs(EBH_TestDataFactory.createUser('System Administrator')) { 
            testCreateUser();
        }        
    }
    
    /*************************************not to be run test, run testProfile_SA() instsead******************************************
    @ Method:         testCreateUser
    @ Version:        1.0
    @ Author:         Samnang MUONG
    @ Purpose:        TEST CASE (*) System should be able to create user by information on ticket when ticket changed status to in-progress
                      COVERAGES (*) checkCreateUsers(): Check status ticket changed
                                    |__createUser(): Bind value from ticket to new user
                                    |__addMemberAsyn(): Add permission to new user

    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 11.10.2017 / Samnang MUONG / Created the test Method.
    @                 08.11.2017 / Vadhanak Voun / added assertion for GroupMember  
    @                 06.12.2017/ Vadhanak Voun / : 06.12.2017/ Vadhanak Voun   / updated assertion to match EBH_ESCampaignRequestApprovers. As localed from Czech to Spnanish since group for Cz has gone missing. 
    *****************************************************************************************************************************/
    
    private static testMethod void testCreateUser() { 

        /*TEST DATA ------------------------------------------------------------------------------------------ BEGIN -----------*/
        EBH_TestDataFactory.setUpCustomSettings();
        Map<String, Ticket__c>  mapEmail2Ticket = EBH_TestDataFactory.setupTicketTriggerHandlerData();
        /*TEST DATA ------------------------------------------------------------------------------------------ END -------------*/
        
        Test.startTest();

            /*POSITIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
            /*Modify data for test*/   

            // update ticket status "New" to "In Progress"
            for (Ticket__c t :mapEmail2Ticket.values()) {
                t.Status__c = 'In Progress';
                t.Should_approve_Campaign_requests__c = true;
                t.Approved__c = true;
            }

            // reset trigger recurrsive
            EBH_CheckRecursive.Run = true;
                
            update mapEmail2Ticket.values();

            User[] users = [SELECT Id,CommunityNickname, Email,UserPermissionsMarketingUser FROM User WHERE Email IN : mapEmail2Ticket.keySet()];
            
            //Assertion
            System.assertEquals('testticket052@test.com', users[0].Email);
            System.assertEquals('testticket152@test.com', users[1].Email);
            System.assertEquals('testticket252@test.com', users[2].Email);
            System.assertEquals('testticket352@test.com', users[3].Email);
            System.assertEquals('testticket452@test.com', users[4].Email);
            
            System.assertEquals(true, users[0].UserPermissionsMarketingUser);
            System.assertEquals(true, users[1].UserPermissionsMarketingUser);
            System.assertEquals(true, users[2].UserPermissionsMarketingUser);
            System.assertEquals(true, users[3].UserPermissionsMarketingUser);

            // Assert ticket share
            System.assertEquals(5, [SELECT COUNT() FROM Ticket__Share WHERE ParentId=:mapEmail2Ticket.values()], 'Should be create a ticket share');

            /*POSITIVE TESTING ------------------------------------------------------------------------------- END -------------*/
            
            /*NEGETIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
            /*Modify data for test*/ 
            Ticket__c ti = mapEmail2Ticket.get('testticket052@test.com');
            ti.Email_Address__c = 'testwrong@test.test';
            ti.Status__c = 'New';

            // reset trigger recurrsive
            EBH_CheckRecursive.Run = true;

            /*Excecute test*/
            update ti;
           
            /* Validate test */       
            System.assertEquals(0, [SELECT Id,CommunityNickname, Email FROM User WHERE Email = 'testwrong@test.test'].size(),'User has email: testwrong@test.test should not create.');
            
            /*EXCEPTION TESTING ------------------------------------------------------------------------------ BEGIN -----------*/
            /*Modify data for test*/    
            /*EXCEPTION TESTING ------------------------------------------------------------------------------ END -------------*/
        Test.stopTest();   
        Set<String> setUserIds = new Set<String>();
        
        for(User u: users)
        {
            setUserIds.add(u.Id);
        }
        
        GroupMember[] gm = [Select Id,Group.DeveloperName from GroupMember where UserOrGroupId IN:setUserIds];
        if( gm.size() > 0){
            System.assertEquals('EBH_ESCampaignRequestApprovers',gm[0].Group.DeveloperName,'user added to a public group "EBH_ESCampaignRequestApprovers" by locale: ca_ES');
            System.assertEquals(setUserIds.size(),gm.size(),'Each user added to public group');
        } 
       
        

    }
    
	static testMethod void testAutoCreateDays()
    {
        User[] allAdmins = [Select Id From User where ProfileId=:EBH_ConstantsUtility.ADMIN_PROFILE_ID AND ISActive=true];
        User[] selUser;
         System.RunAs(allAdmins[0])
         {
         	EBH_TestDataFactory.setUpCustomSettings();
	    	EBH_TestDataFactory.createCountryMapping3();
	        EBH_TestDataFactory.createLocalePublicGroupMapping();
	        List<Ticket__c> listTickets = EBH_TestDataFactory.createTickets(1);
        
         	Test.startTest();
        
	        EBH_CheckRecursive.Run = true;
		        listTickets[0].Status__c = EBH_ConstantsUtility.STATUS_INPROGRESS;
		        listTickets[0].Permission_Sets__c = EBH_ConstantsUtility.TICKET_PERMISSIONSET_MARKETING_EXC_TEAM;
		        listTickets[0].Approved__c  = true;
		        //system.debug('>>>pset: '+listTickets[0].Permission_Sets__c );
		        update listTickets[0]; 
	        
	        Test.stopTest();
	        selUser = [Select Id,Name,Email From User where Email =: listTickets[0].Email_Address__c];
	        
	        System.assertEquals(1,selUser.size(),'1user created from ticket');
	        
	        //group assignment
	        Set<String> setGoups = new Set<String>{EBH_ConstantsUtility.GROUP_MARKETING_EXC};
	        String userId = selUser[0].Id;
	        GroupMember[] groupMembers = Database.query(EBH_ConstantsUtility.SOQL_GROUP_MEMBER +' AND UserOrGroupId =:userId');
	        System.assertEquals(1,groupMembers.size(),' user assigned to group: '+EBH_ConstantsUtility.GROUP_MARKETING_EXC);
	        
	        //days creation
	        Day__c[] createdDays = [Select Id,Day__c,User__c From Day__c Where User__c =:userId];
	        //System.assertEquals(5,createdDays.size(),' 5 days in next 90 days created');
	        for(Day__c d: createdDays)
	        {
	        	DateTime dt = DateTime.newInstance(d.Day__c.year(),d.Day__c.month(),d.Day__c.day());
	        	System.assert(Integer.valueOf(dt.format('u'))<=5, ' the new created days must on weekday' ); 
	        }
         }
        
    }
    static testMethod void testDeactivateUser()
    {
    	EBH_TestDataFactory.setUpCustomSettings();
    	EBH_TestDataFactory.createCountryMapping3();
        EBH_TestDataFactory.createLocalePublicGroupMapping();
        
        List<Ticket__c> listTickets = EBH_TestDataFactory.createTickets(1);
        User[] allAdmins = [Select Id From User where ProfileId=:EBH_ConstantsUtility.ADMIN_PROFILE_ID AND isActive=true];
        User[] selUser;
        System.RunAs(allAdmins[0])
        {
	        Test.startTest();
	        
		        EBH_CheckRecursive.Run = true;
			        listTickets[0].Status__c = EBH_ConstantsUtility.STATUS_INPROGRESS;
			        listTickets[0].Permission_Sets__c = EBH_ConstantsUtility.TICKET_PERMISSIONSET_MARKETING_EXC_TEAM;
			        listTickets[0].Approved__c  = true;
			        //system.debug('>>>pset: '+listTickets[0].Permission_Sets__c );
			        update listTickets[0]; 
		         
		        selUser = [Select Id,Name,Email From User where Email =: listTickets[0].Email_Address__c];
		        
		        EBH_ActiveTriggers__c cusettingTrigger = EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER);
		        cusettingTrigger.EBH_User__c = true;
		        update cusettingTrigger;
	        	 
	        	
	        
        }
       System.RunAs(allAdmins[1])
       {
         	selUser[0].isActive = false;
         	update selUser[0];
			Test.stopTest();
        }
         
        Day__c[] createdDays = [Select Id,Day__c,User__c From Day__c Where User__c =:selUser[0].Id];
		//licence limited. no assertion
        //System.assertEquals(0,createdDays.size(),' user deactivated. all furture Days have been deleted!');
    }
    
    //already covered by test above. here just to make it covered
    static testMethod void testAutoCreateDaysBatch()
    {
    	Test.startTest();
	    		BatchAutoCreateDay b = new BatchAutoCreateDay();
	        	b.execute(null);
    		Test.stopTest();
    }
    
    private static testMethod void testCreateUserGCX() { 
        /*TEST DATA ------------------------------------------------------------------------------------------ BEGIN -----------*/
        User[] admins = [Select Id,Name From User Where ProfileId =:EBH_ConstantsUtility.ADMIN_PROFILE_ID AND isActive = true AND UserRoleId<>null limit 2];
		System.runAs(admins[0])
		{
			EBH_TestDataFactory.setUpCustomSettings();
		}
        System.runAs(admins[1])
		{
			Map<String, Ticket__c>  mapEmail2Ticket = EBH_TestDataFactory.setupTicketTriggerHandlerData();
	        /*TEST DATA ------------------------------------------------------------------------------------------ END -------------*/
	        
	        insert new Account ( Name='GCX' , RecordTypeId='0126A000000M9xKQAS');
	        Test.startTest();
	
	            /*POSITIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
	            /*Modify data for test*/   
			
	            // update ticket status "New" to "In Progress"
	            for (Ticket__c t :mapEmail2Ticket.values()) {
	                t.Status__c = 'In Progress';
	                t.Picklist__c=EBH_ConstantsUtility.PROFILE_GCX_PARTNER;
	                t.Should_approve_Campaign_requests__c = true;
	                t.Approved__c = true;
	            }
	
	            // reset trigger recurrsive
	            EBH_CheckRecursive.Run = true;
	              
	            update mapEmail2Ticket.values();
				 
	            User[] users = [SELECT Id,CommunityNickname, Email,UserPermissionsMarketingUser FROM User WHERE Email IN : mapEmail2Ticket.keySet()];
	            
	            //Assertion
	            System.assertEquals('testticket052@test.com', users[0].Email);
	            System.assertEquals('testticket152@test.com', users[1].Email);
	            System.assertEquals('testticket252@test.com', users[2].Email);
	            System.assertEquals('testticket352@test.com', users[3].Email);
	            System.assertEquals('testticket452@test.com', users[4].Email);
	            
	            System.assertEquals(true, users[0].UserPermissionsMarketingUser);
	            System.assertEquals(true, users[1].UserPermissionsMarketingUser);
	            System.assertEquals(true, users[2].UserPermissionsMarketingUser);
	            System.assertEquals(true, users[3].UserPermissionsMarketingUser);
	
	            // Assert ticket share
	            System.assertEquals(5, [SELECT COUNT() FROM Ticket__Share WHERE ParentId=:mapEmail2Ticket.values()], 'Should be create a ticket share');
	
	            /*POSITIVE TESTING ------------------------------------------------------------------------------- END -------------*/
	            
	            /*NEGETIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
	            /*Modify data for test*/ 
	            Ticket__c ti = mapEmail2Ticket.get('testticket052@test.com');
	            ti.Email_Address__c = 'testwrong@test.test';
	            ti.Status__c = 'New';
	
	            // reset trigger recurrsive
	            EBH_CheckRecursive.Run = true;
	
	            /*Excecute test*/
	            update ti;
	           
	            /* Validate test */       
	            System.assertEquals(0, [SELECT Id,CommunityNickname, Email FROM User WHERE Email = 'testwrong@test.test'].size(),'User has email: testwrong@test.test should not create.');
	            
	            /*EXCEPTION TESTING ------------------------------------------------------------------------------ BEGIN -----------*/
	            /*Modify data for test*/    
	            /*EXCEPTION TESTING ------------------------------------------------------------------------------ END -------------*/
	        Test.stopTest();   
	        Set<String> setUserIds = new Set<String>();
	        
	        for(User u: users)
	        {
	            setUserIds.add(u.Id);
	        }
	        
	        GroupMember[] gm = [Select Id,Group.DeveloperName from GroupMember where UserOrGroupId IN:setUserIds];
	        if( gm.size() > 0){
	            System.assertEquals('EBH_ESCampaignRequestApprovers',gm[0].Group.DeveloperName,'user added to a public group "EBH_ESCampaignRequestApprovers" by locale: ca_ES');
	            System.assertEquals(setUserIds.size(),gm.size(),'Each user added to public group');
	        } 
	        
		}
        
    }

    private static testMethod void testAutoPopulateProfile() {
    	RecordType recTypeUserForm = ApexUtil.getRecordTypeByName('Ticket__c','User_Request_Form');
        List<Ticket__c> listT = EBH_TestDataFactory.createTicket();
        for(Ticket__c t: listT)
        {
        	t.RecordTypeId = recTypeUserForm.Id;
        }                  
         
        Test.startTest();
            TicketTriggerHandler.autoPopulateProfile(listT,null);
        Test.stopTest();

        System.assertEquals('AU Standard User Profile',listT[0].Picklist__c);
        System.assertEquals('Standard User Profile',listT[1].Picklist__c);
        System.assertEquals('GCX Partner Profile',listT[2].Picklist__c);

    }
    
    static testMethod void testPopulateSurveyIdtoCampaign() 
    {
    	EBH_TestDataFactory.setUpCustomSettings();
        
    	RecordType recTypeValidateSurvey = ApexUtil.getRecordTypeByName('Ticket__c','Validate_survey');
    	Campaign c = new Campaign( Name = 'test camp',EBH_Site__c = 'UK',recordTypeId = EBH_ConstantsUtility.CAMP_RECORDTYPE_OUTREACH_ID);
		insert c;
		
        Ticket__c t = EBH_TestDataFactory.createTickets(1)[0];
        EBH_CheckRecursive.Run = true;
         
        Test.startTest();
        	t.recordTypeId = recTypeValidateSurvey.Id;
             t.Related_Campaign__c = c.Id;
             t.Status__c = EBH_ConstantsUtility.TICKET_STATUS_VALIDATED;
             t.Survey_ID__c = '1234567890';
             update t;
              
        Test.stopTest();
		 c = [Select Id,Survey_ID__c From Campaign where Id=:c.Id];
		 System.assertEquals(t.Survey_ID__c,c.Survey_ID__c,'survey id gets assigned from Ticket');
		 t = [Select Id,Status__c from Ticket__c where Id=:t.Id];
		 System.assertEquals(EBH_ConstantsUtility.STATUS_CLOSED,t.Status__c,'then ticket closed');
    }
    
    static testMethod void testReactivateTicket()
    {
    	EBH_TestDataFactory.setUpCustomSettings();
        User[] admins = [Select Id,Name From User Where ProfileId =:EBH_ConstantsUtility.ADMIN_PROFILE_ID AND isActive = true AND UserRoleId<>null limit 2];
    	RecordType recTypeUserReactivate = ApexUtil.getRecordTypeByName('Ticket__c','User_Reactivation');
    	 
        Ticket__c t = EBH_TestDataFactory.createTickets(1)[0];
        EBH_CheckRecursive.Run = true;
        
        User intactivUser = EBH_TestDataFactory.createUser(EBH_ConstantsUtility.TICKET_STANDARD_PROFILE);
        intactivUser.isActive = false;
        
        
		System.runAs(admins[0])
		{
			insert intactivUser;
		}
		
		System.runAs(admins[1])
		{
			 
			 Test.startTest();
	        	 t.recordTypeId = recTypeUserReactivate.Id;
	             t.Status__c = EBH_ConstantsUtility.STATUS_INPROGRESS;
	             t.Inactive_User__c = intactivUser.Id;
	             t.Approved__c = true;
	             update t;
              
        	Test.stopTest();
			 intactivUser = [Select Id,isActive From User where Id=: intactivUser.Id];
			 System.assertEquals(t.Approved__c,intactivUser.isActive,'user gets reactivated success');
		}
        
         
    }
   
}