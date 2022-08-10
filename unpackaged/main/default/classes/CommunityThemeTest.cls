/**
 * @Description Test unit for cover code in CommunityThemeCltr class
 * @date        09/09/2021
 * @author      Samnang MUONG
 */

@isTest
private class CommunityThemeTest {
    
    @testSetup
    static void setup(){       

        //create an account
        Account acc = new Account( Name = 'TestAccount', EBH_StoreSubscription__c = 'Platinum' );
        insert acc; 
        
        Contact con = new Contact(FirstName='test fn', LastName='test ln', AccountId=acc.Id);
        insert con;
        
           
                                    

    }
    
    @isTest static void testInitCode() {
        Test.startTest();
        CommunityThemeCltr.initLocalCode();
        Test.stopTest();
    }

    @isTest static void testVisibleGBDTab() {
        Test.startTest();
        try{
           CommunityThemeCltr.visibleGrowthBasedDiscountsTab(); 
        }catch (Exception e){
            
        }
        
        Test.stopTest();
    }


}