/*
@       Deprecated by       Mony Nou
@       Deprecated Date     14.07.2021
@       Reason: US-0009770 - These class is no longer used 
*/
public with sharing class LC_CreateMediaPlanController {
    /*
	@AuraEnabled
	public static RemoteResponse createMediaPlan(Id oppId) {
		RemoteResponse response;
		try {
            if(Util.hasPermission('Create_Media_Plan')){
            	for(Opportunity o : [select IO_Paper__c, PMP_Subtype__c, RecordType.DeveloperName from Opportunity where id =:oppId]) {
            		if(String.isBlank(o.IO_Paper__c) && o.RecordType.DeveloperName != Label.OPP_RECORDTYPEDEVNAME_PROGRAMMATIC) {
            			response = new RemoteResponse(Label.ERR_OPP_TERMS_REQUIRED_ON_OPP, RemoteResponse.STATUSCODE_ERROR);
            			return response;
            		} else if (Label.OPP_RECORDTYPEDEVNAME_PMP.equalsIgnoreCase(o.RecordType.DeveloperName) && !Label.OPP_PMPSUBTYPE_PREFERRED.equalsIgnoreCase(o.PMP_Subtype__c)) {
            		    response = new RemoteResponse(Label.ERR_NO_PERMISSION_CREATE_MEDIA_PLAN, RemoteResponse.STATUSCODE_ERROR);
            		    return response;
            		}
            	}
            	Map<String, Object> results = GW_Opportunity.createMediaPlan(oppId);
	            if(results.containsKey('Id')){
	            	response = new RemoteResponse('', RemoteResponse.STATUSCODE_OK, new Map<String, Object> {'Id' => results.get('Id')});
	            } else {
	            	response = new RemoteResponse(String.valueOf(results.get('Message')), RemoteResponse.STATUSCODE_ERROR);
	            }
            } else {
            	response = new RemoteResponse(Label.ERR_NO_PERMISSION_CREATE_MEDIA_PLAN, RemoteResponse.STATUSCODE_ERROR);
            }
    	} catch(Exception e) {
    		response = new RemoteResponse(e.getMessage(), RemoteResponse.STATUSCODE_ERROR);
    	}
		return response;
	}
	*/
}