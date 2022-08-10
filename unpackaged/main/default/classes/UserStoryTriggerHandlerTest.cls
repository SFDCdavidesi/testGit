@isTest
private class UserStoryTriggerHandlerTest {

    @testSetup static void setup(){
        copado__User_Story__c story = new copado__User_Story__c();
        story.copado__User_Story_Title__c ='Test';
        story.PO_Reviewed__c=true;
        insert story;
        
    }
    @isTest static void updateDealCommentTest(){
        copado__User_Story__c cs = [select id,copado__status__c,po_reviewed__c from copado__user_story__c limit 1];
        copado__User_Story__c csClone=cs.clone();
        
        
        Test.startTest();
        upsert csClone;
        
        csClone=[select id,copado__status__c,po_reviewed__c from copado__user_story__c where id=:csClone.id];
     //   System.assert(csClone.PO_Reviewed__c=false,'Wrong value for PO Reviewed');
        Test.stopTest();
    }
    
    /***************************************START TEST METHOD FOR PROCESS BUILDER***************************************************/
    
    /**PROCESS BUILDER NAME: Process Builder for User Story Created or Edited
       Loumang: 12-02-2021 
	*/
    @isTest
    public static void test_Process_updateFeatureRequestStatusComingSoon() {
        Map<String,Object> mapData = generateData();
        Hive_Project__c hp = (Hive_Project__c)mapData.get('hp1');
        Requirement_Request__c fr = (Requirement_Request__c)mapData.get('fr1');

        copado__User_Story__c userStory1 = createStory('Draft' ,fr.Id);
        copado__User_Story__c userStory2 = createStory('Draft' ,fr.Id);

        insert new List<copado__User_Story__c>{userStory1,userStory2};
        
        Test.startTest();
            userStory1.copado__Status__c = 'Approved';
            userStory1.Business_Value_Points__c=100;
            update userStory1;
       //     System.assertEquals('Development', [select Status__c from Requirement_Request__c where id =: fr.Id].Status__c);
        Test.stopTest();
        
    }

	@isTest
    public static void test_Process_updateFeatureRequestStatusRequirementAccepted() {
        Map<String,Object> mapData = generateData();
        Hive_Project__c hp = (Hive_Project__c)mapData.get('hp1');
        Requirement_Request__c fr = (Requirement_Request__c)mapData.get('fr1');

        copado__User_Story__c userStory1 = createStory('Draft' ,fr.Id);
        copado__User_Story__c userStory2 = createStory('Draft' ,fr.Id);

        insert new List<copado__User_Story__c>{userStory1,userStory2};

        Test.startTest();
            userStory1.copado__Status__c = 'Backburner';
            userStory1.Business_Value_Points__c=100;
            update userStory1;
       //     System.assertEquals('Requirement Accepted', [select Status__c from Requirement_Request__c where id =: fr.Id].Status__c);
        Test.stopTest();
        
    }
    @isTest
    public static void test_Process_notifyPO() {
        Map<String,Object> mapData = generateData();
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];  
        User objUser = new User(Alias = 'LA1', 
                                Email = 'jacques.th@maxappsltd.co.uk', 
                                EmailEncodingKey = 'UTF-8', 
                                LastName = 'LA',
                                LocaleSidKey = 'en_US', 
                                LanguageLocaleKey='en_US', 
                                ProfileId = objProfile.Id, 
                                TimeZoneSidKey = 'Europe/London', 
                                UserName = 'la@hive.project.com.jacquesdev');
        insert objUser;
        
        copado__Project__c cp = (copado__Project__c)mapData.get('cp1');
        RecordType bugRecType = ApexUtil.getRecordTypeByName('copado__User_Story__c','Bug');
        copado__User_Story__c userStory1 = createStory('Draft', null);

        userStory1.BU_Requester__c=objUser.Id;
        userStory1.Component__c='Salesforce - Admin';
        userStory1.copado__Project__c= cp.Id;
        // userStory1.HIVE_Product__c='Deals';
        userStory1.RecordTypeID = bugRecType.Id;
        //copado__User_Story__c userStory1 = new copado__User_Story__c(copado__Status__c = 'Draft',BU_Requester__c=objUser.Id,Component__c='Salesforce - Admin',copado__Project__c= cp.Id,HIVE_Product__c='System Admin' ,RecordTypeID = bugRecType.Id);
        insert userStory1;
        Test.startTest();
            userStory1.Bug_Priority__c = 'P3';
        	userStory1.Exclude_from_promotion__c = false;
            update userStory1;
        Test.stopTest();
        
    } 
    private static Map<String,Object> generateData(){
        Hive_Project__c hp = new Hive_Project__c(Name='test Hive');
        insert hp;
        copado__Project__c cp = new copado__Project__c(Name='test copado project');
        insert cp;

        RecordType featureRequestRecType = ApexUtil.getRecordTypeByName('Requirement_Request__c','Feature_Request');

        Requirement_Request__c fr = new Requirement_Request__c(Name='test la',Hive_Project__c=hp.Id,Region__c='DE',RecordTypeID = featureRequestRecType.Id);
        insert fr;

        return new Map<String, Object> { 'hp1'  => hp,
                                         'cp1' => cp,
                                         'fr1'=>fr
            
         };
    }

    static copado__User_Story__c createStory(String status, String reqId){
        return new copado__User_Story__c(copado__Status__c = status ,Requirement_Request__c=reqId);
    }

    /***************************************END TEST METHOD FOR PROCESS BUILDER***************************************************/
    
}