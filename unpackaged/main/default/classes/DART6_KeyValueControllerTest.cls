@istest
private class DART6_KeyValueControllerTest {
     
    @testSetup static void setup(){
    	TestDARTCodeCoverage.createTestUser();
        TestDARTCodeCoverage.createCredential('DE');
    }

    @IsTest
    static void testKV(){
         Id RecId = Schema.SObjectType.Targeting__c.getRecordTypeInfosByName().get('Template').getRecordTypeId();
        Targeting__c targ = new Targeting__c();
        targ.Description__c = 'Tageting Template';
        targ.KeyValueString__c = '(Audience Segment=red) AND (car=bmw) AND (car=noname)';
        targ.RecordTypeId = RecId;      
        insert targ;
        List<SObject> keyvalues = TestDARTCodeCoverage.createTargetingKVHierarchy();

        Site__c siteDE = TestDARTCodeCoverage.createSite('DE');
        insert siteDE;

        TargetingKeyValueAssociation__c tas0 = new TargetingKeyValueAssociation__c(Targeting__c=targ.Id,GAM_Key_Value__c=keyvalues[0].get('Id')+'');
        TargetingKeyValueAssociation__c tas1 = new TargetingKeyValueAssociation__c(Targeting__c=targ.Id,GAM_Key_Value__c=keyvalues[1].get('Id')+'');
        TargetingKeyValueAssociation__c tas2 = new TargetingKeyValueAssociation__c(Targeting__c=targ.Id,Audience_Segment__c=keyvalues[6].get('Id')+'');
        
        insert new TargetingKeyValueAssociation__c[]{tas0,tas1,tas2};

        String kvString = '(Audience Segment=red) AND (car=bmw) AND (car=noname)';

        Test.startTest();
            
            DART6_KeyValueController cont = new DART6_KeyValueController(siteDE.Id, kvString,'Auth=xxxxxxxxxxyyyyyyyyyyzzzzzzzzzz','111111');

            //cont.fetchInvalidChars('');
            
            cont.searchCreateDFPFreeFormValues();
            List<DARTObject.IDARTGenericObject> listResult = cont.getListDart();

            if(cont.isNeedToCreate())
            {
                cont.createObjectKeyVal();
            }
            cont.isCreateNewKv();
            cont.updateDart6ValueIds();

            String newText = DART6_KeyValueController.toUIName('test','PREFIX');
            System.assertEquals('test*', newText);
            

        Test.stopTest();
        
    }
}