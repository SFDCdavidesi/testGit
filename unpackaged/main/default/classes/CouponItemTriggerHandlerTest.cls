/*********************************************************************************************************************************
@ Class:          CouponItemTriggerHandlerTest
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        test Class for trigger Coupon Item
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 19.04.2019 / Sovantheany Dim / Created the class.
*********************************************************************************************************************************/
@isTest
private class CouponItemTriggerHandlerTest {
    static testmethod void setupData(){
        EBH_TestDataFactory.setUpCustomSettings();   
        
       
    }
    static testMethod void myUnitTest() {
        setupData();
    	RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	RecordType coRecordType = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_ITEMBASE);
    	Account acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id);
    	insert acc;
    	Coupon__c c1 = new Coupon__c(RecordTypeID = coRecordType.Id);
		insert c1;
		Coupon_Seller__c cs1 = new Coupon_Seller__c(Coupon__c = c1.Id,seller__c = acc.Id,Coupon_Seller_Stage__c=EBH_ConstantsUtility.COUPON_SELLER_STAGE_NEGO);
    	insert cs1;
        Coupon_Co_Invest__c[] cciSel = [select Id From Coupon_Co_Invest__c Where Coupon_Seller__c = :cs1.Id and RecordType.DeveloperName =: EBH_ConstantsUtility.CO_INVEST_ITEM];
        System.assert(cciSel.isEmpty(),'there is no co invest created, because no Coupon item related');
        Test.startTest();
        Coupon_Item__c ci = new Coupon_Item__c(Coupon_ID__c=c1.Id, Coupon_Seller_ID__c=cs1.Id,Item_ID__c='1234567890');
        insert ci;
        Test.stopTest();
        Coupon_Co_Invest__c[] cciSel1 = [select Id,RecordType.DeveloperName From Coupon_Co_Invest__c Where Coupon_Seller__c = :cs1.Id and RecordType.DeveloperName =: EBH_ConstantsUtility.CO_INVEST_ITEM];
        System.assert(cciSel1.size() == 1);
        
    }

    static testMethod void deleteUpdateCouponItemTest(){
    	setupData();
        String userId = UserInfo.getUserId();
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        RecordType coRecordType = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_ITEMBASE);
        Account acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id);
        insert acc;
        Coupon__c c1 = new Coupon__c(RecordTypeID = coRecordType.Id);
        insert c1;
        Coupon_Seller__c cs1 = new Coupon_Seller__c(Coupon__c = c1.Id,seller__c = acc.Id,Coupon_Seller_Stage__c='Contract Signed');
        insert cs1;
        Coupon_Item__c ci1 = new Coupon_Item__c(Coupon_ID__c=c1.Id, Coupon_Seller_ID__c=cs1.Id,Item_ID__c='123');
        Coupon_Item__c ci2 = new Coupon_Item__c(Coupon_ID__c=c1.Id, Coupon_Seller_ID__c=cs1.Id,Item_ID__c='12356');
        List<Coupon_Item__c> ctList = new List<Coupon_Item__c>{ci1};
        insert ctList;
        Test.startTest();
            try {
                ci1.Item_ID__c = '1111';
                update ci1;
                delete ctList;
            }catch(Exception ex) {
                System.assert(ex.getMessage().contains(System.Label.Prevent_Deletion_of_Coupon_Seller_Item_Category));
            }

            cs1.Coupon_Seller_Stage__c = 'Contract Negotiation';
            update cs1;

            ci1.Item_ID__c = '1111';
            update ci1;
            delete ctList;
	        
            //CouponItemTriggerHandler.deleteUpdateCouponItem(ctList);
        Test.stopTest();
    }
    
    static testMethod void testvalidateCouponItem(){
    	setupData();
    	RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        RecordType coRecordType = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_ITEMBASE);
        Account acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id);
        insert acc;
        Coupon__c c1 = new Coupon__c(RecordTypeID = coRecordType.Id);
        insert c1;
        Coupon_Seller__c cs1 = new Coupon_Seller__c(Coupon__c = c1.Id,seller__c = acc.Id,Coupon_Seller_Stage__c='Contract Signed');
        insert cs1;
        Coupon_Item__c ci1 = new Coupon_Item__c(Coupon_ID__c=c1.Id, Coupon_Seller_ID__c=cs1.Id,Item_ID__c='100001');
        Coupon_Item__c ci2 = new Coupon_Item__c(Coupon_ID__c=c1.Id, Coupon_Seller_ID__c=cs1.Id,Item_ID__c='100002');
        List<Coupon_Item__c> ctList = new List<Coupon_Item__c>{ci1,ci2};
        insert ctList;
        Test.startTest();
        try{
        	Coupon_Item__c ci3 = new Coupon_Item__c(Coupon_ID__c=c1.Id, Coupon_Seller_ID__c=cs1.Id,Item_ID__c='100001');
       	 	Coupon_Item__c ci4 = new Coupon_Item__c(Coupon_ID__c=c1.Id, Coupon_Seller_ID__c=cs1.Id,Item_ID__c='100002');
       	 	insert new List<Coupon_Item__c>{ci3,ci4};
        }catch(Exception e){
        	System.assert(true);
        	//System.assert(e.getMessage().contains(System.Label.Error_Duplicate_Coupon_Item_In_File),'error: '+System.Label.Error_Duplicate_Coupon_Item_In_File);
        	System.assert(e.getMessage().contains(System.Label.Error_Duplicate_Coupon_Item),'error: '+System.Label.Error_Duplicate_Coupon_Item);
        }
        Test.stopTest();
    }

    @isTest
    static void test_preventRecordDeletion(){

    	setupData();
    	
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        RecordType coRecordType = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_ITEMBASE);
        
        Account acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id);
        insert acc;
        
        Coupon__c c1 = new Coupon__c(RecordTypeID = coRecordType.Id);
        insert c1;
        
        Coupon_Seller__c cs1 = new Coupon_Seller__c(Coupon__c = c1.Id,seller__c = acc.Id,Coupon_Seller_Stage__c='Contract Signed');
        insert cs1;
        
        Coupon_Item__c ci1 = new Coupon_Item__c(Coupon_ID__c=c1.Id, Coupon_Seller_ID__c=cs1.Id,Item_ID__c='100001');
        Coupon_Item__c ci2 = new Coupon_Item__c(Coupon_ID__c=c1.Id, Coupon_Seller_ID__c=cs1.Id,Item_ID__c='100002');
        List<Coupon_Item__c> ctList = new List<Coupon_Item__c>{ci1,ci2};
        insert ctList;
        
        Test.startTest();
            try{
                delete ctList;

            }catch(Exception ex){
                System.assert(ex.getMessage().contains(System.Label.Prevent_Deletion_of_Coupon_Seller_Item_Category));
            }
        Test.stopTest();
    }
}