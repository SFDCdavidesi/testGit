/*********************************************************************************************************************************
@ Class:          SEPCouponContractDownloadController
@ Version:        1.0
@ Author:         vadhanak voun (vadhanak.voun@gaea-sys.com)
@ Purpose:        Controller vf page: SEPCouponContractDownloadPage
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 14.06.2022 / vadhanak / Created the class.
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 05.08.2022 / Mony Nou / US-0012216 - NA Coupons: Downloading /storing Coupon Contract on Portal and in Hive
*********************************************************************************************************************************/
public with sharing class SEPCouponContractDownloadController {

    //EMAIL tempalte name 
    final String TEMPLATE_ITEM = 'DE_Item_Coupon_Contract_SEP_Download';
    final String TEMPLATE_CAT = 'DE_Category_Coupon_Contract_SEP_Download';

    public String csId {get;set;}
    
    public String htmlContent {get;set;}
   
    private final static String HTML_ROW_TEMPLATE_CAT = '<tr class=""><td> {Coupon_Category__c} </td><td> {Category_ID__c} </td><td> {Co_Invest__c} </td></tr>';
    private final static String HTML_ROW_TEMPLATE_EMPTY = '<tr><td></td><td></td><td></td></tr>';
    private final static String HTML_ROW_TEMPLATE_ITEM = '<tr class=""><td> {Item_ID__c} </td><td> {Item_Title__c} </td><td> {Co_Invest__c} </td></tr>';

    //MN-05082022-US-0012216
    private final static String PROF_SEP_DE = 'DE - Seller Portal';
    private final static String PROF_SEP_NA = 'NA - Seller Portal';
    private final static String COUPON_CATEGORYBASE = 'Category Based';
    private final static String COUPON_ITEMBASE = 'Item Based';

    private final static String EMAIL_COUPON_CONTRACT_DE_ITEM_SEP = 'DE_Item_Coupon_Contract_SEP_Download';
    private final static String EMAIL_COUPON_CONTRACT_DE_CAT_SEP = 'DE_Category_Coupon_Contract_SEP_Download';
    private final static String EMAIL_COUPON_CONTRACT_NA_ITEM_SEP = 'NA_Item_Coupon_Contract_SEP_Download';
    private final static String EMAIL_COUPON_CONTRACT_NA_CAT_SEP = 'NA_Category_Coupon_Contract_SEP_Download';
    
    Map<String, Map<String, String>> mProfEmailTemp = new Map<String, Map<String,String>> {
        PROF_SEP_DE => new Map<String, String>{
            COUPON_ITEMBASE => EMAIL_COUPON_CONTRACT_DE_ITEM_SEP,
            COUPON_CATEGORYBASE => EMAIL_COUPON_CONTRACT_DE_CAT_SEP
        },
        PROF_SEP_NA => new Map<String, String>{
            COUPON_ITEMBASE => EMAIL_COUPON_CONTRACT_NA_ITEM_SEP,
            COUPON_CATEGORYBASE => EMAIL_COUPON_CONTRACT_NA_CAT_SEP
        }
    };

    private static String userProf {
        
        get {

            if (String.isBlank(userProf)) {
                for (User u: [SELECT Profile.Name FROM User WHERE Id=:UserInfo.getUserId()]) { userProf = u.Profile.Name; }
            }

            return userProf;
        }

        private set;
    }
    //------MN-05082022-US-0012216

    public String dtNow {get;set;}
    public SEPCouponContractDownloadController()
    {
        
        dtNow = System.now().format('M/dd/yyyy, hh:mm a');
        csId  =  String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id')==null?'':ApexPages.currentPage().getParameters().get('id'));
        String domain = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('domain')==null?'':ApexPages.currentPage().getParameters().get('domain'));
        //export pdf as file (save)
        // String asFile = ApexPages.currentPage().getParameters().get('asfile')==null?'':ApexPages.currentPage().getParameters().get('asfile');
        if(String.isBlank(csId))
        {
            throw new ContractDownloadException('Invalid CS Id');
        }        
        Coupon_Seller__c cs = SEPCouponController.getCS(csId);
        Boolean isCat = cs.Coupon_Type__c==SEPCouponController.COUPON_CATEGORYBASE;

        // String templateName = isCat ? TEMPLATE_CAT : TEMPLATE_ITEM; //MN-05082022-US-0012216
        
        String templateName = mProfEmailTemp.get(userProf).get(cs.Coupon_Type__c); //MN-05082022-US-0012216
        
        EmailTemplate emp = [Select Id,HtmlValue From EmailTemplate WHERE DeveloperName =:templateName];
        htmlContent = emp.HtmlValue;

        htmlContent = htmlContent.replace('{!recordURL}', domain+'/coupon-seller/'+csId);
        
        htmlContent = SEPCouponController.mergeFieldsContractCoupon(htmlContent, cs);
        List<Coupon_Co_Invest__c> listCInvest = SEPCouponController.getListCoinvest(csId);

        String allHtmlRows = populateCatTable(htmlContent,listCInvest,isCat);

          //populate table of categories into html table
        htmlContent = htmlContent.replace('{CAT_TABLE_ROWS}',allHtmlRows);

        //request as file download
        // if(asfile=='1')
        // {            
        //     Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+getPDFName(cs.Name));
        // }
        
    }

    private static String populateCatTable(String htmlContent,List<Coupon_Co_Invest__c> listCInvest,Boolean isCat)
    {
        
        String allHtmlRows = '';
        if(!listCInvest.isEmpty())
        {
            
            for(Coupon_Co_Invest__c cinv : listCInvest)
            {                
                String row = doMergeFields(cinv,isCat?HTML_ROW_TEMPLATE_CAT:HTML_ROW_TEMPLATE_ITEM);               
                allHtmlRows += row;
            } 

        }else
        {
            allHtmlRows = HTML_ROW_TEMPLATE_EMPTY;
        }
        return allHtmlRows;     
    }

    private static String doMergeFields(Coupon_Co_Invest__c cinv,String template)
    {
        String row = template;
        return row.replace('{Coupon_Category__c}',ApexUtil.checkNull(cinv.Category__c)+'')
        .replace('{Category_ID__c}',ApexUtil.checkNull(cinv.Category_ID__c)+'')
        .replace('{Co_Invest__c}',(cinv.Co_Invest__c==null?'':cinv.Co_Invest__c.format()+'%'))
        .replace('{Item_ID__c}',ApexUtil.checkNull(cinv.Item_ID__c)+'')
        .replace('{Item_Title__c}',ApexUtil.checkNull(cinv.Item_Title__c)+'');
    }

    // public Pagereference pageAction()
    // {
    //     String lastatt  = String.escapeSingleQuotes((ApexPages.currentPage().getParameters().get('lastatt')==null?'':ApexPages.currentPage().getParameters().get('lastatt')));
    //     String csId  = String.escapeSingleQuotes((ApexPages.currentPage().getParameters().get('id')==null?'':ApexPages.currentPage().getParameters().get('id')));
    //    if(lastatt=='1' && String.isNotBlank(csId))
    //    { 
    //         String soql = 'Select Id,Name From Attachment ';
    //         String sWhere = 'where ParentId='+ApexUtil.closeSQoute(csId)+' ORDER BY CreatedDate DESC Limit 1';
    //         List<Attachment> listAtt = WithoutSharing.doQuery(soql, sWhere, '');
    //         if(!listAtt.isEmpty())
    //         {
    //             Pagereference pageAtt = new Pagereference('/servlet/servlet.FileDownload?file='+listAtt[0].Id);
    //             pageAtt.getHeaders().put('content-disposition', 'attachment; filename='+listAtt[0].Name);
    //             pageAtt.setRedirect(true);
    //             return pageAtt;
    //         }
            
    //    }

    //     return null;
    // }
    
    /*****************************************************************************************************************************
    @ Method:         createAttachment
    @ Version:        1.0
    @ Author:         vadhanak voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:        US-0010429 - Ability to sign Agreement in portal
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 16.06.2022 / Sambath Seng / US-0010536 - Downloading /storing Coupon Contract on Portal and in Hive
    *****************************************************************************************************************************/
    public static Map<String,String> createAttachment(Coupon_Seller__c cs)
    {
        Pagereference pdfPage = Page.SEPCouponContractDownloadPage;
        pdfPage.getParameters().put('id',cs.Id);
        pdfPage.getParameters().put('domain',Site.getBaseCustomUrl()); 
        // Blob pageBlob = pdfPage.getContent();
        try 
        {   
            Blob pdfContent = !Test.isRunningTest()?pdfPage.getContent():Blob.valueOf('test');
            //Attachment att = new Attachment(Name=getPDFName(cs),Body=pdfContent,ParentId=cs.Id,Description='SEP Autogenerated',ContentType ='application/pdf'); 
            //WithoutSharing.doInsert(new List<Attachment>{att});
            
            //Attachment attach = [SELECT Id, Name, Body, ContentType, ParentId From Attachment LIMIT 1];
 
            //Insert ContentVersion
            String pdfName = getPDFName(cs);
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = pdfName;//File name with extention
            cVersion.Origin = 'C';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = UserInfo.getUserId();//Owner of the file
            cVersion.Title = pdfName;//Name of the file
            cVersion.VersionData = pdfContent;//File content
            cVersion.Description = 'SEP Auto Generated';
            WithoutSharing.doInsert(new ContentVersion[]{cVersion});
            //After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = cs.Id;//Add attachment parentId
            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            //cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
             
            WithoutSharing.doInsert(new ContentDocumentLink[]{cDocLink});

            return new Map<String,String>{'id'=>cVersion.Id,'name'=>pdfName};
        } catch (DMLException dex) 
        {
            system.debug(dex);throw new ContractDownloadException(dex.getDmlMessage(0));
        }
        
    }

    //MN-25072022-US-0012015
    private static map <String, String> mPDFPrefix = new Map<String, String>{
        PROF_SEP_DE => 'Coupon-Aktion_',
        PROF_SEP_NA => 'Coupon-contract_'
    };

    //Coupon-Aktion | [Business Name] | [Coupon_ID] | [Marketing Name] | [Start Date]- [End Date]
    private static String getPDFName(Coupon_Seller__c cs)
    {
        //MN-25072022-US-0012015----
        String pdfName = (mPDFPrefix.containsKey(userProf))?mPDFPrefix.get(userProf):'';

        if (userProf.equals(PROF_SEP_DE)) pdfName += cs.Seller__r.Name + '_' + cs.Coupon_ID__c + '_' + cs.Marketing_Coupon_Name__c + '_' + cs.Coupon_Start_Date__c.format().replace('/','-') + ' - ' + cs.Coupon_End_Date__c.format().replace('/','-')+'.pdf';
        else if(userProf.equals(PROF_SEP_NA)) pdfName += cs.Seller__r.Name + '_' + cs.Marketing_Coupon_Name__c + '_' + cs.Coupon_Start_Date__c.format().replace('/','-') + ' - ' + cs.Coupon_End_Date__c.format().replace('/','-')+'.pdf';
        
        return pdfName;
        //----MN-25072022-US-0012015

        //MN-25072022-US-0012015
        //return 'Coupon-Aktion_'+cs.Seller__r.Name+'_'+cs.Coupon_ID__c+'_'+cs.Marketing_Coupon_Name__c+'_'+cs.Coupon_Start_Date__c.format().replace('/','-')+' - '+cs.Coupon_End_Date__c.format().replace('/','-')+'.pdf';
        //return csName+'-'+System.now().format('MMddyyyyhhmmss')+'.pdf';
    }
   

    class ContractDownloadException extends Exception{}
}