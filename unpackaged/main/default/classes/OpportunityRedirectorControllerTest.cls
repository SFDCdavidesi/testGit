/*********************************************************************************************************************************
@ Class:          OpportunityRedirectorControllerTest
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        US-0008557 - [NA] Opportunity Layout "Details" and "Related" sections
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 09.11.2020 / Sovantheany Dim / Created the class.
                  
*********************************************************************************************************************************/
@isTest
private class OpportunityRedirectorControllerTest {
    @testSetup
    static void setup(){
        EBH_TestDataFactory.setUpCustomSettings();
        
    }
    @isTest
    static void validatedOpportunityTest(){
        setup();
        Test.startTest();
        Map<String, Object> mapResult = OpportunityRedirectorController.validatedOpportunity();
        Test.stopTest();
        System.assert(mapResult.get('isSuccess') == true);
    }
    @isTest
    static void validatedOpportunityWithNATest(){
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'NA Standard User Base' Limit 1];  
        User objUser = new User(Alias = 'test1', 
                                Email = 'test.test@test.com', 
                                EmailEncodingKey = 'UTF-8', 
                                LastName = 'test',
                                LocaleSidKey = 'en_US', 
                                LanguageLocaleKey='en_US', 
                                ProfileId = objProfile.Id, 
                                TimeZoneSidKey = 'Europe/London', 
                                UserName = 'test@hive.project.com.invalide');
       System.runAs(objUser) {
        Test.startTest();
        Map<String, Object> mapResult = OpportunityRedirectorController.validatedOpportunity();
        Test.stopTest();
        System.assert(mapResult.get('isSuccess') == false,'Fail Because NA User without permission set');
       }     
                                               
    }
    @isTest
    static void validateCloneQuoteButtonTest(){

        Test.startTest();
            Map<String, Object> mapResult = OpportunityRedirectorController.validateCloneQuoteButton();
        Test.stopTest();
        
        System.assert(mapResult.get('isSuccess') == true,'The result should return isSuccess = true.');
    }
}