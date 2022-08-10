/*********************************************************************************************************************************
@ Class:          BulkEditCouponCoInvestControllerTest
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        BulkEditCouponCoInvestController
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:  07.09.2020 / Sophal Noch / Created the class.
*********************************************************************************************************************************/
@isTest
public without sharing class BulkEditCouponCoInvestControllerTest {
    static testMethod void testInitAndSaveCouponCoInvest(){

        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        Account acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id,EBH_DealsProgram__c='Accepted');
        insert acc;

        Contact con = new Contact(LastName='Test Con1', Email='test@test.com.invalid', AccountId=acc.Id);
        insert con;

        Coupon__c c1 = new Coupon__c(Seller_Co_funding_share_forecast__c = null,Coupon_Start_Date__c = System.today(),Coupon_End_Date__c = System.today().addDays(1), Negotiation_End_Date__c=System.today().addDays(1));
        insert c1;
        
        //MN-30082021-US-0009948-Replace Email_Adress__c with Seller_Contact__c
        Coupon_Seller__c cs1 = new Coupon_Seller__c(Seller_Contact__c = con.Id, Coupon__c = c1.Id,seller__c = acc.Id,Legal_Entity_Name_w__c = 'testName',Legal_Entity_Street_w__c='testStreet',Legal_Entity_Zip_w__c='testZip');
        insert cs1;
        
        /* //MN-30082021-US-0009948-Replace Email_Adress__c with Seller_Contact__c
        Coupon_Seller__c cs1 = new Coupon_Seller__c(Email_Adress__c = 'sophal.noch@gaea-sys.com', Coupon__c = c1.Id,seller__c = acc.Id,Legal_Entity_Name_w__c = 'testName',Legal_Entity_Street_w__c='testStreet',Legal_Entity_Zip_w__c='testZip');
        insert cs1;
        */

        cs1.Legal_Entity_Name_w__c = 'testName';
        cs1.Legal_Entity_Street_w__c = 'testStreet';
        cs1.Legal_Entity_Zip_w__c = 'testZip';

        update cs1;

        Coupon_Co_Invest__c coInvest1 = new Coupon_Co_Invest__c(Coupon_Seller__c=cs1.Id, Seller_Name__c=acc.Id,Coupon_Name__c=c1.Id,Co_Invest__c=10);
        Coupon_Co_Invest__c coInvest2 = new Coupon_Co_Invest__c(Coupon_Seller__c=cs1.Id, Seller_Name__c=acc.Id,Coupon_Name__c=c1.Id,Co_Invest__c=20);
        
        List<Coupon_Co_Invest__c> listCoInvestToInsert = new List<Coupon_Co_Invest__c>{coInvest1,coInvest2}; 
        insert listCoInvestToInsert;

        Map<String,Object> mapResult = BulkEditCouponCoInvestController.apexInit();
        System.assertEquals('ok', mapResult.get('status'));

        listCoInvestToInsert[0].Co_Invest__c = 50;
        listCoInvestToInsert[1].Co_Invest__c = 60;

        mapResult = BulkEditCouponCoInvestController.apexSave(listCoInvestToInsert);

        System.assertEquals('ok', mapResult.get('status'));

        List<Coupon_Co_Invest__c> listCoInvestAfterUpdate = [SELECT Id, Co_Invest__c from Coupon_Co_Invest__c WHERE Id IN : listCoInvestToInsert Order By Id ASC];

        System.assertEquals(listCoInvestToInsert[0].Co_Invest__c, listCoInvestAfterUpdate[0].Co_Invest__c);
        System.assertEquals(listCoInvestToInsert[1].Co_Invest__c, listCoInvestAfterUpdate[1].Co_Invest__c);

    }
}