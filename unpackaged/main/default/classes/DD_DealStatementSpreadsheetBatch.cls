/*********************************************************************************************************************************
@ Class:          DD_DealStatementSpreadsheetBatch
@ Version:        1.0
@ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:        US-0008785 - [NA] Resend Deal Statements to Seller
@                 Migrated from Join-instance
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 08.01.2021 / Vadhanak Voun / Created the class.

@               : 19.03.2021 / Vadhanak Voun / US-0009248 - [NA] Mass Send created Deal Statements with attached Excel to Sellers

@               : 22.03.2021 / Sophal Noch / US-0009181 - [NA] Use Contact Roles for Deals instead of Contact Decision Maker Role

@               : 15.10.2021 / Mony Nou / US-0010374 - [NA Deal Statement] Adjusted Statement Generation
@
@               : 19.05.2022 / Sovantheany Dim / US-0011512 - Modify Email template for Adjusted and Disputed Statements
*********************************************************************************************************************************/
public without sharing class DD_DealStatementSpreadsheetBatch implements Database.Batchable<SObject>,Database.Stateful{
    private static Final String SECOND_PAYOUT_APPROVED = '2nd Payout Approved';
    private static Final String FIRST_PAYOUT_APPROVED = '1st Payout Approved';
    private static Final String DISPUTE_PAYOUT_APPROVED = 'Dispute Payout Approved';
    private static Final String FIRST_STATEMENT_SENTOUT = '1st Statement Sent out';
    private static Final String SECOND_STATEMENT_SENTOUT = '2nd Statement Sent out';
    private static Final String DISPUTE_STATEMENT_SENTOUT = 'Dispute Statement Sent Out';

    public static Set<String> PAYOUT_APPROVED = new Set<String>{FIRST_PAYOUT_APPROVED,SECOND_PAYOUT_APPROVED,DISPUTE_PAYOUT_APPROVED};
    public static Set<String> RESENT_PAYOUT_APPROVED = new Set<String>{FIRST_STATEMENT_SENTOUT,SECOND_STATEMENT_SENTOUT,DISPUTE_STATEMENT_SENTOUT};
    private static Map<String,String> MAP_STAUST_AFTER_SENT_OUT = new Map<String,String>{
        FIRST_PAYOUT_APPROVED=>FIRST_STATEMENT_SENTOUT,
        SECOND_PAYOUT_APPROVED=>SECOND_STATEMENT_SENTOUT,
        DISPUTE_PAYOUT_APPROVED=>DISPUTE_STATEMENT_SENTOUT 
    };

    //mapping to find the correct fieldname to get the stored attachment Id (2 fields)
    private static Map<String,String> MAP_FIELD_BY_STATUS = new Map<String,String>{
        FIRST_PAYOUT_APPROVED=>'MostRecentFirstStatement__c',
        SECOND_PAYOUT_APPROVED=>'MostRecentFinalStatement__c',
        DISPUTE_PAYOUT_APPROVED=>'MostRecentAdjustStatement__c', //MN-15102021-US-0010374 - Send Adjust Statement file
        FIRST_STATEMENT_SENTOUT=>'MostRecentFirstStatement__c',
        SECOND_STATEMENT_SENTOUT=>'MostRecentFinalStatement__c',
        DISPUTE_STATEMENT_SENTOUT=>'MostRecentAdjustStatement__c' //MN-15102021-US-0010374 - Send Adjust Statement file
    };

    private Map<String,String> dsId2ErrMsg = new Map<String,String>();
    private List<Deal_Statement__c> lstDs;
    public static String emailStatus = 'Error';
    
    private static Map<String,String> mapMonthValueToLabel; // 20.05.2021 / Sophal Noch / US-0009544
    
    public DD_DealStatementSpreadsheetBatch(List<String> ids){
        //MN-15102021-US-0010374 - Add MostRecentAdjustStatement__c into query
        this([Select MostRecentFirstStatement__c, MostRecentFinalStatement__c, MostRecentAdjustStatement__c, Id,Name,ebay_seller__c,ebay_seller__r.Name, Month__c, Year__c, Status__c, Further_Dispute_Payout__c, Disputes_Payout__c, Second_Payout__c from deal_statement__c where id in :ids]);
    }
    public DD_DealStatementSpreadsheetBatch(List<Deal_Statement__c> lstDs){
        this.lstDs = lstDs;
    }
    public List<SObject> start(Database.BatchableContext bc) {
        return lstDs;
    }
    
    public void execute(Database.BatchableContext bc, List<Deal_Statement__c> objs){
        for(Deal_Statement__c ds:objs){
            try{
                doGenerateSpeedsheet(ds);
            }catch(Exception e){
                dsId2ErrMsg.put(ds.Id,e.getMessage());
            }
        }
        
    }
    
   private static List<String> getReceivers(Id accId){
        //Once generated the email should be sent to all Contacts that have the Contact Role 'Marketplaces - Daily Deals Statement Recipient' 
        //against the same account as the Deal Statement is related ref: Deal_Statement__r.ebay_seller.Account__c
        List<String> emails = new List<String>();

        //Sophal:22/03/2021:US-0009181 replace 'Marketplaces - Daily Deals Statement Recipient' with 'NA Deals Statement Recipient'.
        for(Contact c:[select Email from Contact where Contact_Role__c INCLUDES('NA Deals Statement Recipient') and AccountId=:accId ]){
            emails.add(c.Email);
        }
        return emails;
    }
    public static Messaging.EmailFileAttachment createMessageAtt(Deal_Statement__c ds,String fileName){
         Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
         //NK:19/03/2021:US-0009248
        //PageReference xlsGenerater = new PageReference('/apex/'+page);
        
        // Blob xlsContent = null;
        // if(!Test.isRunningTest()){
        // 	xlsContent = xlsGenerater.getContent();
        // }else{
        // 	xlsContent =Blob.valueOf('test');
        // }

        String fname = MAP_FIELD_BY_STATUS.get(ds.Status__c);
        Attachment fileAtt;
        if(fname <> null && ds.get(fname) <> null )
        {
            //record Attachment
            String attId = ds.get(fname)+'';
            Attachment[] fileAtts = [Select Id,Name,Body from Attachment Where Id=:attId];
            if(!fileAtts.isEmpty())
            {
            	//TH: US-0009969 : 23/07/2021 : replace with fileAtts[0].Name
                //att.setFileName(fileName);
                att.setFileName(fileAtts[0].Name);
                att.setBody(fileAtts[0].Body);   
                return att;
            }else if(fileAtts.isEmpty())
            {
                //incase attachment uploaded as File
                ContentVersion[] files = [Select Id,Title,VersionData,FileExtension From ContentVersion Where ContentDocumentId=:attId];
                if(!files.isEmpty())
                {
                	//TH: US-0009969 : 23/07/2021 : replace with file title
                    //att.setFileName(fileName);
                    att.setFileName(files[0].Title);
                    att.setBody(files[0].VersionData);   
                    return att;
                }
            }
            
        }  
        //throw error if invalid status, no att id, or att not found 
        throw new AttachmentNotFoundException(System.Label.DD_AttachmentNotFound);               
        return att;
    }

    public static void doGenerateSpeedsheet(Deal_Statement__c ds){
    	doGenerateSpeedsheet(ds,null);
    }
    public static void doGenerateSpeedsheet(Deal_Statement__c ds,Messaging.SingleEmailMessage email){
        
       if(ds!=null){        
           if(PAYOUT_APPROVED.contains(ds.Status__c)||RESENT_PAYOUT_APPROVED.contains(ds.Status__c)){
                List<String> tos =getReceivers(ds.ebay_seller__c);
                if(tos!=null && !tos.isEmpty()){
                    
                    //Current_Digest__c
                    String currentDigest = ApexUtil.doEncrypt(ds.Id,ApexUtil.encryptionkey);
                    
                    List<Messaging.EmailFileAttachment> atts = new List<Messaging.EmailFileAttachment>();
                    if(email==null){
                    	String templatename = Label.DD_SSG_FirstPayoutEmailTempalte;  
	                    if(ds.Status__c==SECOND_PAYOUT_APPROVED||ds.Status__c==SECOND_STATEMENT_SENTOUT){ //MN-15102021-US-0010374 enable for status 'Dispute Payout Approved', 'Dispute Statement Sent Out' 
                            
	                    	//second payout
	                    	templatename =Label.DD_SSG_SecondPayoutEmailTempalte;
                        }
                        //TH: 19.05.2022: US-0011512 - Modify Email template for Adjusted and Disputed Statements
                        else if(ds.Status__c == DISPUTE_STATEMENT_SENTOUT || ds.Status__c == DISPUTE_PAYOUT_APPROVED){
                            if(ds.Disputes_Payout__c == null){
                                templatename = Label.DD_SSG_DisputeStatementEmailWithoutSub;
                            }else{
                                templatename = Label.DD_SSG_DisputeStatementEmailWithSub;
                            }
                        }
	                    Map<String,String> binding = new Map<String,String>();
	                    
	                    // binding.put('{!Deal_Statement}',EncodingUtil.urlEncode(currentDigest, 'UTF-8'));
	                    // binding.put('{!Site.Url}',ApexUtil.getSiteURL('Deal_Acceptance'));

                         // 20.05.2021 / Sophal Noch / US-0009544
                        binding.put('{!Deal_Statement__c.eBay_Seller__c}',ds.ebay_seller__r.Name);
	                    binding.put('{!Deal_Statement__c.Month__c}',getMonthLabel(ds.month__c));
                        binding.put('{!Deal_Statement__c.Year__c}',String.valueOf(ds.Year__c));
                        

                        

	                    //load email template 
	                    email = ApexUtil.prepareEmail(null,tos,null,templatename,templatename,binding,null,null);        
                    }       
                   
                   	String fileName = ds.Name+'.xls';
                    //Messaging.EmailFileAttachment att = createMessageAtt('DD_DealStatementSpreadsheet?Id='+ds.Id,fileName); 
                    //NK:19/03/2021:US-0009248
                    Messaging.EmailFileAttachment att = createMessageAtt(ds,fileName);                     
                    atts.add(att);

                    //atts.add(createMessageAtt('DealStatementPaymentDisputeGuidelines',ds.Name+'-PaymentDisputeGuidelines.xls'));
                    //atts.add(createMessageAtt('DealStatementSellerPaymentDispute',ds.Name+'-SellerPaymentDispute.xls'));                   
                     // Attach file using setFileAttachments function

                      // 20.05.2021 / Sophal Noch / US-0009544
                    OrgWideEmailAddress orgWide = ApexUtil.getOWDbyAddress(System.label.OWD_Deals_Subsidy_Support);
                    Id orgWideId = orgWide != null ? orgWide.Id : null;
                    email.setOrgWideEmailAddressId(orgWideId);  // 17.05.2021 / Sophal Noch / US-0009536
                    email.setFileAttachments(atts);
                    ApexUtil.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                    
                    emailStatus = 'Success';
                    ds.Last_Statement_Sent_Out__c = System.now();  
                    String statusBeforeChange =   ds.Status__c;                
                    //after send out sucess then update the ds
                    if(PAYOUT_APPROVED.contains(statusBeforeChange)){
                    	//update DS wen aprroved only
	                    
	                    ds.Status__c = MAP_STAUST_AFTER_SENT_OUT.get(ds.Status__c);
	                    if(ds.Further_Dispute_Payout__c != null){
	                    	ds.X2nd_Dispute_Statement_Sent_Out__c = System.Now();
	                    }else if(ds.Disputes_Payout__c != null){
	                    	ds.Dispute_Statement_Sent_Out__c = System.Now();	                    	
	                    }else if(ds.Second_Payout__c != null){
	                    	ds.X2nd_Statement_Sent_Out__c = System.Now();	                    	
	                    }else{
	                    	ds.X1st_Statement_Sent_Out__c = System.Now();	                    	
	                    }
                    }
           			if(PAYOUT_APPROVED.contains(statusBeforeChange)||RESENT_PAYOUT_APPROVED.contains(ds.Status__c)){
	                    update ds;
	                }

                      // 05.05.2021 / Sophal Noch / US-0009424 no need to generate and store more excel file
	            //    if(PAYOUT_APPROVED.contains(statusBeforeChange)){	                
	            //         //create content version for ds after send out
	            //         ContentVersion contVersion = new ContentVersion(Title = ds.Status__c, VersionData = att.Body, PathOnClient=fileName, FirstPublishLocationId = ds.id);
	            //         insert contVersion;
	            //    }
                    
                }else{
                    emailStatus = Label.DD_SSG_NoDesignatedContacts;
                    throw new NoContactException(Label.DD_SSG_NoDesignatedContacts);
                }
            }else{
                emailStatus = Label.DD_SSG_PayoutMustbeApproved;
                throw new PayoutException(Label.DD_SSG_PayoutMustbeApproved);
            }
       }
    }
    
    private static String getMonthLabel(String monthValue){

         // 20.05.2021 / Sophal Noch / US-0009544

        if(mapMonthValueToLabel == null){
            mapMonthValueToLabel = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult = Deal_Statement__c.Month__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry pickListVal : ple){
				mapMonthValueToLabel.put(pickListVal.getValue(),pickListVal.getLabel());
			}
        }
        return mapMonthValueToLabel.get(monthValue);
    }

    
    
    public void finish(Database.BatchableContext bc){
        //TODO later
    }

    public class NoContactException extends Exception{}
    public class PayoutException extends Exception{}
    public class AttachmentNotFoundException extends Exception{}
}