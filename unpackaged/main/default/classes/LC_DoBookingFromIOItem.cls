/*
@       Deprecated by       Mony Nou
@       Deprecated Date     14.07.2021
@       Reason: US-0009770 - These class is no longer used 
*/
public with sharing class LC_DoBookingFromIOItem {
    /*
	@AuraEnabled
	public static RemoteResponse doBookingFromIOItem(String ioItemId) {

		RemoteResponse responseObj = new RemoteResponse();
		try {
             
             Id ioLineItemId = Id.valueOf(ioItemId);
             IO_LineItem__c IOline = (IO_LineItem__c) QueryUtil.queryRecord(ioLineItemId, new Set<String>{Util.NS + 'IO__r.' + Util.NS + 'Ad_Campaign__c'});
             boolean isRebooking = IOline.Ad_Id__c!=null;
             responseObj = DFPController.doBooking(ioLineItemId);
             if(isRebooking && responseObj.statusCode == RemoteResponse.STATUSCODE_OK) {
             	new GW_IO.RevenueScheduleCreator(IOline).createNonExisting();
             }
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'ERROR ' + e);
            AuraHandledException auraError = new AuraHandledException(e.getMessage() + e.getStackTraceString());
            auraError.setMessage(e.getMessage() + e.getStackTraceString());
            throw auraError;
        }
		return responseObj;
	}
    */
}