/*********************************************************************************************************************************
@ Class:         BatchUpdateCouponSellerStage
@ Version:       1.0
@ Author:        Mony Nou (mony.nou@gaea-sys.com)
@ Purpose:       US-0012069 - Issue with automatic update of coupon seller stage
@                   - This batch schedule is the replica of Flow "Coupon Seller After Flow" and will run every 2 hours 
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 18.07.2022 / Mony Nou / Created the class.
----------------------------------------------------------------------------------------------------------------------------------
*/
global with sharing class BatchUpdateCouponSellerStage implements Database.Batchable<SObject>, Schedulable {
    
    private final static String STAGE_CONTSIGNED = 'Contract Signed';
    private final static String STAGE_CONTTERMINATED = 'Contract Terminated';
    private final static String STAGE_CONTACCEPTED = 'Contract Accepted';
    private final static String STAGE_CPRUNNING = 'Coupon Running';
    private final static String STAGE_CPEXECUTED = 'Coupon executed';
    private final static String STAGE_RUNNING = 'Running';
    
    private final static String RT_MANHATTAN = 'Manhattan_Coupon';
    private final static String RT_POPCP = 'Pop_Coupon';

    private String sQuery = 'Select Id,Cofund_Start_Date__c, Cofund_End_Date__c, Coupon_Seller_Stage__c, RecordType.DeveloperName From Coupon_Seller__c'; 
    private String sWhere = ' WHERE (Cofund_Start_Date__c = TODAY OR Cofund_End_Date__c = TODAY) AND ('
                            + '(Cofund_Start_Date__c != NULL AND Coupon_Seller_Stage__c =:STAGE_CONTSIGNED AND RecordType.DeveloperName =:RT_MANHATTAN)'
                            + ' OR (Cofund_End_Date__c != NULL AND Coupon_Seller_Stage__c =:STAGE_CPRUNNING AND RecordType.DeveloperName =:RT_MANHATTAN)'
                            + ' OR (Cofund_End_Date__c != NULL AND Coupon_Seller_Stage__c !=:STAGE_CONTTERMINATED AND RecordType.DeveloperName =:RT_POPCP)'
                            + ' OR (Cofund_Start_Date__c != NULL AND Coupon_Seller_Stage__c =:STAGE_CONTACCEPTED AND RecordType.DeveloperName =:RT_POPCP))';

    private String cpSellerId;

    public BatchUpdateCouponSellerStage() {}

    public BatchUpdateCouponSellerStage(String cpSellerId) {
        this.cpSellerId = cpSellerId;
        this.sWhere = ' WHERE Id=:cpSellerId';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        return Database.getQueryLocator(sQuery+sWhere);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope){

        List<Coupon_Seller__c> lstCS2Update = new List<Coupon_Seller__c>();

        Date dToday = Date.today();

        for (Coupon_Seller__c cs : (List<Coupon_Seller__c>) scope) {

            //1) From Flow: Contact Signed?
            if (cs.Cofund_Start_Date__c != null && cs.Cofund_Start_Date__c == dToday && cs.Coupon_Seller_Stage__c == STAGE_CONTSIGNED && cs.RecordType.DeveloperName == RT_MANHATTAN) {
                cs.Coupon_Seller_Stage__c = STAGE_CPRUNNING;
            }
            
            //2) From Flow: Coupon Running?
            else if (cs.Cofund_End_Date__c != null && cs.Cofund_End_Date__c == dToday && cs.Coupon_Seller_Stage__c == STAGE_CPRUNNING && cs.RecordType.DeveloperName == RT_MANHATTAN) {
                cs.Coupon_Seller_Stage__c = STAGE_CPEXECUTED;
            }

            //3) From Flow: PopCouponRunning?
            else if (cs.Cofund_End_Date__c != null && cs.Cofund_End_Date__c == dToday && cs.Coupon_Seller_Stage__c != STAGE_CONTTERMINATED && cs.RecordType.DeveloperName == RT_POPCP) {
                cs.Coupon_Seller_Stage__c = STAGE_CONTTERMINATED;
            }

            //4) Contract Accepted?
            else if (cs.Cofund_Start_Date__c != null && cs.Cofund_Start_Date__c == dToday && cs.Coupon_Seller_Stage__c == STAGE_CONTACCEPTED && cs.RecordType.DeveloperName == RT_POPCP) {
                cs.Coupon_Seller_Stage__c = STAGE_RUNNING;
            }

            cs.TriggerStageUpdatedDate__c = System.now();
            
            lstCS2Update.add(cs);

        }
        
        if (!lstCS2Update.isEmpty()) {
            
            Database.SaveResult[] results = Database.update(lstCS2Update,false);
            List<Database.Error> dbError = new List<Database.Error>();

            for (Database.SaveResult result : results) {
                if (!result.isSuccess() && !Test.isRunningTest()){ dbError.addAll(result.getErrors()); }
            }

            if (!dbError.isEmpty()) EBH_ApexLogger.logError(dbError, 'BatchUpdateCouponSellerStage','execute (batch)');
        }
        
        
        
    }

    global void finish(Database.BatchableContext pBc){

    }

    global void execute(SchedulableContext sc) { 
        BatchUpdateCouponSellerStage b = new BatchUpdateCouponSellerStage();
        Database.executeBatch(b, 100);
    }
}