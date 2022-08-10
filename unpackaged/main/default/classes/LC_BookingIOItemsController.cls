/*
@	Deprecated by       Sophal Noch
@	Deprecated Date     29.09.2021
@	Reason: US-0008398 The class is no longer used.
*/
public with sharing class LC_BookingIOItemsController {

    public LC_BookingIOItemsController() {}

    // // public static String IO_RT_DIRECT = Label.IO_RECORDTYPEDEVNAME_DIRECT;
    // // public static String IO_RT_PROGRAMMATIC = Label.IO_RECORDTYPEDEVNAME_PROGRAMMATIC;

    // public static RemoteResponse initializeDataIO(String recordId) {

    //     RemoteResponse rrs = new RemoteResponse();
    //     Map<String, Object> res = new Map<String, Object> ();

    //      // Sophal:01/03/2021:US-0009134 disable for code coverage

    //     // try {
    //     //     if (!Util.hasPermission('Booking')) {
    //     //         rrs.statusCode = RemoteResponse.STATUSCODE_OK;
    //     //         rrs.validationMsg = 'You don\'t have permission to do DFP booking!';
    //     //         return rrs;
    //     //     }
    //     //     //MN-27122019
    //     //     for (IO__c io: [SELECT RecordTypeId, RecordType.DeveloperName, Dually_Signed_IO__c, Buyer_Accepted__c, IO_Status__c FROM IO__c WHERE Id =: recordId]) {
    //     //         if ((io.RecordTypeId == null || io.RecordType.DeveloperName == IO_RT_DIRECT) && !io.Dually_Signed_IO__c) {
    //     //             rrs.statusCode = RemoteResponse.STATUSCODE_OK;
    //     //             rrs.validationMsg = 'Dually Signed IO is required to do booking!';
    //     //             return rrs;
    //     //         } else if (io.RecordTypeId != null && io.RecordType.DeveloperName == IO_RT_PROGRAMMATIC && (io.IO_Status__c != 'Approved' || !io.Buyer_Accepted__c)) {
    //     //             rrs.statusCode = RemoteResponse.STATUSCODE_OK;
    //     //             rrs.validationMsg = 'You cannot book line items until the IO is approved or Buyer has Accepted.';
    //     //             return rrs;
    //     //         }
    //     //     }
            
    //     //     /*for(IO__c io : [select id from IO__c where Id = :recordId and Dually_Signed_IO__c = false]) {
    //     //         rrs.statusCode = RemoteResponse.STATUSCODE_ERROR;
	//     //         rrs.message = 'Dually Signed IO is required to do booking!';
	//     //         return rrs;
    //     //     }*/
                
    //     //     res.put('lstLineItem', [SELECT Id,
    //     //         Name, Ad_Id__c, IsPendingDfpPush__c,
    //     //         Quantity__c,
    //     //         SalesPriceNet__c,
    //     //         from_Date__c,
    //     //         Roll_up_Summary_Total_Quantity__c,
    //     //         Rollup_Summary_Total_Price__c,
    //     //         Total_Price__c,
    //     //         until_Date__c,
    //     //         Product__r.Name
    //     //         // ,Product__r.Billing_Category__c // Sophal:01/03/2021:US-0009134
    //     //         FROM IO_LineItem__c
    //     //         WHERE IO__c =: recordId AND (Ad_Id__c = NULL OR IsPendingDfpPush__c = TRUE)
    //     //     ]);

    //     //     rrs.statusCode = RemoteResponse.STATUSCODE_OK;
    //     //     rrs.content = res;
    //     //     rrs.message = 'successed';
    //     // } catch (Exception e) {
    //     //     rrs.statusCode = RemoteResponse.STATUSCODE_ERROR;
    //     //     rrs.message = e.getMessage();
    //     //     rrs.debug = e.getMessage() + ':' + e.getStackTraceString();
    //     // }
    //     return rrs;
    // }

    // public static RemoteResponse bookingLineItemIO(String recordId) {
    //     RemoteResponse rrs = new RemoteResponse();

    //     // Sophal:01/03/2021:US-0009134 disable for code coverage
    //     // try {
    //     //     IO_LineItem__c IOline = (IO_LineItem__c) QueryUtil.queryRecord(recordId, new Set<String> {
    //     //         Util.NS + 'IO__r.' + Util.NS + 'Ad_Campaign__c'
    //     //     });
    //     //     boolean isRebooking = IOline.Ad_Id__c != null;
    //     //     DFPController.initContext(recordId, 'IO');
    //     //     rrs = DFPController.doBooking(recordId, 'IO');
    //     //     if (rrs.statusCode == RemoteResponse.STATUSCODE_OK) {
    //     //         IOline.IsPendingDfpPush__c = false;
    //     //         update IOline;
    //     //     }
    //     //     if (isRebooking && rrs.statusCode == RemoteResponse.STATUSCODE_OK) {
    //     //         new GW_IO.RevenueScheduleCreator(IOline).createNonExisting();
    //     //     }
    //     // } catch (Exception e) {
    //     //     rrs.statusCode = RemoteResponse.STATUSCODE_ERROR;
    //     //     rrs.message = e.getMessage();
    //     //     rrs.debug = e.getMessage() + ':' + e.getStackTraceString();
    //     // }
    //     return rrs;
    // }
}