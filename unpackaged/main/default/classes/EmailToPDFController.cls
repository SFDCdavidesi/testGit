public without sharing class EmailToPDFController {
    public String htmlBody {get;set;}
    public String parentId {get;set;}
    
    public EmailToPDFController()
    {
    	//parentId = ApexPages.currentPage().getParameters().get('parentId');
    	//parentId = null?null:String.escapeSingleQuotes(parentId);
    	
    }
}