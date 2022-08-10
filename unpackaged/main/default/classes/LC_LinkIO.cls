/*
@	Deprecated by       Sophal Noch
@	Deprecated Date     29.09.2021
@	Reason: US-0008418 The class is no longer used.
*/
public with sharing class LC_LinkIO {

	public LC_LinkIO() {}
	
	// @AuraEnabled
	// public static RemoteResponse getData(String recordId) {
	// 	RemoteResponse response = new RemoteResponse();
	// 	try {
	// 		Id recId= Id.valueOf(recordId);
	// 		String ioApprovedStatus = Label.IO_STATUS_APPROVED;	
	// 		// currently linkIO can be from Opp Object and quote Object
			
    //         if(!Util.hasPermission('Revision_IO')){
    //             response.statusCode = RemoteResponse.STATUSCODE_ERROR;
    //             response.message = Label.ERR_NO_PERMISION_REVISION_IO;
    //             return response;
    //         }

	// 		if( recId.getSobjectType() == Schema.Opportunity.SobjectType ){
	// 			Opportunity opp = (Opportunity) QueryUtil.queryRecord(recId);
    //             if(String.isNotBlank(opp.IO__c)){
    //                 response.statusCode = RemoteResponse.STATUSCODE_ERROR;
    //                 response.message = Label.ERR_REVISION_IO_OPP_ALREADY_LINKED;
    //                 return response;
    //             }
    //             /*
    //             else if(!Label.OPP_TYPE_DIRECT_REVISION.equalsIgnoreCase(opp.Type)){
    //                 response.statusCode = RemoteResponse.STATUSCODE_ERROR;
    //                 response.message = Label.ERR_REVISION_IO_APPLICABLE;
    //                 return response;
    //             }
    //             */
	// 			Set<Id> agencyIds = new Set<Id>();
	// 			for(Advertiser_Agency_Relationship__c advAgencyRel:(List<Advertiser_Agency_Relationship__c>) QueryUtil.queryRecords(Util.NS+'Advertiser_Agency_Relationship__c',Util.NS+'Advertiser__c = :value1', new Map<String,Object>{'value1'=>opp.AccountId})){
	// 				agencyIds.add(advAgencyRel.Agency__c);
	// 			}
	// 			response.contents = QueryUtil.queryRecords(Util.NS+'IO__c', Util.NS+'Agency__c IN:value1 or '+Util.NS+'Advertiser__c =:value2', new Set<String> {Util.NS+'Advertiser__r.Name',Util.NS+'Agency__r.Name'}, new Map<String,Object>{'value1'=>agencyIds,'value2'=> opp.AccountId});
	// 			response.statusCode = RemoteResponse.STATUSCODE_OK;
	// 			return response;
	// 		}

	// 		for(Quote quote : [SELECT Id,Name, Opportunity.Agency__c FROM Quote WHERE Id = :recId and Opportunity.Agency__c != null]) {
	// 			response.contents = QueryUtil.queryRecords(Util.NS+'IO__c', Util.NS+'Agency__c=:value1 and '+Util.NS+'IO_Status__c<>\'' +ioApprovedStatus+ '\' ', new Set<String> {Util.NS+'Advertiser__r.Name', Util.NS+'Agency__r.Name'}, new Map<String,Object>{'value1'=>quote.Opportunity.Agency__c});
	// 		}
			
	// 		response.statusCode = 0;
	// 	} catch(Exception e) {
	// 		response = new RemoteResponse(e.getMessage(), 1);
	// 	}
		
	// 	return response;
	// }
	
	// @AuraEnabled
	// public static RemoteResponse linkFromQuoteToIO(String oneIoId, String recordId) {
	// 	RemoteResponse response = new RemoteResponse();
	// 	try {
	// 		//throw new ExceptionGroup.customException('sdsds');
	// 		Id ioId = Id.valueOf(oneIoId);
	// 		Id recId= Id.valueOf(recordId);

	// 		// currently linkIO can be from Opp Object and quote Object
	// 		if( recId.getSobjectType() == Schema.Opportunity.SobjectType ){
	// 			GW_IO.revisionIO(ioId, recId);
	// 			return new RemoteResponse('Successfully Link', RemoteResponse.STATUSCODE_OK);
	// 		}

	// 		//GW_IO.linkQuoteToIO(ioId,recId);
    //         response.statusCode = 0;
    //         response.message = 'Successfully Link';
            
    // 	} catch(Exception e) {
    // 		response = new RemoteResponse(e.getMessage(), 1);
    // 	}
	// 	return response;
	// }
}