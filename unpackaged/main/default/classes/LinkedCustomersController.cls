/*********************************************************************************************************************************
@ Class:          LinkedCustomersController
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        US-0009214 - [Linked Acc]Enable Linked B2C Customers to be shown in Customer 360
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 23.03.2021 / Sovantheany Dim / Created the class.
*********************************************************************************************************************************/
public class LinkedCustomersController {
    /************************************* CONSTANT DEFINITION *************************************************/
    
    private static final string SOQL_SELLER = 'Select Id[PLACEHOLDER] From Account';
    private static final string SOQL_SELLER_Parent = 'Select Id, Linked_Acc_Group_Id__c From Account';
    private static final string SELLER_RECORDTYPE = 'EBH_Seller';

    /************************************ END OF CONSTANT DEFINITION*******************************************/
    
    /***********************************************************************************************************************************
    @ Method:       getAccounts 
    @ Version:      1.0
    @ Author:       Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:      US-0009214 - [Linked Acc]Enable Linked B2C Customers to be shown in Customer 360
    @ Parameter:    parentId: AccountId, limitClause : limit soql query
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Returns  Map<String,Object>
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 23.03.2021 / Sovantheany Dim / Created the Method.
	***********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> getAccounts(Id parentId, Integer limitClause) {
        Map<String,Object> mapResult = new Map<String,Object>();
        List<ContactsRelatedController.LightningTableColumnWrapper> lstTableColumn = new list<ContactsRelatedController.LightningTableColumnWrapper> ();
        List<Account> lstAccount = new List<Account>();
        
        //get Linked_Acc_Group_Id__c from parent seller
        List<Account> parentSeller = Database.query(SOQL_SELLER_Parent+' where Linked_Acc_Group_Id__c != null AND Id =: parentId AND recordtype.DeveloperName =: SELLER_RECORDTYPE');
        String linkCustomer = parentSeller.isEmpty()?'':parentSeller[0].Linked_Acc_Group_Id__c;
        if(!String.isBlank(linkCustomer)){
        	//get list Account related to Seller.Linked_Acc_Group_Id__c
	        lstAccount = Database.query(accountQuery+' where Linked_Acc_Group_Id__c != null AND Linked_Acc_Group_Id__c =: linkCustomer AND Id !=: parentId AND recordtype.DeveloperName =: SELLER_RECORDTYPE order by EBH_OracleID__c Limit '+limitClause);
	        //get list column header
	        for(Schema.FieldSetMember fld : SObjectType.Account.FieldSets.LinkedCustomers.getFields()){
	        	ContactsRelatedController.LightningTableColumnWrapper colWrapper = new ContactsRelatedController.LightningTableColumnWrapper();
	        	colWrapper.label = fld.getLabel();
	        	colWrapper.fieldName = fld.getFieldPath();
	        	colWrapper.type = String.valueof(fld.getType()).toLowerCase();
	        	colWrapper.sortable = true;
	        	lstTableColumn.add(colWrapper);
	        }
        }
        
        ContactsRelatedController.LightningTableWraper ltngTableWrapper = new ContactsRelatedController.LightningTableWraper();
        ltngTableWrapper.tableRecord = lstAccount;
        ltngTableWrapper.tableColumn = lstTableColumn;
        
        mapResult.put('lstWrapper',ltngTableWrapper);
        mapResult.put('accountNumber',ltngTableWrapper.tableRecord.size() > 0 ? ltngTableWrapper.tableRecord.size() : 0);
        mapResult.put('isMoreValue',lstAccount.size() == limitClause ? true : false);
        mapResult.put('sitePrefix',Site.getPathPrefix());
        return mapResult;
    }
    
    private static String accountQuery {
        get {
            //query account with placeholder
            String query = SOQL_SELLER;
            String PLACEHOLDER = EBH_ConstantsUtility.FR_BLANK;
            //All the fields are being queried which are present in the fieldset
            for(Schema.FieldSetMember fld : SObjectType.Account.FieldSets.LinkedCustomers.getFields()) {
                PLACEHOLDER += EBH_ConstantsUtility.ATCH_COMMA + fld.getFieldPath();
            }
            return !String.isBlank(PLACEHOLDER) ? query.replace(EBH_ConstantsUtility.PLACEH, PLACEHOLDER) : 
                   query.replace(EBH_ConstantsUtility.PLACEH, EBH_ConstantsUtility.FR_BLANK);
        }
    } 
}