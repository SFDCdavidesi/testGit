/*********************************************************************************************************************************
@ Class:          ForwardToSellerController
@ Version:        1.0
@ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:        Controller for Aura: ForwardToSeller, SourcingOppList
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 19.07.2019 / Vadhanak Voun / Created the class.
----------------------------------------------------------------------------------------------------------------------------------
@ Class:          ForwardToSellerController
@ Version:        2.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        US-0005891
@				  As a...
@ 			      Any User
@ 			      Want to...
@ 			      select all Seller to Product records in Inventory Diagnostic
@ 			      So that...
@ 			      I do not have to go through all list views if I want to send all records to a seller
@ 			      Description
@ 			      AC1:
@ 			      Given that I am Any User
@ 			      When I got to Inentory Diagnostic 
@ 			      I am able to see "Select All" button 
@ 			      Than enables me to select all records that fit the filter criteria
@ 			      *Currently I am able to select only those record that are shown in the list view
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 05.07.2020 / Sophal Noch / Modified the method.
*********************************************************************************************************************************/
public without sharing class ForwardToSellerController {
    
	public final static String SOQL_SELLER_TO_PRODUCT = 'Select Price_Gap_P_Color__c,Product__r.Product_Link_2_auto__c,Product__r.Product_Link_2__c,Price_Main_Competitor__c,eBay_Item_Link_auto_h__c,eBay_Item_Link_auto__c,Product__r.Update_Date__c,Update_Date__c,Price_Difference_seller_vs_competitor__c,Product__r.Vertical__c,Product__r.Name,Name,Product__r.Price_competitor_2__c,Category_L3__c,Brand__c,Product_Brand__c, Seller__c,Seller__r.Name,Listing_ID__c,eBay_Link__c,EPID__c,Product__r.Price_competitor__c,Product__r.eBay_Product_Link__c,Product__r.EAN__c,Product__r.Product_ID__c,Listing_Title__c,Take_Rate__c,Price_seller__c,Id From Seller_to_Product__c';
    //final static Integer ITEM_PER_VIEW = 3;//passing from component instead
    
    /*****************************************************************************************************************************
	@ Method:   apexInit
	@ Version:  1.0
	@ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
	@ Purpose:  EPH-7701 Trading Engine. Initiating 1:1 communication
	@			 
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:      parentId: seller id
	------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 20.07.2019/ Vadhanak Voun / Created the  Method.
					09.03.2020/ Acmatac SEING / [US-0006326] EAN filter
	*****************************************************************************************************************************/

	private final static String ID_SELECTION_SOQL = 'Select Id From ';

    @AuraEnabled
    public static Map<String,Object> apexInit(String parentId)
    {
    	Map<String,Object> mapResult = new Map<String,Object>();
    	Set<String> setAccountIds = new Set<String>{parentId};
    	String soql_seller = EBH_ConstantsUtility.SOQL_ACCOUNT;
    	Account[] listSelelr = Database.query(soql_seller);
    	
    	mapResult.put('seller',listSelelr[0]);
    	mapResult.put('baseSOQL',EBH_ConstantsUtility.SOQL_SOPP);
    	
    	List<Schema.FieldSetMember> listSTPFieldsMeta = SObjectType.Seller_to_Product__c.FieldSets.ForwardToSellerListView.getFields();
    	String stpQuery = 'SELECT ';
    	List<Map<String,String>> listStpFields = new List<Map<String,String>>();
    	
    	Map<String,List<Map<String,String>>> mapPicklistVal = new Map<String,List<Map<String,String>>>();
    	
        for(Schema.FieldSetMember f : listSTPFieldsMeta) {
            stpQuery += f.getFieldPath() + ', ';
            listStpFields.add(new Map<String,String>{'label'=>f.getLabel(),'value'=>f.getFieldPath(),'type'=>f.getType()+''});
            
            if(f.getType() == Schema.DisplayType.Picklist) // || f.getType() == Schema.DisplayType.MultiPicklist
            {
            	Schema.DescribeFieldResult fdesc = f.getSObjectField().getDescribe();
            	for(Schema.PicklistEntry pkl: fdesc.getPicklistValues())
            	{
            		if(!mapPicklistVal.containsKey(f.getFieldPath()))
	            	{
	            		mapPicklistVal.put(f.getFieldPath(),new List<Map<String,String>>());
	            	}
	            	mapPicklistVal.get(f.getFieldPath()).add(new Map<String,String>{'label'=>pkl.getLabel(),'value'=>pkl.getValue()});
            	}

            	
            }
        }
        
        //NK:04/11/2019: CR: US-0015755. new field is formula text, but wanting to display picklist value for selection
        for(Schema.PicklistEntry pkl: Seller_to_Product__c.Competitive_Status_seller__c.getDescribe().getPicklistValues())
    	{
    		if(!mapPicklistVal.containsKey('Competitive_Status_Main_Competitor__c'))
        	{
        		mapPicklistVal.put('Competitive_Status_Main_Competitor__c',new List<Map<String,String>>());
        	}
        	mapPicklistVal.get('Competitive_Status_Main_Competitor__c').add(new Map<String,String>{'label'=>pkl.getLabel(),'value'=>pkl.getValue()});

		}
            	
        stpQuery += ' Id FROM Seller_to_Product__c ';
        mapResult.put('baseSOQLSTP',stpQuery);
        mapResult.put('stpFieldSet',listStpFields);
        mapResult.put('mapPicklistVal',mapPicklistVal);
        
        Set<String> setUser = new Set<String>{UserInfo.getUserId()};
        User currentUser =  Database.query(EBH_ConstantsUtility.SOQL_User);
        mapResult.put('currentUserEmail',currentUser.Email);
        
       // List<Contact> listContacts = Database.query(EBH_ConstantsUtility.SOQL_CONTACT +' Where AccountId=:parentId' );
        //mapResult.put('listContacts',listContacts);
        
    	mapResult.put('status','ok');
    	
    	return mapResult;
    }
    
     /*****************************************************************************************************************************
	@ Method:   apexCreateNorminatedItems
	@ Version:  1.0
	@ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
	@ Purpose:  US-0005908 Redirect Users to Custom Element (Inventory Diagnostic) for FVF Nomination
	@			replicated from: FinalValueFee_FVF_Handler.createNorminatedItem(). old story logic use text field on New page to populate selected STP ids
	@			new story, to create from custom component directly
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:      fvfId: fvfId, sellerToProductIds
	------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 12.12.2019/ Vadhanak Voun / Created the  Method.
	*****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> apexCreateNorminatedItems(String fvfId, String[] sellerToProductIds)
    {
    	Map<String,Object> mapResult = new Map<String,Object>();
    	//get FVF by the extId which is newly created from force.createRecord
    	String sWhere = ' Where Unique_Id__c =:fvfId';
    	Final_Value_Fee_FVF__c fvf = Database.query(EBH_ConstantsUtility.SOQL_FVF+sWhere); 
    	
    	List<Nominated_Item__c> lstNorminatedItem = new List<Nominated_Item__c>();
		for(String sellerToProductId :sellerToProductIds){
			 
			lstNorminatedItem.add(
				new Nominated_Item__c(Final_Value_Fee_FVF__c = fvf.Id,Inventory_Diagnostic__c = sellerToProductId)
			);
		}
    	 
    	if(!lstNorminatedItem.isEmpty())
    	{
    		try
    		{
    			mapResult.put('status','ok');
    			mapResult.put('fvfId',fvf.Id);
    			insert lstNorminatedItem;	
    		}catch(Exception ex)
    		{
    			mapResult.put('status','ko');mapResult.put('error',ex.getMessage());
    		}
    	}	
    	
    	return mapResult;
    }
    
    /*****************************************************************************************************************************
	@ Method:   apexContactList
	@ Version:  1.0
	@ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
	@ Purpose:  US-0015688 User Experience Improvements. Inventory Diagnostic. Restrict Contacts
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:      parentId: seller id
	------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 22.09.2019/ Vadhanak Voun / Created the  Method.
	*****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> apexContactList(String parentId)
    {
    	Map<String,Object> mapResult = new Map<String,Object>();
        List<UserContact> listContacts = new List<UserContact>() ;
        
        Set<String> setUser = new Set<String>{UserInfo.getUserId()};
    	User currentUser =  Database.query(EBH_ConstantsUtility.SOQL_User);
    	listContacts.add(new UserContact(currentUser.Id,currentUser.Name,currentUser.Email));
    	 
        for(Contact c: Database.query(EBH_ConstantsUtility.SOQL_CONTACT +' Where AccountId=:parentId' ))
        {
        	listContacts.add(new UserContact(c.Id,c.Name,c.Email));
        }  
        mapResult.put('listContacts',listContacts);
        
    	mapResult.put('status','ok');
    	return mapResult;
    }
     
    
    /*****************************************************************************************************************************
	@ Method:   apexContactAndSellerToProductInfo
	@ Version:  1.0
	@ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
	@ Purpose:  EPH-7701 Trading Engine. Initiating 1:1 communication
	@			 
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:      contactId: contact id to get detail. (input lookup from componet get only id, we need name here)
	------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 22.07.2019/ Vadhanak Voun / Created the  Method.
	@				: 28.10.2019/ Vadhanak Voun/ US-0015755 Inventory Diagnostic. Main Competitor
	@						%sum(seller to product records with competitive status (main competitor)= uncompetitive)% listings will be recommended for price optimization
	@						% sum(seller to product records with competitive status (main competitor)= out of stock)% listings will be recommended for restocking
	*****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> apexContactAndSellerToProductInfo(String contactId,String sellerToProductIds)
    {
    	Map<String,Object> mapResult = new Map<String,Object>();
    	String sWhere = ' Where Id =:contactId ';
    	
    	//Contact[] contacts = Database.query(EBH_ConstantsUtility.SOQL_CONTACT+sWhere);
    	//UserContact uCont =  findUserContact(contactId);
    	
    	List<String> listSellerToProduct = (sellerToProductIds+'').split(',');
    	
    	Integer sellerToProduct_Count =  String.isBlank(sellerToProductIds)?0:listSellerToProduct.size();
    	
    	String pkl_outOfStock = EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK;
    	String pkl_unCompete = EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN;
    	
    	String sWhereSTP_outofstock = ' Where Id IN:listSellerToProduct AND Competitive_Status_Main_Competitor__c =:pkl_outOfStock '; 
    	String sWhereSTP_uncompete = ' Where Id IN:listSellerToProduct AND Competitive_Status_Main_Competitor__c =:pkl_unCompete '; 
    	
    	String soql_arr = 'Select count(Id) rowCount From Seller_to_Product__c ';
    	AggregateResult aResult_outofstock = Database.query(soql_arr + sWhereSTP_outofstock);
    	AggregateResult aResult_uncompete = Database.query(soql_arr + sWhereSTP_uncompete);
    	 
    	//mapResult.put('contact',uCont);
    	mapResult.put('sellerToProduct_Count',sellerToProduct_Count);
    	mapResult.put('sellerToProduct_Uncompete',aResult_uncompete.get('rowCount')); 
    	mapResult.put('sellerToProduct_OutOfStock',aResult_outofstock.get('rowCount'));
    	
    	mapResult.put('status','ok');
    	
    	return mapResult;
    } 
    
     //mapping Customer.RevRollup to the correct email template name
    static Map<String,String> mapTemplateNameByCountry = new Map<String,String>
    {
    	'DE'=>'TradingEngine_DE',
    	'UK'=>'TradingEngine_UK',
    	'ES'=>'TradingEngine_ES',
    	'IT'=>'TradingEngine_IT'
    };
    
    
    /*****************************************************************************************************************************
	@ Method:   apexGetEmailTemplate
	@ Version:  1.0
	@ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
	@ Purpose:  EPH-7701,7704 Trading Engine. Initiating 1:1 communication
	@			"DE_Trading Engine text" if Customer.RevRollup= DE
	@			"UK_Trading Engine text" if Customer.RevRollup= UK
	@			"IT_Trading Engine text" if Customer.RevRollup= IT
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:    sellerId:  
	------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 23.07.2019/ Vadhanak Voun / Created the  Method.
	*****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> apexGetEmailTemplate(String sellerId,String contactId)
    {
    	Map<String,Object> mapResult = new Map<String,Object>();
    	  
    	Set<String> setAccountIds = new Set<String>{sellerId};
    	String soql_seller = EBH_ConstantsUtility.SOQL_ACCOUNT;
    	Account seller = (Account)Database.query(soql_seller)[0];
    	Set<String> setUser = new Set<String>{UserInfo.getUserId()};
    	User currentUser =  Database.query(EBH_ConstantsUtility.SOQL_User);
    	UserContact uCont =  findUserContact(contactId);
    	
    	
    	String templateName = mapTemplateNameByCountry.containsKey(seller.EBH_RevRollup__c)?mapTemplateNameByCountry.get(seller.EBH_RevRollup__c):mapTemplateNameByCountry.get('UK'); //default UK
   		List<EmailTemplate>  emailTemplates = Database.query(EBH_ConstantsUtility.SOQL_BOB_EMAIL_TEMPLATE);
   		
    	String subject = emailTemplates[0].Subject;
    	String htmlBody =  emailTemplates[0].HtmlValue;
    	
    	htmlBody = doMergeFields(seller,currentUser,uCont,htmlBody);
    	 
    	 
		List<String> listOrgEmail = new List<String>();
		listOrgEmail.add(JSON.serialize(new JOption(currentUser.Name +' <'+ currentUser.Email+'>','')));
		for(OrgWideEmailAddress owe : Database.query(EBH_ConstantsUtility.SOQL_ORG_EMAIL))
		{
			listOrgEmail.add(JSON.serialize(new JOption(owe.DisplayName +' <'+ owe.Address+'>',owe.Id)));
		}

    	mapResult.put('emailBody',htmlBody);
    	mapResult.put('emailSubject',subject);
    	mapResult.put('listOrgEmail',listOrgEmail);
		
    	mapResult.put('status','ok');
    	
    	return mapResult;
    }
    
    /*****************************************************************************************************************************
	@ Method:   apexSendEmailComplete
	@ Version:  1.0
	@ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
	@ Purpose:  EPH-7701,7704 Trading Engine. Initiating 1:1 communication
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:    sellerId:  
	------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 23.07.2019/ Vadhanak Voun / Created the  Method.
	@				: 09.08.2019/ Vadhanak Voun/ EPH-7950: added more column to SOPP xls
	@				: 20.08.2019/ Vadhanak Voun/ EPH-7932 Trading Engine. 1:1 communication. UK version
	@				: 31.10.2019/ Vadhanak Voun/ US-0018789 Exclude yourself from CC for Inventory Diagnostic
	@ 				: 04.March.2020/ Acmatac SEING / [US-0000787] Remove value "In Queue" from Targeting Engine Communication Task.
	*****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> apexSendEmailComplete(String sellerId,String contactId,String ccAddress,String subject2,String htmlBody2,String sellerToProductIds,Map<String,String> mapSelectedSOPP,String orgWideMailId)
    {
    	Map<String,Object> mapResult = new Map<String,Object>();
    	try
    	{
	    	Set<String> setAccountIds = new Set<String>{sellerId};
	    	String soql_seller = EBH_ConstantsUtility.SOQL_ACCOUNT;
	    	Account seller = (Account)Database.query(soql_seller)[0];
	    	
	    	Set<String> setUser = new Set<String>{UserInfo.getUserId()};
	    	User currentUser =  Database.query(EBH_ConstantsUtility.SOQL_User);
	    	
	    	//String sWhereContact = ' Where Id =:contactId ';
    		//Contact[] contacts = Database.query(EBH_ConstantsUtility.SOQL_CONTACT+sWhereContact);
    		UserContact uCont =  findUserContact(contactId);
    	 	if(String.isBlank(uCont.Email))
    	 	{
    	 		mapResult.put('status','ko');
    	 		mapResult.put('error','Contact has no email!!!');
    	 		return mapResult;
    	 	}
    	 
	    	List<String> listSellerToProduct = sellerToProductIds.split(',');
	    	String sWhere = ' Where Id IN:listSellerToProduct';
	    	
	    	
	    	List<ExcelGenerator.xSheet> listSheets = new List<ExcelGenerator.xSheet>();
	    	
	    	//Seller To Product collumn headers
	    	List<String> listRowSTP = getColumnHeaders('STP',seller.EBH_RevRollup__c);
	    	
	    	List<List<String>> listRowSTP_all = new List<List<String>>{listRowSTP};
	    	
	    	for(Seller_to_Product__c stp: Database.query(SOQL_SELLER_TO_PRODUCT + sWhere))
	    	{
				List<String> listRow = new List<String>();
				for(String fName : getListFieldName('STP',seller.EBH_RevRollup__c))
				{
					//NK:03/08/2020:US-0005933
					String val = getFieldValue(fName,stp,seller.EBH_RevRollup__c) + ( fName=='Price_Difference_seller_vs_competitor__c' ? getFontColor(stp.Price_Gap_P_Color__c):'' );
					listRow.add(val);
				}
				listRowSTP_all.add(listRow);
					
	    	}
	    	//xls for Seller To Product
	    	ExcelGenerator.xSheet sheetSTP = new ExcelGenerator.xSheet(getSheetName('STP',seller.EBH_RevRollup__c),listRowSTP_all);//('Sortimentsinformationen L3 Kat',listRowSTP_all);
	    	listSheets.add(sheetSTP);
	    	
	    	ExcelGenerator genSTP = new ExcelGenerator(currentUser.Name,listSheets); 
	    	
    		genSTP.generateWorkBook();
    		
    		List<Messaging.EmailFileAttachment> listAtt = new List<Messaging.EmailFileAttachment>();
    		
    		Messaging.EmailFileAttachment fileAttachmentSTP = new Messaging.EmailFileAttachment();
	        fileAttachmentSTP.setBody(Blob.valueOf(genSTP.getWorkbookXML()));
	        fileAttachmentSTP.setFileName(getAttName('STP',seller));//('SellerToProducts.xls');  
	        listAtt.add(fileAttachmentSTP);  
        	
        	//xls for selected Sourcing Opportunity
        	if(!mapSelectedSOPP.isEmpty())
        	{
        		//header Sourcing Opportunity
        		List<List<String>> listRowSOPP_all = new List<List<String>>{
									getColumnHeaders('SOPP',seller.EBH_RevRollup__c)
								};
        		 
		    	Set<String> setSOPPId = mapSelectedSOPP.keySet();
		    	String sWhereSOPP = ' Where Id IN :setSOPPId ';	
		    	for(Sourcing_Opportunity__c sopp: Database.query(EBH_ConstantsUtility.SOQL_SOPP + sWhereSOPP))
		    	{
					List<String> listRow = new List<String>();
					for(String fName : getListFieldName('SOPP',seller.EBH_RevRollup__c))
					{
						listRow.add(getFieldValue(fName,sopp,seller.EBH_RevRollup__c));
					}
					listRowSOPP_all.add(listRow);
		    	}
	    	
        		List<ExcelGenerator.xSheet> listSheetsSOPP = new List<ExcelGenerator.xSheet>();
        		ExcelGenerator.xSheet sheetSOPP = new ExcelGenerator.xSheet(getSheetNameSOPP('SOPP',seller.EBH_RevRollup__c),listRowSOPP_all); //('Inventarlücken',listRowSOPP_all)
        		
		    	listSheetsSOPP.add(sheetSOPP);
		    	
		    	ExcelGenerator genSOPP = new ExcelGenerator(currentUser.Name,listSheetsSOPP); 
		    	
	    		genSOPP.generateWorkBook();
	    		
	    		Messaging.EmailFileAttachment fileAttachmentSOPP = new Messaging.EmailFileAttachment();
		        fileAttachmentSOPP.setBody(Blob.valueOf(genSOPP.getWorkbookXML()));
		        fileAttachmentSOPP.setFileName('SourcingOpportunity.xls');  
		        listAtt.add(fileAttachmentSOPP);  
		        
	        
        	}
        
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setToAddresses(new String[]{uCont.Email});
	        //system.debug('>>>>>>>>>ccAddress: '+ccAddress);
	        //NK:31/10/2019: US-0018789
	        if(String.isNotBlank(ccAddress))
	        {
	        	mail.setCcAddresses(ccAddress.split(',')); //NK:27/08/2019: EPH-7938:AC2
	        }
	        
	        mail.setSubject(subject2);
	        mail.setBccSender(false);
	        mail.setUseSignature(false); 
	        mail.setHtmlBody(htmlBody2);
    		mail.setFileAttachments(listAtt);
    		
    		if(String.isNotEmpty(orgWideMailId))
    		{
    			mail.setOrgWideEmailAddressId(orgWideMailId);
    		}else
    		{
    			mail.setSenderDisplayName(currentUser.Name+'');
    		}
    		
    		Integer totalCount = listSellerToProduct.size() + mapSelectedSOPP.size();
    		logTask(sellerId,uCont,currentUser.Name,totalCount+'',listAtt);
    		
    		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}); 
    		
    		apexCreateNominatedItems(sellerId,uCont.Id+'',uCont.Email,sellerToProductIds,mapSelectedSOPP);
    		
	    	mapResult.put('status','ok');
    	}
    	catch(Exception ex)
    	{
    		mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString());
    	}
    	
    	return mapResult;
    }
	
	/*****************************************************************************************************************************
	@ Method:   getFontColor
	@ Version:  1.0
	@ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
	@ Purpose:  US-0005933 - Inventory Diagnostic. Keep Color coding in the attachment
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:    priceGap_P_collor:  Price_Gap_P_Color__c
	------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 04.08.2020/ Vadhanak Voun / Created the  Method.
	*****************************************************************************************************************************/
	private static String getFontColor(String priceGap_P_collor)
	{
		if(priceGap_P_collor.contains('red'))
		{
			return ExcelGenerator.STYLE_SEP +'f_red';
		}else if(priceGap_P_collor.contains('green'))
		{
			return ExcelGenerator.STYLE_SEP +'f_green';
		}
		return '';
	}

	/* 
		@ Change history: 04.March.2020/ Acmatac SEING / [US-0000787] Remove value "In Queue" from Targeting Engine Communication Task.
	*/
    private static void logTask(String sellerId,UserContact cont,String userName,String totalCount,List<Messaging.EmailFileAttachment> listMailAtt)
    {
    	ID standardTaskId = ApexUtil.getRecordTypeByName('Task', 'Standard_Task').ID;
    	Task t = new Task(
    		WhatId = sellerId,
    		Subject = 'Targeting Engine communication',
    		Description = userName+' sent Targeting Engine communication to '+cont.Name+'\nTotal number of listings/products communicated: '+totalCount+'.\nDetails attached',
    		Status = 'Completed',
    		OwnerId = UserInfo.getUserId(),
    		RecordtypeId = standardTaskId,
			WhoId = cont.id.startsWith('005')?null:cont.Id, //contact,lead
			ActivityDate = System.today(), //Due Date
			EBH_DMC__c = true,
			Task_Completed_Date__c = System.today(),
			EBH_ResponseCode__c = 90,
			Log_Task__c = true
    	);
    	insert t;
    	
    	List<Attachment> listAtt = new List<Attachment>();
    	for(Messaging.EmailFileAttachment att: listMailAtt)
    	{
    		listAtt.add(new Attachment(
    			Body = att.getBody(),
    			Name = att.getFileName(),
    			ParentId = t.Id
    		));
    	}
   		if(!listAtt.isEmpty())
   		{
   			insert listAtt;
   			
   		}	
    }
     
    private static String doMergeFields(Account seller,User currentUser,UserContact uCont,String htmlBody)
    {
    	return htmlBody.replace('{!SellerName}',seller.Name+'')
    						.replace('{!ContFirstName}',uCont.name+'')
    						.replace('{!CurrentUserName}',currentUser.Name+'')
    						.replace('{!CurrentUserFirstName}',currentUser.FirstName+'')
    						.replace('{!CurrentUserLastName}',currentUser.LastName+'');
    }
   
 	/*****************************************************************************************************************************
	@ Method:   apexCreateNominatedItems
	@ Version:  1.0
	@ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
	@ Purpose:  EPH-7702 Trading Engine. 1:1 communication. Creation of Nominated Item records for future reporting
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:    sellerId:  
	------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 24.07.2019/ Vadhanak Voun / Created the  Method.
	@				: 07.10.2019/ Vadhanak Voun/ disabled @future: conflict with new story: US-0015722 Enable
	@							/ assignPermset_NominatedItemEdit() use future to assign permission set (mixed dml)
	*****************************************************************************************************************************/
    //@future
    private static void apexCreateNominatedItems(String sellerId,String contactId,String contEmail,String sellerToProductIds,Map<String,String> mapSelectedSOPP)
    { 
    	RecordType rec_fvf_sellercom = ApexUtil.getRecordTypeByName('Final_Value_Fee_FVF__c','Seller_Communication');
    	Final_Value_Fee_FVF__c fvf = new Final_Value_Fee_FVF__c(
    		RecordTypeId = rec_fvf_sellercom.Id,
    		Contact_Person__c = contactId.startsWith('005')?null:contactId,
    		Seller_Email__c = contEmail,
    		Seller_Name__c = sellerId,
    		Start_Date_w__c = System.today(),
    		End_Date_w__c = System.today().addDays(14)    		
    	);
    	insert fvf;
    	//system.debug('>>fvf: '+fvf);
    	List<Nominated_Item__c> listNominatedItemCreate = new List<Nominated_Item__c>();
    	List<String> listSellerToProduct = sellerToProductIds.split(',');
    	String sWhere = ' Where Id IN:listSellerToProduct';
    	
    	for(Seller_to_Product__c stp: Database.query(SOQL_SELLER_TO_PRODUCT + sWhere))
    	{
    		listNominatedItemCreate.add(
    			new Nominated_Item__c(
    				Final_Value_Fee_FVF__c = fvf.Id,
    				Listing_Name_w__c = stp.Name,
    				Listing_ID_w__c = stp.Listing_ID__c,
    				Product_ID_w__c = stp.Product__c,
    				Product_Name__c  = stp.Product__r.Name,
    				Price_seller_w__c = stp.Price_seller__c,
    				Price_target_w__c = stp.Product__r.Price_competitor_2__c
    			)
    		);
    		
		}
    	//System.debug('>>>mapSelectedSOPP:' +mapSelectedSOPP);
    	if(!mapSelectedSOPP.isEmpty())
    	{
    		Set<String> setSOPPId = mapSelectedSOPP.keySet();
    		String sWhereSOPP = ' Where Id IN :setSOPPId ';	
	    	for(Sourcing_Opportunity__c sopp: Database.query(EBH_ConstantsUtility.SOQL_SOPP + sWhereSOPP))
	    	{ 
	    		listNominatedItemCreate.add(
	    			new Nominated_Item__c(
	    				Final_Value_Fee_FVF__c = fvf.Id,
    					EAN_w__c = sopp.Product__r.EAN__c,
    					Price_target_w__c = sopp.Product__r.Price_competitor_2__c,
    					Product_Name__c  = sopp.Product__r.Name
	    			)
	    		);
	    	}
    	}
    	
    	insert listNominatedItemCreate;
    }
    
    /*****************************************************************************************************************************
	@ Method:   apexGetAllRecordId
	@ Version:  1.0
	@ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
	@ Purpose:  US-0005891
	@			As a...
	@ 			Any User
	@ 			Want to...
	@ 			select all Seller to Product records in Inventory Diagnostic
	@ 			So that...
	@ 			I do not have to go through all list views if I want to send all records to a seller
	@ 			Description
	@ 			AC1:
	@ 			Given that I am Any User
	@ 			When I got to Inentory Diagnostic 
	@ 			I am able to see "Select All" button 
	@ 			Than enables me to select all records that fit the filter criteria
	@ 			*Currently I am able to select only those record that are shown in the list view
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:      String: sql for where conditon 
	------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 05.07.2020/ Sophal Noch / Created the  Method.
	*****************************************************************************************************************************/
	@AuraEnabled
    public static Map<String,Object> apexGetAllRecordId(String soqlWhere)
    {

		Map<String,Object> mapResult = new Map<String,Object>();

		try {

			Map<String,Boolean> mapAllRecordId;

			String completeSoql = ID_SELECTION_SOQL + soqlWhere;

			List<Sobject> listAllRecord = Database.query(completeSoql);

			if(!listAllRecord.isEmpty()){
				
				mapAllRecordId = new Map<String,Boolean>();

				for(Sobject eachSObject : listAllRecord){
					mapAllRecordId.put(eachSObject.Id,true);
				}

			}
			mapResult.put('status','ok');
			mapResult.put('mapAllRecordId',mapAllRecordId);

		}catch(Exception ex)
    	{   mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString());	}
       
    	return mapResult;
    }

    
     
    private static List<String> getColumnHeaders(String obj,String country)
    {
    	 return mapColumnHeader.containsKey(obj+'_'+country)?mapColumnHeader.get(obj+'_'+country):mapColumnHeader.get(obj+'_UK');//default UK
    }
    
    /*	NK:20/08/2019: EPH-7932 
    	mapping collumn head by object and country
    	STP : Seller To Product
    	SOPP: Sourcing Opportunity
    */
    private static Map<String,List<String>> mapColumnHeader = new Map<String,List<String>>
    {
    	'STP_DE'=> new List<String>{'Nutzername',
						    		'Artikelnummer',
						    		'Angebotstitel',
						    		'Ihr aktueller Verkaufspreis',
						    		'Empfohlener Verkaufspreis oder niedriger(mit Versandkosten)',
						    		'Hauptkategorie',
						    		'Level-3 Kategorie', 
						    		'Marke',
						    		'EAN',
						    		'Preisdifferenz',
						    		'Festellungsdatum'},
		'SOPP_DE' => new List<String>{'Nutzername',
				    				'Produktbezeichnung',
				    				'Empfohlener Verkaufspreis oder niedriger(mit Versandkosten)',
				    				'Level-3 Kategorie',
				    				'Marke',
				    				'EAN',
				    				'Ha/uptkategorie',
				    				'Festellungsdatum'},
		'STP_UK'=>  new List<String>{'Seller',
									'Listing ID',
									'Listing Link',
									'Listing Title',
									'Price',
									'Maximum Recommended Price',
									'Price Difference (%)',
									'L3 Category',
									'Vertical',
									'Brand',
									'EAN'},
		'SOPP_UK' => new List<String>{'Seller',
									'Product Name',
									'Maximum Recommended Price',
									'L3 Category',
									'Vertical',
									'Brand',
									'EAN'},
		'STP_ES' => new List<String>{'Vendedor',
						    		'Referencia eBay',
						    		'Enlace al anuncio',
						    		'Título del anuncio',
						    		'Precio',
						    		'Precio máximo recomendado',
						    		'Diferencia de precio %', 
						    		'Categoria L3',
						    		'Vertical',
						    		'Marca',
						    		'EAN'},
		'SOPP_ES' => new List<String>{'Vendedor',
				    				'Nombre del producto',
				    				'Link del producto',
				    				'Precio máximo recomendado',
				    				'Vertical',
				    				'Marca',
				    				'EAN'},
		'STP_IT' => new List<String>{'Venditore',
						    		'Numero oggetto eBay',
						    		'Link all\'inserzione',
						    		'Titolo dell\'inserzione',
						    		'Prezzo',
						    		'Prezzo massimo raccomandato',
						    		'Differenza di prezzo (%)', 
						    		'Categoria L3',
						    		'Vertical',
						    		'Marca',
						    		'EAN'},
		'SOPP_IT' => new List<String>{'Venditore',
				    				'Nome del prodotto',
				    				'Link alla pagina del prodotto',
				    				'Prezzo massimo raccomandato',
				    				'Categoria',
				    				'Marca',
				    				'EAN'}
	
									
    };
    
    private static List<String> getListFieldName(String obj,String country)
    {
    	return mapFieldsName.containsKey(obj+'_'+country)?mapFieldsName.get(obj+'_'+country):mapFieldsName.get(obj+'_UK'); //default UK
    }
    
    private static Map<String,List<String>> mapFieldsName = new Map<String,List<String>>
    {
    	'STP_DE'=> new List<String>{'Seller__r.Name',
    								'Listing_ID__c',
    								'Name',
    								'Price_seller__c',
    								'Price_Main_Competitor__c', // Product__r.Price_competitor_2__c
    								'Product__r.Vertical__c',
    								'Category_L3__c',
    								'Brand__c',
    								'Product__r.EAN__c',
    								'Price_Difference_seller_vs_competitor__c',
    								'Product__r.Update_Date__c'},
    								
    	'SOPP_DE'=> new List<String>{'Seller__r.Name',
    								'Product__r.Name',
    								'Product__r.Price_competitor_2__c',
    								'Product__r.Category_Tree__r.Name',
    								'Brand__c',
    								'Product__r.EAN__c',
    								'Product__r.Vertical__c',
    								'Update_Date__c'},
    	'SOPP_UK'=> new List<String>{'Seller__r.Name',
    								'Product__r.Name',
    								'Product__r.Price_competitor__c',
    								'Product__r.Category_Tree__r.Name',
    								'Product__r.Vertical__c',
    								'Brand__c',
    								'Product__r.EAN__c'},
    	'STP_UK'=> new List<String>{'Seller__r.Name',
    								'Listing_ID__c',
    								'eBay_Item_Link_auto_h__c', //NK:22/102019: US-0009409: eBay_Item_Link_auto__c
    								'Name',
    								'Price_seller__c',
    								'Price_Main_Competitor__c', // Product__r.Price_competitor__c
    								'Price_Difference_seller_vs_competitor__c',
    								'Category_L3__c',
    								'Product__r.Vertical__c',
    								'Brand__c',
    								'Product__r.EAN__c'},
    	 'STP_ES'=> new List<String>{'Seller__r.Name',
    								'Listing_ID__c',
    								'eBay_Item_Link_auto_h__c', 
    								'Name',
    								'Price_seller__c',
    								'Price_Main_Competitor__c', 
    								'Price_Difference_seller_vs_competitor__c',
    								'Category_L3__c',
    								'Product__r.Vertical__c',
    								'Brand__c',
    								'Product__r.EAN__c'},
    	'SOPP_ES'=> new List<String>{'Seller__r.Name',
    								'Product__r.Name',
    								'Product__r.eBay_Product_Link__c',
    								'Product__r.Price_competitor__c',
    								'Product__r.Vertical__c',
    								'Brand__c',
    								'Product__r.EAN__c'},
    	'STP_IT'=> new List<String>{'Seller__r.Name',
    								'Listing_ID__c',
    								'eBay_Item_Link_auto_h__c', 
    								'Name',
    								'Price_seller__c',
    								'Price_Main_Competitor__c', 
    								'Price_Difference_seller_vs_competitor__c',
    								'Category_L3__c',
    								'Product__r.Vertical__c',
    								'Brand__c',
    								'Product__r.EAN__c'},
    	'SOPP_IT'=> new List<String>{'Seller__r.Name',
    								'Product__r.Name',
    								'Product__r.eBay_Product_Link__c',
    								'Product__r.Price_competitor__c',
    								'Product__r.Vertical__c',
    								'Brand__c',
    								'Product__r.EAN__c'}
    								
    	
	    				 
    };
    
    private static String getFieldValue(String fieldName,Sobject sobj,String revRoll)
    {
    	//System.debug('>>>fieldName: '+fieldName);
    	Object val = ApexUtil.getValue(fieldName,sobj);
    	Schema.DisplayType fType =  mapFieldType.get(sobj.getSObjectType()+':'+fieldName);
    	if(val==null)
    	{
    		return '';
    	}else if(Schema.DisplayType.Percent ==fType)
    	{
    		//return val +' %';
    		return ApexUtil.formatNumber((Decimal)val,2,revRoll)+' %';
    	}else if(Schema.DisplayType.Date ==  fType)
    	{
    		return ((Date)val).format();
    	}else if(Schema.DisplayType.DateTime == fType)
    	{
    		return ((DateTime)val).format();
    	}else if(Schema.DisplayType.Currency == fType|| Schema.DisplayType.Integer == fType  || Schema.DisplayType.Double == fType ||  Schema.DisplayType.Long == fType)
    	{
    		return ApexUtil.formatNumber((Decimal)val,2,revRoll);
    	}
    	
    	return val+''; 
    	 
    } 
    
    private static Map<String,Schema.DisplayType> mapFieldType = new Map<String,Schema.DisplayType>
    {
    	'Seller_to_Product__c:Price_Difference_seller_vs_competitor__c'=> Schema.DisplayType.Percent,
    	'Seller_to_Product__c:Product__r.Update_Date__c'=> Schema.DisplayType.Date,
    	'Sourcing_Opportunity__c:Update_Date__c'=>Schema.DisplayType.Date,
    	'Seller_to_Product__c:Price_seller__c'=>Schema.DisplayType.Double,
    	'Seller_to_Product__c:Product__r.Price_competitor_2__c'=>Schema.DisplayType.Double,
    	'Sourcing_Opportunity__c:Product__r.Price_competitor_2__c'=>Schema.DisplayType.Double
    };
    
    private static String getAttName(String obj, Account seller)
    {
    	Map<String,String> mapAttNames = new Map<String,String>
	    {
	    	'STP_UK'=>'Your Top Product Listings Information.xls',
	    	'STP_DE'=>'Preisempfehlungen für {!sellerName}.xls',
	    	'STP_ES'=>'Informe de competitividad.xls',
	    	'STP_IT'=>'Report di competitività.xls'
	    };
	    String k = obj+'_'+seller.EBH_RevRollup__c;
	    return mapAttNames.containsKey(k)?mapAttNames.get(k).replace('{!sellerName}',seller.Name):mapAttNames.get(obj+'_UK'); //default
    }
    
    private static String getSheetName(String obj,String revRoll )
    {
    	 Map<String,String> mapSheetNames = new Map<String,String>
	    {
	    	'STP_UK'=>'Top Product Listings',
	    	'STP_DE'=>'Mögliche Preis-Optimierungen',
	    	'STP_ES'=>'optimización de precios',
	    	'STP_IT'=>'Suggerimenti sul prezzo'
	    };
	    
	    return mapSheetNames.containsKey(obj+'_'+revRoll)?mapSheetNames.get(obj+'_'+revRoll):mapSheetNames.get(obj+'_UK');//default uk
    }
    private static String getSheetNameSOPP(String obj,String revRoll )
    {
    	 Map<String,String> mapSheetNames = new Map<String,String>
	    {
	    	'SOPP_UK'=>'inventory opportunities',
	    	'SOPP_DE'=>'Inventarlücken',
	    	'SOPP_ES'=>'Opportunidades de inventario',
	    	'SOPP_IT'=>'Suggerimenti sull’inventario'
	    };
	    
	    return mapSheetNames.containsKey(obj+'_'+revRoll)?mapSheetNames.get(obj+'_'+revRoll):mapSheetNames.get(obj+'_UK');//default uk
    }
    
    private static UserContact findUserContact(String contactId)
    {
    	Set<String> setUser = new Set<String>{UserInfo.getUserId()};
    	String soql = contactId.startsWith('005')?EBH_ConstantsUtility.SOQL_User:EBH_ConstantsUtility.SOQL_CONTACT+' Where Id =:contactId ';
    	SObject sobj =  Database.query(soql);
    	 
    	return new UserContact(sobj.get('Id')+'',sobj.get('Name')+'',sobj.get('Email')+'');
    }
    
    public class UserContact{
    	
    	@AuraEnabled
    	public String id;
    	
    	@AuraEnabled
    	public String name;
    	
    	@AuraEnabled
    	public String email;
    	public UserContact(String id,String name,String email)
    	{
    		this.id = id;
    		this.name = name;
    		this.email = email;
    	}
    }
    
   class JOption{
    	public String label;
    	public String value;
    	public JOption(String label,String value)
    	{
    		this.label = label;
    		this.value = value;
    	}
    }
}