/*********************************************************************************************************************************
@ Class:          BatchSendCouponSellerInvoiceStatement
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        Batch class to send email template to coupon seller
                  EPH-7565 Coupon - Manhattan Invoice Statment send to coupon seller
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 31.07.2019 / Sovantheany Dim (sovantheany.dim@gaea-sys.com) / Created the class.
*********************************************************************************************************************************/

global with sharing class BatchSendCouponSellerInvoiceStatement implements Database.Batchable<SObject>, Schedulable{
    String soql = '';
    
    /*****************************************************************************************************************************
    @ Method:         start
    @ Version:        1.0
    @ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:        QueryLocator start method
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 31.07.2019 / Sovantheany Dim (sovantheany.dim@gaea-sys.com) / Created the method.
    ****************************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soql);
    }
    
    /*****************************************************************************************************************************
    @ Method:         execute
    @ Version:        1.0
    @ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:        QueryLocator execute method
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 31.07.2019 / Sovantheany Dim (sovantheany.dim@gaea-sys.com) / Created the method.
    *****************************************************************************************************************************/
    global void execute(Database.BatchableContext pBc, List<SObject> scope){
    	/*set<String> emailTemplateName = new set<String>{EBH_ConstantsUtility.DE_INVOICE_4Days_EMAIL_TEMPLATED_NAME,EBH_ConstantsUtility.DE_INVOICE_34Days_EMAIL_TEMPLATED_NAME};
    	String whereCl = ' Where DeveloperName IN: emailTemplateName'; 
    	Map<String,EmailTemplate> mapEmpt = new Map<String,EmailTemplate>();
    	for(EmailTemplate empt : Database.query(EBH_ConstantsUtility.SOQLEMAIL_TEMPLATES + whereCl)){
    		mapEmpt.put(empt.DeveloperName, empt);
    	}
    	List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
    	List<Coupon_Seller__c> lstcouponSeller = new List<Coupon_Seller__c>();
        for(Coupon_Seller__c couponSeller : (List<Coupon_Seller__c>) scope){
        	if(couponSeller.Coupon__r.Contract_Language__c == 'DE'){
	        	if(couponSeller.days_since_coupon_End_Date__c == 4 && mapEmpt.containsKey(EBH_ConstantsUtility.DE_INVOICE_4Days_EMAIL_TEMPLATED_NAME)){
	        		couponSeller.Date_4days_Sent__c = System.now();
	        		lstcouponSeller.add(couponSeller);
	        		
        			EmailTemplate empt = mapEmpt.get(EBH_ConstantsUtility.DE_INVOICE_4Days_EMAIL_TEMPLATED_NAME);
        			Messaging.SingleEmailMessage mail = setSingleEmailMessage(empt, couponSeller);
        			listEmail.add(mail);
	        	}else if(couponSeller.days_since_coupon_End_Date__c == 34 && mapEmpt.containsKey(EBH_ConstantsUtility.DE_INVOICE_34Days_EMAIL_TEMPLATED_NAME)){
	        		couponSeller.Date_34_days_Sent__c = System.now();
	        		lstcouponSeller.add(couponSeller);
	        		
        			EmailTemplate empt = mapEmpt.get(EBH_ConstantsUtility.DE_INVOICE_34Days_EMAIL_TEMPLATED_NAME);
        			Messaging.SingleEmailMessage mail = setSingleEmailMessage(empt, couponSeller);
        			listEmail.add(mail);
	        	}
        	}
        }
       if(!lstcouponSeller.isEmpty()) update lstcouponSeller;
       if(!listEmail.isEmpty() && !Test.isRunningTest()) Messaging.sendEmail(listEmail);*/
    }
    
    /*private static Messaging.SingleEmailMessage setSingleEmailMessage(EmailTemplate empt, Coupon_Seller__c couponSeller){
    	String subject = mergSubject(empt.Subject,couponSeller);
    	String htmlBody = mergeEmailTemplateBody(empt.HtmlValue,couponSeller);
    	
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	mail.setToAddresses(new String[]{getObjectValue(couponSeller.Email_Adress__c)});
    	mail.setSenderDisplayName('Hive Support');
    	mail.setCcAddresses(new String[]{getObjectValue(couponSeller.EBH_CouponSellerOwner__r.Email)});
    	mail.setSubject(subject);
    	mail.setBccSender(false);
    	mail.setUseSignature(false);
    	mail.setHtmlBody(htmlBody);
    	return mail;
    }
    
    private static String getObjectValue(Object obj){
        if(obj==null)return '';
        return obj + '';
    }
    
    private static String mergSubject(String s, Coupon_Seller__c c)
    {
    	return s==null?'':s.replace('{!Coupon_Seller__c.Coupon_ID__c}',getObjectValue(c.Coupon_ID__c))
    			.replace('{!Coupon_Seller__c.Coupon_Start_Date__c}',(c.Coupon_Start_Date__c == null ? '':c.Coupon_Start_Date__c.format()))
    			.replace('{!Coupon_Seller__c.Coupon_End_Date__c}',(c.Coupon_End_Date__c == null ? '':c.Coupon_End_Date__c.format()));
    		
    }
    
    private static String mergeEmailTemplateBody(String s, Coupon_Seller__c c)
 	{
 		return s==null?'':s
 		.replace('{!Coupon_Seller__c.Coupon_ID__c}',getObjectValue(c.Coupon_ID__c))
 		.replace('{!Coupon_Seller__c.Coupon_Start_Date__c}',(c.Coupon_Start_Date__c == null ? '':c.Coupon_Start_Date__c.format()))
 		.replace('{!Coupon_Seller__c.Coupon_End_Date__c}',(c.Coupon_End_Date__c == null ? '':c.Coupon_End_Date__c.format()))
 		.replace('{!Coupon_Seller__c.GMV_LC__c}',getObjectValue(c.GMV_LC__c))
 		.replace('{!Coupon_Seller__c.Contra_LC__c}',getObjectValue(c.Contra_LC__c)) 
 		.replace('{!Coupon_Seller__c.Cost_Share_Seller_LC__c}',getObjectValue(c.Cost_Share_Seller_LC__c));
 	}*/
 	
    /*****************************************************************************************************************************
    @ Method:         finish
    @ Version:        1.0
    @ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:        QueryLocator finish method, it calls the insert batch
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 31.07.2019 / Sovantheany Dim (sovantheany.dim@gaea-sys.com) / Created the method.
    *****************************************************************************************************************************/ 
    global void finish(Database.BatchableContext pBc){
        
    }
    
    /*****************************************************************************************************************************
    @ Method:         execute
    @ Version:        1.0
    @ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:        Allow this batch to be schedulable
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 31.07.2019 / Sovantheany Dim (sovantheany.dim@gaea-sys.com) / Created the method.
    *****************************************************************************************************************************/ 
     global void execute(SchedulableContext sc) { 
        BatchSendCouponSellerInvoiceStatement b = new BatchSendCouponSellerInvoiceStatement();
        Database.executeBatch(b);
    }
}