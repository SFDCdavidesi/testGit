@isTest
private class HIVE_Intellum_EnrollmentControllerTest {
    
    @TestSetup
    static void makeData(){
    	 Account test_account = new Account(
                Name = 'Test Account'
            );
        insert test_account;
        intellumapp__IntellumActivity__c i_act = new intellumapp__IntellumActivity__c(intellumapp__id__c=91673733);
        intellumapp__IntellumUser__c i_user = new intellumapp__IntellumUser__c(Seller__c=test_account.Id,intellumapp__id__c=582732833);
        insert new SObject[]{i_act,i_user};

        

    }

    @IsTest
    static void testCreateEnrol()
    {
        
        Test.startTest();
        
         String iDateFormat = 'yyyy-MM-dd';
        // String iDateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm:00Z';
        // Map<String,Object> mapCourse  = new Map<String,Object>{'id'=>'91673733'};
        // Map<String,Object> mapUser = new Map<String,Object>{'id'=>'582732833'};
        // Map<String,Object> mapEnrol  = new Map<String,Object>
        //     {
        //     'course'=>mapCourse,
        //     'user'=>mapUser,
        //     'relationship_type'=>'recommended',
        //     'relationship_reason'=>'tested from api',             
        //     'due_on'=> System.now().addDays(20).formatGmt(iDateFormat),
        //     'expires_on'=> System.now().addDays(20).formatGmt(iDateTimeFormat)
        //     };
        // Map<String,Object> mapParam  = new Map<String,Object>{'enrollment'=>mapEnrol};

        // HIVE_Intellum.createEnrollmentService createEnrol = new HIVE_Intellum.createEnrollmentService(mapParam);
        // createEnrol.sendRequest();
        // Map<String,Object> result = createEnrol.getResult();
        // system.debug('--result: '+result);
        // upsert (List<intellumapp__IntellumEnrollment__c>)createEnrol.getListObject() intellumapp__id__c;
        // 
        
        
        List<intellumapp__IntellumActivity__c> activities = [Select Id,intellumapp__id__c From intellumapp__IntellumActivity__c];
        List<intellumapp__IntellumUser__c> iUser = [Select Id From intellumapp__IntellumUser__c];
        List<Account> acc = [Select Id From Account];
        intellumapp__IntellumEnrollment__c intellum = new intellumapp__IntellumEnrollment__c();
        intellum.intellumapp__due_on__c = System.today();
		intellum.intellumapp__status__c = 'New';
		intellum.intellumapp__relationship_type__c = 'recommended';
		intellum.intellumapp__IntellumUser__c = iUser[0].Id;
		intellum.Relationship_Reason__c = 'Test';
        intellum.Seller__c = acc[0].Id;
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(acc);
		HIVE_Intellum_EnrollmentController intellumEnrollment = new HIVE_Intellum_EnrollmentController(sc);
        HIVE_Intellum_EnrollmentController.createIntellumEnrollment(intellum,activities,582732833);
        List<intellumapp__IntellumEnrollment__c> listEnrollment = [Select Id From intellumapp__IntellumEnrollment__c];
        System.assertEquals(1, listEnrollment.size());
        Test.stopTest();
        
    }
}