public with sharing class LC_AddPricebook2Quote {
	
	@AuraEnabled
	public static String updateQuoteField(String quoteId, String pricebookId) {
		Id priceBId = Id.valueOf(pricebookId);
		try {
			update new Quote(id = quoteId, Pricebook2Id = priceBId) ;

		} catch (Exception e) {System.debug(LoggingLevel.Error, 'ERROR ' + e);AuraHandledException auraError = new AuraHandledException(e.getMessage() + e.getStackTraceString());auraError.setMessage(e.getMessage() + e.getStackTraceString());throw auraError;}

		return 'SUCCESS';
	}

/*****************************************************************************************************************************
@ Method:   getPricebookData
@ Author: 	Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:	US-0009102 - [Ads 2020] Product Config - Roles and Pricebooks
------------------------------------------------------------------------------------------------------------------------------
@ Change history: US-0009102 23.02.2021 / Sophal Noch / Modify method
*****************************************************************************************************************************/    
	@AuraEnabled
	public static List<Pricebook2> getPricebookData(String searchName) {
		
		List<Pricebook2> allowedPricebook = new List<Pricebook2>();
		try {

			List<Pricebook2> pricebook = new List<Pricebook2>();

             if(String.isNotBlank(searchName)){
                pricebook = [SELECT Id, Name FROM Pricebook2 WHERE Name LIKE : '%'+ searchName +'%'];
            }else {
            	pricebook = [SELECT Id, Name FROM Pricebook2];
            }

			Set<Id> pricebookIDs = new Set<Id>();
			for(Pricebook2 book : pricebook){ pricebookIDs.add(book.Id); }

			List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, 
			HasDeleteAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId IN: pricebookIDs];

			map<Id,boolean> accessMap = new map<Id,boolean>();

			for(UserRecordAccess recAccess : listUserRecordAccess){
				accessMap.put(recAccess.RecordId, recAccess.HasReadAccess);
			}

			for(Pricebook2 book : pricebook){
				if(accessMap.get(book.Id)){
					allowedPricebook.add(book);
				}
			}


        } catch (Exception e) {System.debug(LoggingLevel.Error, 'ERROR ' + e); AuraHandledException auraError = new AuraHandledException(e.getMessage() + e.getStackTraceString()); auraError.setMessage(e.getMessage() + e.getStackTraceString()); throw auraError;}

        return allowedPricebook;
	}
}