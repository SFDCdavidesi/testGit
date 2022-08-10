/*********************************************************************************************************************************
@ Class:          EBH_ProjectTriggerHandlerTest
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        Test class for Project Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 27.12.2019 / Sovantheany Dim / Created the test class.
*********************************************************************************************************************************/
@isTest
private class EBH_ProjectTriggerHandlerTest {
    static String ADMIN_PROFILE_ID = '00e6A000000HNzwQAG';
    private static RecordType recTypeSRMProj = ApexUtil.getRecordTypeByName('EBH_Project__c','Seller_Risk_Management');
    @TestSetup
    static void makeData(){
        EBH_TestDataFactory.setUpCustomSettings(); 
		ActiveValidationRules__c avr = new ActiveValidationRules__c();
		avr.All_Validation_Rules_Deactivated__c = false;
		insert avr;
        Lead oneL = new Lead();
		oneL.RecordTypeId = ApexUtil.getRecordTypeByName('Lead', 'EBH_eBayAUSMB').Id;
		oneL.EBH_eBayID__c = 'biggest_sellert_test';
		oneL.Site__c = 'AU';
		oneL.LeadSource = 'Self Gen';
		oneL.LeadSegment__c = 'SMB';
		oneL.OtherLeadSource__c = 'other leadsource tst';
		oneL.LastName = 'AMT Lead tst 01';
		oneL.Phone = '012 345 5678';
		oneL.Website = 'www.test.com.test';
		oneL.Email = 'test@tes.com.invalid';
		oneL.EBH_Vertical__c = 'Collectibles';
        oneL.VAT_Number__c = '12312312312312';
        oneL.Company = 'AMT Company';
        insert oneL;
    }
    static testMethod void testvalidatedAuSMBProject1() {
    	RecordType recTypeAuSMBLead = ApexUtil.getRecordTypeByName('Lead','EBH_eBayAUSMB');
    	Lead l = EBH_TestDataFactory.createLeads();
    	l.LeadSource = EBH_ConstantsUtility.LEAD_SOURCE_SELF_GEN;
    	l.RecordTypeId = recTypeAuSMBLead.Id;
    	l.isapproved__c = false;
    	l.Site__c = 'AU';
    	l.LeadSegment__c = 'SMB';
    	insert l;
    	List<Account> sellers =  EBH_TestDataFactory.createAccounts(1, 'EBH_Seller') ;
    	EBH_Project__c p1 = new EBH_Project__c(Lead__c = l.id,EBH_Seller__c=sellers[0].Id,ProjectName__c='Project 1',RecordTypeId=ApexUtil.getRecordTypeByName('EBH_Project__c','eBayAUSMB').Id);
        Test.startTest();
        try{
        insert p1;
        }catch(Exception e){
        	System.AssertEquals(e.getMessage().contains(System.label.eBayAuSBM_Err_2), true);
        }
        Test.stopTest();
        List<EBH_Project__c> projects = [select id from EBH_Project__c where id =: p1.Id];
        System.Assert(projects.isEmpty(),'No Project created because error : '+System.label.eBayAuSBM_Err_2);
    }
    static testMethod void testvalidatedAuSMBProject2() {
    	RecordType recTypeAuSMBLead = ApexUtil.getRecordTypeByName('Lead','EBH_eBayAUSMB');
    	List<Account> sellers =  EBH_TestDataFactory.createAccounts(1, 'EBH_Seller') ;
    	EBH_Project__c p2 = new EBH_Project__c(EBH_Seller__c=sellers[0].Id,ProjectName__c='Project 1',RecordTypeId=ApexUtil.getRecordTypeByName('EBH_Project__c','eBayAUSMB').Id);
        Test.startTest();
        try{
        insert p2;
        }catch(Exception e){
        	System.AssertEquals(e.getMessage().contains(System.label.eBayAuSBM_Err_1), true);
        }
        Test.stopTest();
        List<EBH_Project__c> projects = [select id from EBH_Project__c where id =: p2.Id];
        System.Assert(projects.isEmpty(),'No Project created because error : '+System.label.eBayAuSBM_Err_1);
    }
    static testMethod void testValidateManagedPaymentProj() {
        Lead oLead = [SELECT Site__c, Company FROM Lead WHERE LastName = 'AMT Lead tst 01'];
        RecordType recTypeManagedPayProj = ApexUtil.getRecordTypeByName('EBH_Project__c','ManagedPayment');
    	EBH_Project__c p1 = new EBH_Project__c(Lead__c=oLead.Id,ProjectName__c='Project 1',RecordTypeId=recTypeManagedPayProj.Id);
        insert p1;
         
        Test.startTest();
        Profile profileSTD = ApexUtil.getProfileByName('Standard User Profile');
        //User standardUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User Profile' AND IsActive = true LIMIT 1];
        User[] admins = [Select Id from User where ProfileId = :ADMIN_PROFILE_ID And IsActive = true limit 2];
        User standardUser =new User(
                Username='user3478test@test.com',
                LastName='user1test',
                Alias='SFDC2',
                CommunityNickname='ktang2test',
                TimeZoneSidKey='Atlantic/Cape_Verde',
                LocaleSidKey='en_GB',
                EmailEncodingKey='ISO-8859-1',
                ProfileId=profileSTD.id, 
                LanguageLocaleKey='de',
                Email='user1@test.com'
                //Sales_Team__c='AT'//,
                //UserRoleId=role1.id
        );  
        System.runAs(admins[0]){
            insert standardUser;
        }       
        

        try{
            System.runAs(standardUser){
                update p1;
            }
        }catch(Exception e){
        	system.debug(e);System.AssertEquals(e.getMessage().contains(Label.Validate_Managed_Payment), true);
        }
        
        p1 = [SELECT Name,EBH_Seller__r.EBH_RegistrationCountry__c,EBH_Seller__r.Name FROM EBH_Project__c WHERE Id =: p1.Id];
        // test for validationrule: Project Manage Payment Prepopulate Name
        String pName = String.isBlank(p1.EBH_Seller__r.EBH_RegistrationCountry__c) ? '' : ' ' + p1.EBH_Seller__r.EBH_RegistrationCountry__c;
        pName = String.isBlank(p1.EBH_Seller__r.Name) ? pName : pName + ' ' + p1.EBH_Seller__r.Name;
        System.AssertEquals(p1.Name, 'Payments' + pName);
        try{
            System.runAs(standardUser){
                update p1;
            }
        }catch(Exception e){
        	System.AssertEquals(e.getMessage().contains(Label.Validate_Managed_Payment), true);
        }
        //update should be ok after assign permission
        System.runAs(standardUser){
            String sWhere = ' WHERE PermissionSet.Name = \'Managed_Payment\'';
            PermissionSet ps = Database.query('SELECT Id, Name FROM PermissionSet WHERE Name = \'Managed_Payment\'');
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = standardUser.Id);
            insert psa;
            update p1;
        }
        try{
            System.runAs(standardUser){
                delete p1;
            }
        }catch(Exception e){
        	// System.AssertEquals(e.getMessage().contains(Label.Validate_Managed_Payment), true);
        }
        Test.stopTest();
    }

    /*****************************************************************************************************************************
    @ Method:   testValidateManagedPaymentProjWithInsertPermission
    @ Version:  1.0
    @ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
	@ Purpose: 	US-0007521 test class for trigger handler method EBH_ProjectTriggerHandler.validateManagedPaymentProj
    @------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      none
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 18.06.2020 / Sophal Noch / Created the  Method.
    *****************************************************************************************************************************/
    static testMethod void testValidateManagedPaymentProjWithInsertPermission() {
        Lead oLead = [SELECT Site__c, Company FROM Lead WHERE LastName = 'AMT Lead tst 01'];
        RecordType recTypeManagedPayProj = ApexUtil.getRecordTypeByName('EBH_Project__c','ManagedPayment');
    	EBH_Project__c p1 = new EBH_Project__c(Lead__c=oLead.Id,ProjectName__c='Project 1',RecordTypeId=recTypeManagedPayProj.Id);
        Test.startTest();
        Profile profileSTD = ApexUtil.getProfileByName('Standard User Profile');
        //User standardUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User Profile' AND IsActive = true LIMIT 1];
        User[] admins = [Select Id from User where ProfileId = :ADMIN_PROFILE_ID And IsActive = true limit 2];
        User standardUser =new User(
                Username='user3478test@test.com',
                LastName='user1test',
                Alias='SFDC2',
                CommunityNickname='ktang2test',
                TimeZoneSidKey='Atlantic/Cape_Verde',
                LocaleSidKey='en_GB',
                EmailEncodingKey='ISO-8859-1',
                ProfileId=profileSTD.id, 
                LanguageLocaleKey='de',
                Email='user1@test.com'
                //Sales_Team__c='AT'//,
                //UserRoleId=role1.id
        );  
        System.runAs(admins[0]){
            insert standardUser;
        }       

        try{
            System.runAs(standardUser){
                insert p1;
            }
        }catch(Exception e){
        	System.AssertEquals(e.getMessage().contains(Label.Validate_Managed_Payment), true);
        }
       
        insert p1;

        System.runAs(admins[0])
        {
            String sWhere = ' WHERE PermissionSet.Name = \'Managed_Payment\'';
            PermissionSet ps = Database.query('SELECT Id, Name FROM PermissionSet WHERE Name = \'Create_Managed_Payment\'');
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = standardUser.Id);
            insert psa;   
        }      
            
        BatchUploadManagedPayment.isBatchManagedPaymentUploading = true;

        System.runAs(standardUser){
            
            try{
                update p1;
            }catch(Exception e){system.debug('---193: '+e);}
            BatchUploadManagedPayment.isBatchManagedPaymentUploading = false;
            
            System.AssertNotEquals(null, p1.Id);
        }
        
        try{
            System.runAs(standardUser){
                delete p1;
            }
        }catch(Exception e){
        	// System.AssertEquals(e.getMessage().contains(Label.Validate_Managed_Payment), true);
        }
        Test.stopTest();
    }

    static testMethod void testValidateSRMProj() {
        List<Account> sellers =  EBH_TestDataFactory.createAccounts(1, 'EBH_Seller') ;
        Profile profileSTD = ApexUtil.getProfileByName('Standard User Profile');
        User admins = [Select Id from User where ProfileId = :ADMIN_PROFILE_ID And IsActive = true limit 1];
        User standardUser =new User(
                Username='user3478test@test.com',
                LastName='user1test',
                Alias='SFDC2',
                CommunityNickname='ktang2test',
                TimeZoneSidKey='Atlantic/Cape_Verde',
                LocaleSidKey='en_GB',
                EmailEncodingKey='ISO-8859-1',
                ProfileId=profileSTD.id, 
                LanguageLocaleKey='de',
                Email='user1@test.com'
        );  

        insert standardUser;

        EBH_Project__c proj1;
        System.runAs(admins){
            PermissionSet ps1 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Managed_Payment'];
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ps1.Id, AssigneeId = standardUser.Id);
            insert psa1; 
        }       
        
        System.runAs(standardUser){
            proj1 = new EBH_Project__c(EBH_Seller__c=sellers[0].Id,RecordTypeId=recTypeSRMProj.Id, EBH_Stage__c=EBH_ProjectTriggerHandler.PROJECT_STAGE_SUBMITTED);
            insert proj1;
        }
        Test.startTest();
            System.runAs(standardUser){
                try {
                    EBH_ProjectTriggerHandler.isHistoryCreate = false;
                    delete [SELECT Id FROM EBH_Project__c WHERE Id =: proj1.Id];
                    //System.assert(false, 'Expect: Without permission you can\'t delete this record');
                } catch (Exception ex) {
                    String errormsg = 'Expect: Error Message should be === '+ Label.PROJECT_SRM_ERROR_ON_DELETE +' , Actual: ' + ex.getMessage();
                    System.assert(ex.getMessage().contains(Label.PROJECT_SRM_ERROR_ON_DELETE), errormsg);
                }
            }

            System.runAs(admins)
            {
    
                PermissionSet ps2 = Database.query('SELECT Id, Name FROM PermissionSet WHERE Name = \'UK_Seller_Risk_Management_BU\'');
                PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = ps2.Id, AssigneeId = standardUser.Id);
                insert psa2;   
            }

            System.runAs(standardUser){
                try {
                    EBH_ProjectTriggerHandler.isHistoryCreate = false;
                    delete [SELECT Id FROM EBH_Project__c WHERE Id =: proj1.Id];
                } catch (Exception ex) {
                    System.assert(false, 'Expect: With permission you can delete this record');
                }
            }
                
        Test.stopTest();
    }
    
    /*****************************************************************************************************************************
    @ Method:   testvalidatedRequiredField
    @ Version:  1.0
    @ Author:   Sovantheany Dim (sovantheany.dim@gaea-sys.com)
	@ Purpose: 	US-0009942 - [UK Risk] Pending items- High Priority
    @------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      none
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.07.2021 / Sovantheany Dim / Created the  Method.
    *****************************************************************************************************************************/
    static testMethod void testvalidatedRequiredField() {
        Profile profileSTD = ApexUtil.getProfileByName('Standard User Profile');
        User standardUser =new User(
                Username='user1111test@test.com',
                LastName='user1test',
                Alias='SFDC2',
                CommunityNickname='ktang2test',
                TimeZoneSidKey='Atlantic/Cape_Verde',
                LocaleSidKey='en_GB',
                EmailEncodingKey='ISO-8859-1',
                ProfileId=profileSTD.id, 
                LanguageLocaleKey='de',
                Email='user1@test.com'
        );  
        User standardUser2 =new User(
                Username='user2222test@test.com',
                LastName='user2test',
                Alias='SFDC23',
                CommunityNickname='ktang2test34',
                TimeZoneSidKey='Atlantic/Cape_Verde',
                LocaleSidKey='en_GB',
                EmailEncodingKey='ISO-8859-1',
                ProfileId=profileSTD.id, 
                LanguageLocaleKey='de',
                Email='user2@test.com'
        );  
		insert new List<User>{standardUser,standardUser2};
        
        User admins = [Select Id from User where ProfileId = :ADMIN_PROFILE_ID And IsActive = true limit 1];
        System.runAs(admins)
        {
            
            PermissionSet ps2 = Database.query('SELECT Id, Name FROM PermissionSet WHERE Name = \'UK_Seller_Risk_Management_CUD_GCX\'');
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = ps2.Id, AssigneeId = standardUser.Id);
          
            PermissionSet psBU = Database.query('SELECT Id, Name FROM PermissionSet WHERE Name = \'UK_Seller_Risk_Management_BU\'');
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = psBU.Id, AssigneeId = standardUser2.Id);
            
            insert new List<PermissionSetAssignment>{psa2,psa3};      
        }
        EBH_Project__c proj1;
        Test.startTest();
        System.runAs(standardUser){
            List<Account> sellers =  EBH_TestDataFactory.createAccounts(1, 'EBH_Seller') ;
            proj1 = new EBH_Project__c(EBH_Seller__c=sellers[0].Id,RecordTypeId=recTypeSRMProj.Id, EBH_Stage__c=EBH_ProjectTriggerHandler.PROJECT_STAGE_SUBMITTED); 
            insert proj1;
        }
        System.runAs(standardUser){
            try {
                EBH_ProjectTriggerHandler.isHistoryCreate = false;
                proj1.EBH_Stage__c = EBH_ProjectTriggerHandler.PROJECT_STAGE_COMPLETED;
                proj1.Ticket_Status__c = 'Rejected';
                Proj1.Rejected_Reason__c = 'more information needed';
                update proj1;
            } catch (Exception ex) {
                System.assert(ex.getMessage().contains(Label.UKSRM_Required_Field_error));
            }

            proj1.Risk_tier_manual__c = 1;
            proj1.Registration_data__c = 'test';
            proj1.Seller_Account_Status__c = 'Open /Active';
            proj1.Open_Issues__c = 'test';
            proj1.Issue_97_flag__c = 'test';
            proj1.Verification_Status__c = 'Yes';
            proj1.Category_Risk__c = 'test';
            proj1.Listings__c = 1;
            proj1.Listings_t__c = 'test';
            proj1.Business_details__c = 'test';
            proj1.Merchant_Type__c = 'PLC: Public Limited Company';
            proj1.Time_in_Business_TIB__c = 'test';
            proj1.Internet_Search__c = 'test';
            proj1.Basic_KYB_for_Commercial_Entities__c = 'test';
            proj1.Credit_check_for_Commercial_Entities__c = 'test';
            update proj1;
        }

        System.runAs(standardUser2){
            try{
                proj1.EBH_Stage__c = 'Appeal';
                proj1.Reason_for_Appeal__c = 'test';
                update proj1;
                EBH_ProjectTriggerHandler.isHistoryCreate = false;
                proj1.Site__c = 'UK';
                update proj1;
            }catch (Exception ex) {
                //Insufficient Privileges to modify the record when stage is not Submitted
                System.assert(ex.getMessage().contains(Label.Validation_UKSRM_BU_Edit_Record_Error_msg));
            }
        }
        Test.stopTest();
    }
    
}