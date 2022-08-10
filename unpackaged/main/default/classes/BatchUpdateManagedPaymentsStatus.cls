/********************************************************************************************************************************
@ Class:            BatchUpdateManagedPaymentsStatus
@ Version:          1.0
@ Author:           Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:          US-0007611 If a Managed Payment record exists and
@                   is not already in the stage 'Preboarded' or 'Onboarded' 
@                   than a bulk process will check the related Seller record in Hive 
@                   to see if the Managed Payment Status (updated from DWH) has been set 
@                   to 'Preboarded' or 'Onboarded' {Story 0007543 AC:2} if it has been, 
@                   then the stage on the Managed Payment Project record [Project.EBH_Stage__c] 
@                   will be updated to either 'Preboarded' or 'Onboarded' accordingly.
@                
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 25.05.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Created the class.
----------------------------------------------------------------------------------------------------------------------------------
@ Class:            BatchUpdateManagedPaymentsStatus
@ Version:          2.0
@ Author:           Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:          US-0007898 
@                   As a...
@                   Any user
@                   Want to...
@                   be able to see the latest status of a managed payment record
@                   So that...
@                   I can understand when a seller has 'onboarded' to managed payments
@                   Description
@                   Summary:
@                   The goal was to make sure all sellers had 'Preboarded' but as there are additional status updates after this and we shouldn't be stopping stage from being updated after a seller has 'Preboarded'.
@                   Currently:
@                   When a Managed Payment record has EBH_Project.Stage__c != 'Preboarded' or 'Onboarded'
@                   The batch process checks the related Seller (Account.Managed_Payments_Status__c)' and updates the 'EBH_Project.Stage__c' accordingly.
@                   Unfortunately this also means that if a seller has 'Preboarded' the batch will not update the record any further.
@                   Fix
@                   Could we please amend the logic of the batch process so that the stage on a Managed Payment record is always updated unless EBH_Stage__c = 'Onboarded'

----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 30.07.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / modify the method BatchUpdateManagedPaymentsStatus / sql string.
*********************************************************************************************************************************
*/

global without sharing class BatchUpdateManagedPaymentsStatus implements Database.Batchable<SObject>,Schedulable{

    public static final Id PROJECT_MANAGED_PAYMENT_RECORDTYPE_ID = ApexUtil.getRecordTypeByName('EBH_Project__c','ManagedPayment').Id;

    public static final Id CUSTOMER_SELLER_RECORDTYPE_ID = ApexUtil.getRecordTypeByName('Account','EBH_Seller').Id;

    public static final String PREBOARDED_STATUS = 'Preboarded';
    public static final String ONBOARDED_STATUS = 'Onboarded';

    public static final Set<String> MANAGED_PAYMENT_STATUS = new Set<String>{PREBOARDED_STATUS,ONBOARDED_STATUS};

    // US-0007898 this below will also run when BH_Seller__r.Managed_Payments_Status__c = 'Onboarded' and EBH_Project__c.EBH_Stage__c = 'Preboarded'
    private string sqlQuery = 'SELECT Id, EBH_Stage__c, EBH_Seller__r.Managed_Payments_Status__c'
    + ' FROM EBH_Project__c'
    + ' WHERE RecordTypeId =: PROJECT_MANAGED_PAYMENT_RECORDTYPE_ID'
    + ' AND EBH_Seller__r.RecordTypeId =: CUSTOMER_SELLER_RECORDTYPE_ID'
    + ' AND('

    + ' (EBH_Stage__c NOT IN: MANAGED_PAYMENT_STATUS'
    + ' AND EBH_Seller__r.Managed_Payments_Status__c IN: MANAGED_PAYMENT_STATUS)'
    + ' OR'
    + ' (EBH_Stage__c =: PREBOARDED_STATUS'
    + ' AND EBH_Seller__r.Managed_Payments_Status__c =: ONBOARDED_STATUS)'

    + ')';   


    /*****************************************************************************************************************************
	@ Method/Constructor:   BatchUpdateManagedPaymentsStatus
	@ Version:  1.0
	@ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:  Setup a Query String for retrieveing EBH_Project__c records that 
                Field RecordType = MANAGED_PAYMENT
                AND Field EBH_Stage__c IS NOT Preboarded or Onboarded
                AND Its Child Record Field EBH_Seller__r/Account.RecordType = Seller
                AND EBH_Seller__r/Account.RecordType IS Preboarded or Onboarded
    @ Event:	When Batch instance initialize
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:      none
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 25.05.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Created the method.
    
	*****************************************************************************************************************************/

    public BatchUpdateManagedPaymentsStatus() {

    }

    /*****************************************************************************************************************************
	@ Method:   start
	@ Version:  1.0
	@ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:  Query String to retrive the data from Database
    @ Event:	after Batch instance initialize
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:      batch context
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 25.05.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Created the method.
	*****************************************************************************************************************************/

    global Database.QueryLocator start(Database.BatchableContext BC) {


        // System.debug('nsp : CUSTOMER_SELLER_RECORDTYPE_ID is : ' + CUSTOMER_SELLER_RECORDTYPE_ID);
        // System.debug('nsp : PROJECT_MANAGED_PAYMENT_RECORDTYPE_ID is : ' + PROJECT_MANAGED_PAYMENT_RECORDTYPE_ID);
        // System.debug('nsp : MANAGED_PAYMENT_STATUS is : ' + MANAGED_PAYMENT_STATUS);

        
        return Database.getQueryLocator(sqlQuery);
    }


    /*****************************************************************************************************************************
	@ Method:   execute
	@ Version:  1.0
	@ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:  take EBH_Project__c record list and loop over its and
                update each of its field EBH_Stage__c to Preboarded or Onboarded
                According to its child record field EBH_Seller__r/Account.Managed_Payments_Status__c
    @ Event:	when each batch run
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:      batch context , EBH_Project__c record list
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 25.05.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Created the method.
	*****************************************************************************************************************************/
    
    global void execute(Database.BatchableContext bc, List<EBH_Project__c> projects){

        for(EBH_Project__c eachProject: projects){
            eachProject.EBH_Stage__c = eachProject.EBH_Seller__r.Managed_Payments_Status__c;
        }

        update projects;


    }

    global void finish(Database.BatchableContext bc){

    }

    /*****************************************************************************************************************************
	@ Method:   execute
	@ Version:  1.0
	@ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:  make this class to be available to salesforce schedule. 
    @ Event:	When Schedule instance initialize
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:     schedule context
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 25.05.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Created the method.
	*****************************************************************************************************************************/

    global void execute(SchedulableContext sc) { 
        BatchUpdateManagedPaymentsStatus batchUpdateManagedPaymentStatus = new BatchUpdateManagedPaymentsStatus();
        Database.executeBatch(batchUpdateManagedPaymentStatus);
    }

}