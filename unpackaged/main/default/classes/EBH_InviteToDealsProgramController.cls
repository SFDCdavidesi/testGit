public without sharing class EBH_InviteToDealsProgramController {
    
    public Account acc {get;set;}
    public Boolean isAllowed {get;set;}
    
    public ApexPages.StandardController contr;
    
    //defining the account record and the standard controller
    public EBH_InviteToDealsProgramController(ApexPages.StandardController controller) {
        this.acc = (Account)controller.getRecord();
        
    }
    
    // Saving the current record
    public PageReference updateInvitedtoDealProgram() {
    	  
    	   //NK:16/08/2019: EPH-7969: allow re-invite
        //if( acc.EBH_DealsProgram__c == null) {
        	try
        	{
        		if(String.isBlank(selectedCulture))
		    	{
		    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Growth Portal Culture is required.'));
		    		return null;
		    	}else
		    	{
		    		acc.EBH_GBCulture__c = selectedCulture;
		    	}
    	
        		acc.EBH_DealsProgram__c = 'Allow';
	            //acc.EBH_InvitedtoDealProgram__c = TRUE;
	           
	            update acc;
	             
        	}catch(Exception ex)
        	{
        		acc.EBH_DealsProgram__c = null;	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getdmlMessage(0))); return null;	
        	}
            
        //}
        //return null;
        return new PageReference('/' + acc.Id);
    }
    
    //NK:28/03/2018: use select list instead of input field (picklist culture field)
    //since Deal profile has read-only to Account
    public String selectedCulture{get;set;}
     
}