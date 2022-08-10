@isTest
private class DeleteUserAvailabilityControllerTest {

    @testSetup
    static void setupData(){

    }

    @isTest
    private static void testDeleteUserAvailability()
    {
    	DeleteUserAvailabilityController dUA;
        User stdU = EBH_TestDataFactory.createUser('Business Admin');
        insert stdU;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: DeleteUserAvailabilityController.PERMISSION_BOB_CATEGORY_LEAD];
        insert new PermissionSetAssignment(AssigneeId = stdU.id, PermissionSetId = ps.Id);

    	Test.startTest();
            System.runAs(stdU){
                User_Availability__c ua1 = new User_Availability__c();
                insert ua1;

                User_Availability__c ua2 = new User_Availability__c();
                insert ua2;

                List<User_Availability__c> lstUA = [SELECT Id FROM User_Availability__c];
                System.assert(lstUA.size() == 2);

                ApexPages.StandardSetController sc = new ApexPages.StandardSetController(lstUA);
                sc.setSelected(lstUA);
                dUA = new DeleteUserAvailabilityController(sc);
                dUA.backToListView();
                dUA.initDeleting();
                dUA.actionDelete();
            }
    	Test.stopTest();
        System.assert([SELECT Id FROM User_Availability__c].isEmpty());
    	
    }

    @isTest
    private static void testDeleteUserAvailabilityError()
    {
    	DeleteUserAvailabilityController dUA;
        User stdU = EBH_TestDataFactory.createUser('Business Admin');
        insert stdU;

    	Test.startTest();
            System.runAs(stdU){
                User_Availability__c ua1 = new User_Availability__c();
                insert ua1;

                User_Availability__c ua2 = new User_Availability__c();
                insert ua2;

                List<User_Availability__c> lstUA = [SELECT Id FROM User_Availability__c];
                System.assert(lstUA.size() == 2);

                ApexPages.StandardSetController sc = new ApexPages.StandardSetController(lstUA);
                sc.setSelected(lstUA);
                dUA = new DeleteUserAvailabilityController(sc);
                dUA.backToListView();
                dUA.initDeleting();
                dUA.actionDelete();
            }
    	Test.stopTest();
        System.assert([SELECT Id FROM User_Availability__c].size() == 2);
    	
    }
}