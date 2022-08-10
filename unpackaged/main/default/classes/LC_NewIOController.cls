public with sharing class LC_NewIOController {
    public LC_NewIOController() {}
	/*@AuraEnabled
	public static RemoteResponse newIOFromQuote(Id quoteId) {
		RemoteResponse response = new RemoteResponse();
		
		try {
            
            if(!Util.hasPermission('New_IO')){
                response.statusCode = RemoteResponse.STATUSCODE_ERROR;
                response.message = Label.ERR_NO_PERMISION_CREATE_IO;
                return response;
            }
            
			// create IO from Quote...
			Map<String, Object> checkResult = checkQuoteBeforeCreateIo(quoteId);
            if((Boolean)checkResult.get('isValidated')){
                Id ioId = GW_IO.createIOFromQuote(quoteId);
                response.content = ioId;
                response.statusCode = RemoteResponse.STATUSCODE_OK;
            }else{
                response.content = checkResult;
                response.statusCode = RemoteResponse.STATUSCODE_ERROR;
                response.message = String.valueOf(checkResult.get('errMsg'));
            }
			
    	} catch(Exception e) {
    		response = new RemoteResponse(e.getMessage(), RemoteResponse.STATUSCODE_ERROR);
    	}
		return response;
	}
    private static Map<String, Object> checkQuoteBeforeCreateIo(Id qId){
        Map<String, Object> res = new Map<String, Object>{'isValidated'=> true};
        for(Quote q : [SELECT Id, Status, IO__c FROM Quote WHERE Id =: qId]){
            if(q.Status != Label.QUOTE_STATUS_APPROVED){
                res.put('isValidated', false);
                res.put('errMsg', Label.ERR_PLS_APPROVE_QUOTE);
            }else if(String.isNotBlank(q.IO__c)){
                res.put('isValidated', false);
                res.put('errMsg', Label.ERR_QUOTE_ALREADY_LINKED);
            }
        }
        return res;
    }*/
}