/*********************************************************************************************************************************
@ Class:          ClsListViewControllerTest
@ Version:        1.0
@ Author:         Sochettra Saing
@ Purpose:        Ability to run test the logic in class ClsListViewController(EBAY-260)
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 28.06.2021 / Sochettra Saing / Created the class.
@ Change history: 25.11.2021 / Sovantheany Dim / Update the class.
*********************************************************************************************************************************/

@isTest
public with sharing class ClsListViewControllerTest {


    static RecordType sellerRecordType;
    static Map<String,RecordType> couponRecordType;
    static Account acc1;
    static Coupon__c c1;
    static Coupon_Seller__c cs1;

    @testSetup
    static void setupData(){

        sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	couponRecordType = ApexUtil.getRecordTypeBySobjectName('Coupon__c');
    	acc1 = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id);
    	insert acc1;
    	// c1 = new Coupon__c(RecordTypeID = couponRecordType.get(EBH_ConstantsUtility.COUPON_CATEGORYBASE).Id);
        c1 = new Coupon__c(Main_Coupon_Site__c = 'ebay.com', RecordTypeID = couponRecordType.get(EBH_ConstantsUtility.COUPON_CATEGORYBASE).Id,Contract_Due_Date__c = System.today()-2, Coupon_Start_Date__c = System.today()+1, Coupon_End_Date__c = System.today() +2);
        insert c1;
    	cs1 = new Coupon_Seller__c(Coupon__c = c1.Id,seller__c = acc1.Id);
    	insert cs1;

    }

    static testMethod void testMethod1() {


        Test.startTest();
        //TH:25.11.2021: test getMtdObjectName for code coverage
        String objectName = ClsListViewController.getMtdObjectName('My_Deal_Related_List');
        System.assertEquals('EBH_Deal__c',objectName);

        //TH:25.11.2021:change to My_Deal_Related_List, previous setting does not exist
        Map<String, Object>  mResult = ClsListViewController.getAllSetting('My_Deal_Related_List');

    //    System.assertEquals('status:success', 'status:'+ mResult.get('status'));

        Map<String, Object>  mSearchResult = ClsListViewController.getSearchResult('Test','My_Deal_Related_List','');
        List<Sobject> lstSobj = (List<Sobject>) mSearchResult.get('listRecord');
        System.assertEquals('listRecord:0', 'listRecord:'+ lstSobj.size());

        Test.stopTest();
    }

    static testMethod void testUpdateContact() {
        Account acc = new Account( Name = 'TestAccount' );
        insert acc;

        //create a contact
        Contact con = new Contact(Accepted_Current_Deals_Agreement__c=false, Portal_Display_Density__c = 'High', FirstName='test fn', LastName='test ln', AccountId=acc.Id, Email = 'test123@test.com');
        insert con;

        Test.StartTest();

        /*String localCode = ClsListViewController.initLocalCode();
        System.debug('>>>>>>> localCode:'+ localCode);
        System.assertEquals('localCode:en', 'localCode:'+localCode);*/
        con.Portal_Display_Density__c = 'Low';
        Map<String, Object>  mResult = ClsListViewController.doUpdateContact(con);

        System.assertEquals('status:success', 'status:'+ mResult.get('status'));
        for(Contact c : [SELECT Id, Portal_Display_Density__c FROM Contact WHERE Id =: con.Id]){

            System.assertEquals('Portal_Display_Density__c:Low', 'Portal_Display_Density__c:'+ c.Portal_Display_Density__c);
        }

        Test.stopTest();
    }

    @isTest
    static void testupdateInterest(){

        setupData();

        List<Id> my_list = new List<Id>();
        my_list.add(c1.id);

        Map<String,Object> result = ClsListViewController.updateInterest(my_list);
        System.assertEquals('success',  result.get('status'));
    }
    @isTest
    static void testupdateNotInterest(){

        setupData();

        List<Id> my_list = new List<Id>();
        my_list.add(c1.id);

        Map<String,Object> result = ClsListViewController.updateNotInterest(my_list);
        System.assertEquals('success',  result.get('status'));
    }

}