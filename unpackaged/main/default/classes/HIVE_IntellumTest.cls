@isTest
private class HIVE_IntellumTest {

    @IsTest
    static void testCreateEnrol()
    {
        
        Test.startTest();
        
        String iDateFormat = 'yyyy-MM-dd';
        String iDateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm:00Z';
        Map<String,Object> mapCourse  = new Map<String,Object>{'id'=>'91673733'};
        Map<String,Object> mapUser = new Map<String,Object>{'id'=>'582732833'};
        Map<String,Object> mapEnrol  = new Map<String,Object>
            {
            'course'=>mapCourse,
            'user'=>mapUser,
            'relationship_type'=>'recommended',
            'relationship_reason'=>'tested from api',             
            'due_on'=> System.now().addDays(20).formatGmt(iDateFormat),
            'expires_on'=> System.now().addDays(20).formatGmt(iDateTimeFormat)
            };
        Map<String,Object> mapParam  = new Map<String,Object>{'enrollment'=>mapEnrol};

        HIVE_Intellum.createEnrollmentService createEnrol = new HIVE_Intellum.createEnrollmentService(mapParam);
        createEnrol.sendRequest();
        Map<String,Object> result = createEnrol.getResult();
        system.debug('--result: '+result);
        //upsert (List<intellumapp__IntellumEnrollment__c>)createEnrol.getListObject() intellumapp__id__c;


        Test.stopTest();
        
    }
    @IsTest
    static void testListEnrol()
    {
        Test.startTest();

        HIVE_Intellum.ListEnrollmentService listService = new HIVE_Intellum.ListEnrollmentService(new Map<String,Object>());


        Test.stopTest();
    }
     
}