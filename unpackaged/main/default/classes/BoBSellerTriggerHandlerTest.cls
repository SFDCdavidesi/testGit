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
@isTest
private class BoBSellerTriggerHandlerTest {
	/*
    static testMethod void testPopulateBoBFieldsToSeller() {
        List<Account> sellers = EBH_TestDataFactory.createAccounts(2, 'EBH_Seller');
        Test.startTest();
            BoB__c bob = new BoB__c(Status__c='Draft',EBH_BOBCNTRY__c='3',EBH_BOBVertical__c='Fashion');
            insert bob;
            BoB_Seller__c bs = new BoB_Seller__c(Account_Manager__c=UserInfo.getUserId(),Parent_Seller__c=sellers[0].Id,Status__c=EBH_ConstantsUtility.BOB_SELLER_STATUS_NEW,Seller__c=sellers[0].Id,BoB__c = bob.Id,EBH_BOBSegment__c='MSO',BoB_Subsegment__c='Platin');
            BoB_Seller__c bs2 = new BoB_Seller__c(Account_Manager__c=UserInfo.getUserId(),Parent_Seller__c=sellers[0].Id,Status__c=EBH_ConstantsUtility.BOB_SELLER_STATUS_REMOVED,Seller__c=sellers[1].Id,BoB__c = bob.Id,EBH_BOBSegment__c='MSO',BoB_Subsegment__c='Platin');
            insert new List<BoB_Seller__c>{bs,bs2};  
            bob.Status__c=EBH_ConstantsUtility.BOB_STATUS_ACTIVE;
            update bob;
            //delete bs;
        Test.stopTest();
        Account acc = [Select Id,EBH_BOBManaged__c,EBH_BOBCNTRY__c,EBH_BOBVertical__c,EBH_BOBSegment__c,BoB_Subsegment__c From Account Where Id=:sellers[0].Id];
         System.assertEquals(true,acc.EBH_BOBManaged__c,' acc.EBH_BOBManaged__c is true from BoB');
         System.assertEquals(acc.EBH_BOBCNTRY__c,EBH_ConstantsUtility.MAP_CODE_TO_COUNTRY.get(bob.EBH_BOBCNTRY__c),' bob country from bob to seller');
         System.assertEquals(bob.EBH_BOBVertical__c,acc.EBH_BOBVertical__c,' acc.EBH_BOBVertical__c is   from BoB');
         System.assertEquals(bs.EBH_BOBSegment__c,bs.EBH_BOBSegment__c,' acc.EBH_BOBSegment__c is   from BoB');
         System.assertEquals(bs.BoB_Subsegment__c,acc.BoB_Subsegment__c,' acc.BoB_Subsegment__c is   from BoB');
    }
    */
    static testMethod void testValidateBoBSeller()
    {
        User existAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

        BoBSellerViewControllerTest.setUpUserGroup();
        List<Account> sellers = EBH_TestDataFactory.createAccounts(3, 'EBH_Seller');
        RecordType bobRecordTypeManage = ApexUtil.getRecordTypeByName('BOB__c',EBH_ConstantsUtility.BOB_MANAGE_RECORDTYPE);
        RecordType bobSellerRecordTypeManaged = ApexUtil.getRecordTypeByName('BoB_Seller__c','Managed');
        Test.startTest();
            BoB__c bob = new BoB__c(RecordTypeId = bobRecordTypeManage.Id ,Status__c=EBH_ConstantsUtility.BOB_SELLER_STATUS_DRAFT,/*BoB_Cohort__c='2018',*/EBH_BOBCNTRY__c='Spain',EBH_BOBVertical__c='Fashion');
            insert bob;
            BoB_Seller__c bs = new BoB_Seller__c(RecordTypeId = bobSellerRecordTypeManaged.Id,Account_Manager__c=UserInfo.getUserId(),Parent_Seller__c=sellers[0].Id,Seller__c=sellers[0].Id,BoB__c = bob.Id,EBH_BOBSegment__c='MSO',BoB_Subsegment__c='Platin');
            insert bs;  
        Test.stopTest();
        //test duplicate
        BoB_Seller__c bs2 = new BoB_Seller__c(RecordTypeId = bobSellerRecordTypeManaged.Id,Account_Manager__c=UserInfo.getUserId(),Parent_Seller__c=sellers[0].Id,Seller__c=sellers[1].Id,BoB__c = bob.Id,EBH_BOBSegment__c='MSO',BoB_Subsegment__c='Platin');
        insert bs2;
        try
        {
            bs2.Seller__c=sellers[0].Id;
            update bs2;
        }catch(Exception ex)
        {
            System.assert(ex.getDmlMessage(0).startsWith(System.Label.ErrorSellerDuplicate.substring(0,10)),'duplicate error');
        }
        //test seller occupied by another active bob
        BoB__c bob2 = new BoB__c(RecordTypeId = bobRecordTypeManage.Id ,Status__c=EBH_ConstantsUtility.BOB_STATUS_ACTIVE/*,BoB_Cohort__c='2018'*/,EBH_BOBCNTRY__c='3',EBH_BOBVertical__c='Fashion');
        insert bob2;
        BoB_Seller__c bs3 = new BoB_Seller__c(RecordTypeId = bobSellerRecordTypeManaged.Id,Account_Manager__c=UserInfo.getUserId(),Parent_Seller__c=sellers[0].Id,Seller__c=sellers[2].Id,BoB__c = bob2.Id,EBH_BOBSegment__c='MSO',BoB_Subsegment__c='Platin');
        insert bs3;
//        BoB__c bob4 = new BoB__c(Status__c=EBH_ConstantsUtility.BOB_SELLER_STATUS_DRAFT,BoB_Cohort__c='2018',EBH_BOBCNTRY__c=null,EBH_BOBVertical__c='Fashion');
        BoB__c bob4 = new BoB__c(RecordTypeId = bobRecordTypeManage.Id , Status__c=EBH_ConstantsUtility.BOB_SELLER_STATUS_DRAFT,EBH_BOBCNTRY__c='Portugal',EBH_BOBVertical__c='Fashion');
        insert bob4;
        BoB_Seller__c bs4 = new BoB_Seller__c(RecordTypeId = bobSellerRecordTypeManaged.Id,Account_Manager__c=UserInfo.getUserId(),Parent_Seller__c=sellers[0].Id,Seller__c=sellers[0].Id,BoB__c = bob4.Id,EBH_BOBSegment__c='MSO',BoB_Subsegment__c='Platin');
        try
        {
            insert bs4;
        }catch(Exception ex)
        {
            system.debug('>>>error: '+ex.getDmlMessage(0));
            System.assert(ex.getDmlMessage(0).startsWith(System.Label.ErrorSellerPartOfActiveBoB.substring(0,10)),'error: bob seller occupied by another aticve bob');
        }
        //test delete
        try
        {
            delete bs;
        }catch(Exception ex)
        {
            System.assert(ex.getMessage().contains(System.Label.ErrorBoBSellerDelete),'error: only New can be deleted');
        }
        //test assignAccountManagerToSellerOwner
        List<User> admUsers = EBH_TestDataFactory.createUsers(1, 'System Administrator');
        admUsers[0].BoB_Country__c = '3';

        System.runAs(existAdmin){
            insert admUsers;
        }

        
        System.runAs(admUsers[0])
        {
        	Group gcxOp = [Select Id,Name,DeveloperName From Group Where DeveloperName =:EBH_ConstantsUtility.BOB_GROUP_BOB_GCX_OPERATIONS];
        	GroupMember gm1 = new GroupMember(UserOrGroupId=admUsers[0].Id,GroupId=gcxOp.Id);
        	insert gm1;
        }
        bs3.Account_Manager__c = admUsers[0].Id;
        update bs3;
        /*
        Account selAccount = [Select Id,OwnerId from Account where Id=:sellers[2].Id];
        System.assertEquals(bs3.Account_Manager__c,selAccount.OwnerId,'Owner updated from BoBSeller Account Manager');
        */
    }
    static testMethod void testpopulateBobSeller(){

        User existAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

    	RecordType bobRecordTypeLTTM = ApexUtil.getRecordTypeByName('BOB__c',EBH_ConstantsUtility.BOB_LTTM_RECORDTYPE);
    	RecordType bobSellerRecordTypeLttm = ApexUtil.getRecordTypeByName('BoB_Seller__c','LTTM');
    	List<User> admUsers = EBH_TestDataFactory.createUsers(1, 'System Administrator');
        admUsers[0].BoB_Country__c = '3';
        System.runAs(existAdmin){
            insert admUsers;
        }
        List<Account> sellers = EBH_TestDataFactory.createAccounts(1, 'EBH_Seller');
    	 Test.startTest();
            BoB__c bob = new BoB__c(Status__c=EBH_ConstantsUtility.BOB_SELLER_STATUS_DRAFT,EBH_BOBCNTRY__c='Spain',EBH_BOBVertical__c='Fashion',RecordTypeId = bobRecordTypeLTTM.Id,Account_Manager__c = admUsers[0].Id);
            insert bob;
            BoB_Seller__c bs = new BoB_Seller__c(RecordTypeId = bobSellerRecordTypeLttm.Id,Account_Manager__c=UserInfo.getUserId(),Seller__c=sellers[0].Id,BoB__c = bob.Id,EBH_BOBSegment__c='MSO',BoB_Subsegment__c='Platin');
            insert bs;  
        Test.stopTest();
        BoB_Seller__c bss = [select Account_Manager__c, Parent_Seller__c,Seller__c, EBH_BOBSegment__c from BoB_Seller__c where id =: bs.Id];
        System.assertEquals(bss.Account_Manager__c,bob.Account_Manager__c,'auto populate bobSeller.Account Manager = bob.Account Manager');
        System.assertEquals(bss.Parent_Seller__c,bss.Seller__c,'set "Parent Seller" = seller if Parent Seller is empty');
        //System.assertEquals(bss.EBH_BOBSegment__c,EBH_ConstantsUtility.BOB_SELLER_SEGMENT_LTTM,'set default Segment to LTTM for LTTML bob record type');
    }


    @isTest
    private static void testUpdateUserAvailibilityWithBobSeller(){
        insert new EBH_ActiveTriggers__c(Name = 'EBH Trigger Controller',UserAvailabilityTrigger__c = true, EBH_TaskTrigger__c = true);

        RecordType bobRecordTypeLTTM = ApexUtil.getRecordTypeByName('BOB__c',EBH_ConstantsUtility.BOB_LTTM_RECORDTYPE);
    	RecordType bobSellerRecordTypeLTTM = ApexUtil.getRecordTypeByName('BoB_Seller__c','LTTM');
        
        BoB__c bob = new BoB__c(
            RecordTypeId = bobRecordTypeLTTM.Id ,
            Name='Bob 1',
            Status__c = 'BoB Active',
            Managed_Type__c = 'LTTM Managed'
        );
        insert bob;
        
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
 		Account seller = new Account(Name='Seller',RecordTypeID = sellerRecordType.Id);
        Account seller1 = new Account(Name='Seller222',RecordTypeID = sellerRecordType.Id);
        insert new List<Account>{seller,seller1};

        Id currentUserId = UserInfo.getUserId();

        Date d = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        Datetime dt = (DateTime)d;
        String dow = dt.format('EEEE');
        if (dow == 'Saturday') d = Date.today().addDays(3);
        else if (dow == 'Sunday') d = Date.today().addDays(2);
        
        BOB_Seller__c bobSeller = new BOB_Seller__c(
            RecordTypeId = bobSellerRecordTypeLTTM.Id ,
            BOB__c=bob.Id, 
            Seller__c=seller.Id,
            Next_Call_Schedule_Date__c = d,
            Time_Slot__c = 'Morning (9 AM to 12 PM)'
        );
        
        insert bobSeller;
        
        bobSeller.Account_Manager__c = currentUserId;
        update bobSeller;



        Test.startTest();
            User_Availability__c uv = new User_Availability__c(Date__c=d, Unique_Id__c=(currentUserId+'#'+d), Available_Calls_Morning_Slot__c = 4, Available_Calls_Afternoon_Slot__c = 4, OwnerId=currentUserId);
            insert uv;
            uv = [Select Id, Date__c, Unique_Id__c, Scheduled_Calls_Morning_Slot__c, Scheduled_Calls_Afternoon_Slot__c From User_Availability__c Where Id =: uv.Id];
            System.assertEquals(1, uv.Scheduled_Calls_Morning_Slot__c);
            System.assertEquals(null, uv.Scheduled_Calls_Afternoon_Slot__c);

            BOB_Seller__c bobSeller1 = new BOB_Seller__c(
                RecordTypeId = bobSellerRecordTypeLTTM.Id ,
                BOB__c=bob.Id, 
                Seller__c=seller1.Id,
                Next_Call_Schedule_Date__c = d,
                Time_Slot__c = 'Afternoon(1 PM to 5 PM)'
            );

            insert bobSeller1;
            bobSeller1.Account_Manager__c = currentUserId;
            update bobSeller1;

            uv = [Select Id, Date__c, Unique_Id__c, Scheduled_Calls_Morning_Slot__c, Scheduled_Calls_Afternoon_Slot__c From User_Availability__c Where Id =: uv.Id];
            System.assertEquals(1, uv.Scheduled_Calls_Morning_Slot__c);
            System.assertEquals(1, uv.Scheduled_Calls_Afternoon_Slot__c);

        Test.stopTest();
    }
}