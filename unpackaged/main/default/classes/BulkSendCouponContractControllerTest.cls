/*********************************************************************************************************************************
@ Class:          BulkSendCouponContractControllerTest
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        BulkSendCouponContractController
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:  27.08.2020 / Sophal Noch / Created the class.
*********************************************************************************************************************************/
@isTest
private class BulkSendCouponContractControllerTest {

    static testMethod void testInitAndSaveCoupounSeller(){
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        Account acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id,EBH_DealsProgram__c='Accepted');
        insert acc;

        Contact con = new Contact(LastName='Test Con1', Email='test@test.com.invalid', AccountId=acc.Id);
        Contact con2 = new Contact(LastName='Test Con2', Email='test2@test.com.invalid', AccountId=acc.Id);
        insert new List<Contact>{con, con2};

        Coupon__c c1 = new Coupon__c(Seller_Co_funding_share_forecast__c = null,Coupon_Start_Date__c = System.today(),Coupon_End_Date__c = System.today().addDays(1), Negotiation_End_Date__c=System.today().addDays(1));
        insert c1;

        Coupon_Seller__c cs1 = new Coupon_Seller__c(Seller_Contact__c = con.Id, Coupon__c = c1.Id,seller__c = acc.Id,Legal_Entity_Name_w__c = 'testName',Legal_Entity_Street_w__c='testStreet',Legal_Entity_Zip_w__c='testZip');
        Coupon_Seller__c cs2 = new Coupon_Seller__c(Seller_Contact__c = con2.Id, Coupon__c = c1.Id,seller__c = acc.Id,Legal_Entity_Name_w__c = 'testName',Legal_Entity_Street_w__c='testStreet',Legal_Entity_Zip_w__c='testZip');

        /* //MN-30082021-US-0009948-Replace Email_Adress__c with Seller_Contact__c
        Coupon_Seller__c cs1 = new Coupon_Seller__c(Email_Adress__c = 'sophal.noch@gaea-sys.com', Coupon__c = c1.Id,seller__c = acc.Id,Legal_Entity_Name_w__c = 'testName',Legal_Entity_Street_w__c='testStreet',Legal_Entity_Zip_w__c='testZip');
        Coupon_Seller__c cs2 = new Coupon_Seller__c(Email_Adress__c = 'sophal.noch@gaea-sys.com',Coupon__c = c1.Id,seller__c = acc.Id,Legal_Entity_Name_w__c = 'testName',Legal_Entity_Street_w__c='testStreet',Legal_Entity_Zip_w__c='testZip');
        */
        insert new List<Coupon_Seller__c>{cs1,cs2}; 

        cs1.Legal_Entity_Name_w__c = 'testName';
        cs1.Legal_Entity_Street_w__c = 'testStreet';
        cs1.Legal_Entity_Zip_w__c = 'testZip';

        cs2.Legal_Entity_Name_w__c = 'testName';
        cs2.Legal_Entity_Street_w__c = 'testStreet';
        cs2.Legal_Entity_Zip_w__c = 'testZip';

        update new List<Coupon_Seller__c>{cs1,cs2}; 

        
        Coupon_Co_Invest__c coInvestForCs1 = new Coupon_Co_Invest__c(Coupon_Seller__c=cs1.Id, Seller_Name__c=acc.Id,Coupon_Name__c=c1.Id,Co_Invest__c=10);
        Coupon_Co_Invest__c coInvestForCs2 = new Coupon_Co_Invest__c(Coupon_Seller__c=cs2.Id, Seller_Name__c=acc.Id,Coupon_Name__c=c1.Id,Co_Invest__c=20);
        
        insert new List<Coupon_Co_Invest__c>{coInvestForCs1,coInvestForCs2}; 

       

        PermissionSet ps = Database.query('SELECT Id, Name FROM PermissionSet WHERE Name = \'Coupon_Special_Permission\'');

        User standardUser = [
            SELECT Id FROM User 
            WHERE Profile.Name = 'Standard User Profile' 
            AND IsActive = true
            AND Id NOT IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =: ps.Id)
            LIMIT 1
        ];

        System.assertNotEquals(null, standardUser.Id);


        System.runAs(standardUser){

            Map<String,Object> mapResult = BulkSendCouponContractController.apexInit(c1.Id);

            System.assertEquals(System.Label.ErrorNoCouponSpecialPermission, (String)mapResult.get('error'));
            System.assertEquals('ko', (String)mapResult.get('status'));

        }

       

       
        
        Test.startTest();
        System.runAs(standardUser){

            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = UserInfo.getUserId());
            insert psa;

            Map<String,Object> mapResult = BulkSendCouponContractController.apexInit(c1.Id);
            System.assertEquals('ok', (String)mapResult.get('status'));
    
            List<Coupon_Seller__c> listCoSeller = ((List<Coupon_Seller__c>)mapResult.get('listCoSeller'));
    
            System.assertEquals(2, listCoSeller.size());
    
    
            mapResult = BulkSendCouponContractController.apexSave(listCoSeller);
            System.assertEquals('ko', (String)mapResult.get('status'));
            System.assertEquals(System.Label.ErrorNoCouponSellerInApprovedStage, (String)mapResult.get('error'));
    
            listCoSeller[0].Coupon_Seller_Stage__c = EBH_ConstantsUtility.COUPONSELLER_STAGE_APPROVED;
            listCoSeller[1].Coupon_Seller_Stage__c = EBH_ConstantsUtility.COUPONSELLER_STAGE_APPROVED;
            update listCoSeller;
    
            mapResult = BulkSendCouponContractController.apexSave(listCoSeller);
            System.assertEquals(null, (String)mapResult.get('error'));
            System.assertEquals('ok', (String)mapResult.get('status'));
    
            List<Coupon_Seller__c> listCoSellerAfterUpdated = [SELECT Id,Coupon_Seller_Stage__c FROM Coupon_Seller__c where Id =: listCoSeller[0].Id OR Id =: listCoSeller[1].Id];
            System.assertEquals(EBH_ConstantsUtility.COUPON_SELLER_STAGE_CONTRACT_SEND, listCoSellerAfterUpdated[0].Coupon_Seller_Stage__c);
            System.assertEquals(EBH_ConstantsUtility.COUPON_SELLER_STAGE_CONTRACT_SEND, listCoSellerAfterUpdated[1].Coupon_Seller_Stage__c);

        }
        Test.stopTest();


        


    }

}