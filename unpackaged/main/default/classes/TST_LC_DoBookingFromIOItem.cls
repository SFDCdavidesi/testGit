/**
 * @author: SRONG TIN
 * @createdDate: 04/July/2018
 * @description: 
 *  - test class of LC_DoBookingFromIOItem
 *  - coverage : 100%
 * @references: 
 *  - 
 * @changeLog:
 *
 */

 /*
@       Deprecated by       Mony Nou
@       Deprecated Date     14.07.2021
@       Reason: US-0009770 - These class is no longer used 
*/
@isTest
private class TST_LC_DoBookingFromIOItem {
    static testMethod void test_method(){
        LC_DoBookingFromIOItem obj = new LC_DoBookingFromIOItem();
    }   
    /*
    
    @TestSetup static void setup(){
        TST_DataGenerator.setupSimpleData(new Set<String>{'Account', 'Opportunity', 'Quote', 'QuoteLineItem','IO__c','IO_LineItem__c'});
        TestDARTCodeCoverage.sites = QueryUtil.queryRecords(Util.NS + 'Site__c');
        TestDARTCodeCoverage.createTestUser();
        TestDARTCodeCoverage.createCredential();
        TestDARTCodeCoverage.createTargetingHierarchy();
        TestDARTCodeCoverage.createAccount();
        TestDARTCodeCoverage.createAdvertiser();
        
        TestDARTCodeCoverage.createTargetingKVHierarchy();
        TestDARTCodeCoverage.createTargetingKVHierarchy();
        TestDARTCodeCoverage.login = TST_DataGenerator.generateAdServerLogin();

        insert TestDARTCodeCoverage.login;
        TestDARTCodeCoverage.io = (IO__c) QueryUtil.queryRecords(Util.NS + 'IO__c','ID<>null limit 1', new Set<String>{'Owner.Name', Util.NS + 'Advertiser__r.Name'}, new Set<String>()).get(0);
    }
    
	static testMethod void testDoBooking(){
        Test.startTest();
            TestDARTCodeCoverage.IOline = (IO_LineItem__c ) QueryUtil.queryRecords(Util.NS + 'IO_LineItem__c', 'Id<> null limit 1', DFPController.DFP_IO_ADDITIONAL_FIELD, new Map<String,Object>()).get(0);
            RemoteResponse response = LC_DoBookingFromIOItem.doBookingFromIOItem(TestDARTCodeCoverage.IOline.Id);
            System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_OK);
            RemoteResponse responseErr = new RemoteResponse();
            
            Boolean isError = false;
            try{
                responseErr = LC_DoBookingFromIOItem.doBookingFromIOItem(TestDARTCodeCoverage.IOline.Id);
            }catch(Exception e){
                isError = true;
            }
            System.assert(!isError); 
        Test.stopTest();
	}
    */
}