@isTest
/*****************************************************************************************************************************************************************
@ Class:          IntellumUserTriggerHandlerTest
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        Test Class for IntellumUserTriggerHandler
----------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history:  17.08.2021 / Sophal Noch / Created the class.
***********************************************************************************************************************************************************/
private class IntellumUserTriggerHandlerTest {

    private static Account acc1;
    private static Account acc2;
    private static Account acc2V1;

    private static Integer iApp1Id = 111;
    private static Integer iApp1V2Id = 112;
    private static Integer iApp2Id = 222;

    private static String ebayApiUser1Id = 'aiUser1';
    private static String ebayApiUser2Id = 'apiUser2';
    private static String ebayApiUser2V1Id = 'apiUser2V1';

    private static String appLogin1 = 'Seller 1';
    private static String appLogin2 = 'Seller 2';


    private static void setupData(){

        insert new EBH_ActiveTriggers__c(Name = 'EBH Trigger Controller',IntellumUserTrigger__c = true);
    
        Id accRtSellerId = [SELECT id from recordType where sobjectType ='Account' and developerName ='EBH_Seller'].Id;

        acc1 = new Account(eBay_API_User_Id__c = ebayApiUser1Id, Name = appLogin1, EBH_VATNumber__c='1122334455', RecordTypeId = accRtSellerId);
        acc2 = new Account(eBay_API_User_Id__c = ebayApiUser2Id, Name = appLogin2, EBH_VATNumber__c='1122334456', RecordTypeId = accRtSellerId);
        acc2V1 = new Account(eBay_API_User_Id__c = ebayApiUser2V1Id, Name = appLogin2, EBH_VATNumber__c='1122334457', RecordTypeId = accRtSellerId);

        insert new List<Account>{acc1,acc2,acc2V1};
    }


    /*****************************************************************************************************************************************************************
    @ Method:         testGetSellersToMatchIUser
    @ Version:        1.0
    @ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:        Test method for IntellumUserTriggerHandler.populateIUserSeller
    ----------------------------------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  17.08.2021 / Sophal Noch / Created the method.
    ----------------------------------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  01.09.2021 / Sophal Noch / Modify the method.
    ***********************************************************************************************************************************************************/
    @isTest
    private static void testGetSellersToMatchIUser(){

        setupData();

        intellumapp__IntellumUser__c iUser1 = new intellumapp__IntellumUser__c(intellumapp__code__c = ebayApiUser1Id, intellumapp__login__c = appLogin1, Name = 'IUser1', intellumapp__id__c = iApp1Id);
        intellumapp__IntellumUser__c iUser1V2 = new intellumapp__IntellumUser__c(intellumapp__code__c = 'xxxxxxxxxxx', intellumapp__login__c = appLogin1, Name = 'IUser1V2', intellumapp__id__c = iApp1V2Id);
        intellumapp__IntellumUser__c iUser2 = new intellumapp__IntellumUser__c(intellumapp__code__c = ebayApiUser2Id, intellumapp__login__c = appLogin2, Name = 'IUser2', intellumapp__id__c = iApp2Id);

        
        List<intellumapp__IntellumUser__c> listIuser =  new List<intellumapp__IntellumUser__c>{iUser1,iUser1V2,iUser2};
        insert listIuser;

        listIuser = [Select Id, Seller__c From intellumapp__IntellumUser__c where Id IN: listIuser];

        Test.startTest();
            System.assertEquals(3, listIuser.size());

            System.assertEquals(acc1.Id, listIuser[0].Seller__c);
            System.assertEquals(acc1.Id, listIuser[1].Seller__c);
            System.assertEquals(acc2.Id, listIuser[2].Seller__c);

        Test.stopTest();

    }

    // @isTest
    // private static void testFlowBeforeInsertAndUpdate(){

    // // Sophal / 17.08.2021 / US-0010060 IntellumEnrollment-Record Update-Before Trigger flow

    //     setupData();

    //     intellumapp__IntellumUser__c iUser1 = new intellumapp__IntellumUser__c(intellumapp__code__c = ebayApiUser1Id, intellumapp__login__c = appLogin1, Name = 'IUser1', intellumapp__id__c = iApp1Id);
    //     intellumapp__IntellumUser__c iUser1V2 = new intellumapp__IntellumUser__c(intellumapp__code__c = 'xxxxxxxxxxx', intellumapp__login__c = appLogin1, Name = 'IUser1V2', intellumapp__id__c = iApp1V2Id);
    //     intellumapp__IntellumUser__c iUser2 = new intellumapp__IntellumUser__c(intellumapp__code__c = ebayApiUser2Id, intellumapp__login__c = appLogin2, Name = 'IUser2', intellumapp__id__c = iApp2Id);

        
    //     List<intellumapp__IntellumUser__c> listIuser =  new List<intellumapp__IntellumUser__c>{iUser1,iUser1V2,iUser2};
    //     insert listIuser;

    //     intellumapp__IntellumActivity__c iA1 = new intellumapp__IntellumActivity__c(Name='Activity 1',intellumapp__id__c=iApp1Id);
    //     intellumapp__IntellumActivity__c iA1V2 = new intellumapp__IntellumActivity__c(Name='Activity 1 V2', intellumapp__id__c=iApp1V2Id);
    //     intellumapp__IntellumActivity__c iA2 = new intellumapp__IntellumActivity__c(Name='Activity 2', intellumapp__id__c=iApp2Id);
    //     insert new List<intellumapp__IntellumActivity__c>{iA1,iA1V2,iA2};

    //     intellumapp__IntellumEnrollment__c iE1 = new  intellumapp__IntellumEnrollment__c(intellumapp__IntellumUser__c=iUser1.Id,intellumapp__id__c=iApp1Id,intellumapp__IntellumActivity__c =iA1.Id);
    //     intellumapp__IntellumEnrollment__c iE1V2 = new  intellumapp__IntellumEnrollment__c(intellumapp__IntellumUser__c=iUser1V2.Id,intellumapp__id__c=iApp1V2Id,intellumapp__IntellumActivity__c =iA1V2.Id);
    //     intellumapp__IntellumEnrollment__c iE2 = new  intellumapp__IntellumEnrollment__c(intellumapp__IntellumUser__c=iUser2.Id,intellumapp__id__c=iApp2Id,intellumapp__IntellumActivity__c =iA2.Id);

    //     List<intellumapp__IntellumEnrollment__c> listIe =  new List<intellumapp__IntellumEnrollment__c>{iE1,iE1V2,iE2};
    //     Test.startTest();
    //         insert listIe;
    //         listIe = [Select Id, Seller__c From intellumapp__IntellumEnrollment__c where Id IN: listIe];
    //         System.assertEquals(acc1.Id, listIe[0].Seller__c);
    //         System.assertEquals(acc1.Id, listIe[1].Seller__c);
    //         System.assertEquals(acc2.Id, listIe[2].Seller__c);
    //     Test.stopTest();

    // }

}