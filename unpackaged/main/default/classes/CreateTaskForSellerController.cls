/*********************************************************************************************************************************
@ Class:          CreateTaskForSellerController
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        EPH-5671 Create Contact Quality Task in Seller Record when Status = red for managed sellers
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 13.03.2019 / Sovantheany Dim / Created the class.
				: 28.04.2022 / Loumang SENG / US-0011388 - Deactivate Contact Quality Task creation in the Seller Record
*********************************************************************************************************************************/

public class CreateTaskForSellerController {
	/***********************************************************************************************************************************
    @ Method:       createTask 
    @ Version:      1.0
    @ Author:       Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:      AC1) Create Task under seller record for seller which is account managed (category captain) and data quality in (red or yellow)
	@ The field to identify a managed seller, please refer to seller field BOB Managed = TRUE
    @ Parameter:    parentId: Account seller id
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        Map<String,Object>
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 13.03.2019 / Sovantheany Dim / Created the Method.
    ***********************************************************************************************************************************/
	public CreateTaskForSellerController(){}
	/*
    @AuraEnabled
    public static Map<String,Object> createTask(String parentId)
    { 
    	Map<String,String> mapResult = new Map<String,String>();
        ID TaskRecordTypeId=ApexUtil.getRecordTypeByName('Task', 'Standard_Task').ID;
    	try
    	{
    		Set<String> dataQuality = new Set<String>{'RED','YELLOW'};
    		Account acc = [select EBH_BOBManaged__c, Contact_Data_Quality__c from Account where id =: parentId and RecordType.DeveloperName='EBH_Seller'];
    		if(acc.EBH_BOBManaged__c == false || acc.Contact_Data_Quality__c == null || !dataQuality.contains(acc.Contact_Data_Quality__c.toUpperCase())) {
    			mapResult.put('status','info');mapResult.put('info','Task is created only when BoB Managed = TRUE and Contact Data Quality = RED or YELLOW');
    			return mapResult;
    		}
	    	String description = 'Bounced Email = RED (if applicable) and Invalid Phone Number = red (if applicable) \n'+
	'\"Atleast one of your managed contact for the seller had been indentified with either an invalid email or invalid phone number. We won\'t be able to reach the contact in our upcoming campaigns if this won\'t be updated!\" \n'+
	'Please check for the contact under related tab.\n'+
	'If it is a DWH Contact (the contact that is registered on eBay) please forward the following link to your contact and ask to update the phone and or email adress in my eBay.\n'+
	'DE Contacts: https://scgi.ebay.de/ws1/eBayISAPI.dll?ChangeRegistrationShow&guest=1 \n'+
	'UK Contacts:https://scgi.ebay.co.uk/ws1/eBayISAPI.dll?ChangeRegistrationShow&guest=1 \n'+
	'FR Contacts: https://scgi.ebay.co.fr/ws1/eBayISAPI.dll?ChangeRegistrationShow&guest=1 \n'+
	'IT Contacts: https://scgi.ebay.it/ws1/eBayISAPI.dll?ChangeRegistrationShow&guest=1 \n'+
	'ES: Contacts: https://scgi.ebay.es/ws1/eBayISAPI.dll?ChangeRegistrationShow&guest=1 \n';
			
			//create task
	    	Task task = new Task(Subject='Contact Quality Task is created',Status='Open',Priority='High',Description=description,WhatId=parentId,recordtypeid=TaskRecordTypeId);
	    	insert task;
	    	
	    	//Send Email to seller owner
	    	Account sellerAcc = [select OwnerId, Owner.Name,Owner.Email,Name,Id from Account where id =: parentId];
	    	List<Contact> contactRelated = [Select c.AccountId,c.RecordType.Name, c.RecordTypeId, c.Name, c.Incorrect_Phone_Number__c, c.Email_Bounced__c From Contact c where AccountId =: sellerAcc.Id and Contact_Data_Quality__c =: EBH_ConstantsUtility.RED_ACCOUNT];
	    	if(String.valueOf(sellerAcc.OwnerId).substring(0,15) != EBH_ConstantsUtility.INTEGRATION_USER_ID){
	    		EmailTemplate emailTemplate = [Select e.Subject, e.Name, e.HtmlValue, e.DeveloperName, e.Body From EmailTemplate e where DeveloperName =: EBH_ConstantsUtility.EMAILTEMPLATE_CONTACTDATAUPDATETASKSELLER]; 
	    		String subject = emailTemplate.Subject.replace('{!Account.Name}',sellerAcc.Name);
	    		
	    		String sellerUrl = URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Account/'+sellerAcc.Id+'/view';
	    		
	    		String body = emailTemplate.HtmlValue;
	    		body = body.replace('{!Account.Name}',sellerAcc.Name).replace('{!Account.OwnerFullName}',sellerAcc.Owner.Name).replace('{sellerUrl}',sellerUrl);
	    		if(!contactRelated.isEmpty()){
	    			Contact contact = contactRelated[0];
	    			body = body.replace('{Contact Name}',contact.Name).replace('{Email_Bounced__c}',String.valueOf(contact.Email_Bounced__c)).replace('{Incorrect_Phone_Number__c}',String.valueOf(contact.Incorrect_Phone_Number__c)).replace('{RecordTypeId}',contact.RecordType.Name);
	    		}
	    		
	    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				        mail.setToAddresses(new String[]{sellerAcc.Owner.Email});
				        mail.setSenderDisplayName('Hive Support');
				        mail.setSubject(subject);
				        mail.setBccSender(false);
				        mail.setUseSignature(false); 
				        mail.setHtmlBody(body);
				
				if(!Test.isRunningTest()){
					Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
					if (results[0].success) {
						mapResult.put('emailMessage',' And The email was sent successfully.');
					} else {
						mapResult.put('emailMessage',' But The email failed to send: '+ results[0].errors[0].message);
					}
				}        
	    	}
	    	
	    	mapResult.put('status','ok');
    	}catch(DMLException dex)
    	{
    		System.debug('<<<<error='+dex.getMessage());
    		mapResult.put('status','ko');mapResult.put('error',dex.getDmlMessage(0));mapResult.put('errorDetail',dex.getStackTraceString());
    	}
    	catch(Exception ex)
    	{
    		mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString());
    	}
    	return mapResult;
    }*/
}