@isTest
/*********************************************************************************************************************************
@ Class:          BatchUploadManagedPaymentTest
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        US-0007521 
@                 Test Class for BatchUploadManagedPaymentTest
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 18.06.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Created the class.
*********************************************************************************************************************************/
public with sharing class BatchUploadManagedPaymentTest {

    private static List<Account> sellers;
    private static List<String> oracleIds = new List<String>{'111','222','333','444'};
    private static List<String> invitationDates = new List<String>{'22/04/2020','23/04/2020','24/04/2020','25/04/2020'};


    static void init(){

        
       sellers = new List<Account> ();
        
        String germany = 'Germany';

        Id accountSellerRecordTypeId = ApexUtil.getRecordTypeByName('Account','EBH_Seller').Id;
        
        Integer accountCount = 4;

        for(Integer i = 0; i < accountCount; i++){

            Account acc = new Account(
                    Name = 'Seller_'+(i+1),
                    EBH_RegistrationCountry__c = germany,
                    EBH_OracleID__c = oracleIds[i],
                    RecordTypeId = accountSellerRecordTypeId
            );

            sellers.add(acc);
        }

    
    }


    @isTest static void createManagedPaymentFromCSVWithValidCSVData(){

        init();
        insert sellers;

        String sellerContentOne = oracleIds[0]+','+invitationDates[0];
        String sellerContentTwo = oracleIds[1]+','+invitationDates[1];
        String sellerContentThree = oracleIds[2]+','+invitationDates[2];
        String sellerContentFour = oracleIds[3]+','+invitationDates[3];

        String csvString = 'seller_id;Outreach_dt\r'+sellerContentOne+'\r'+sellerContentTwo+'\r'+sellerContentThree+'\r'+sellerContentFour;

        String uniqueName = ApexUtil.genUniqueString(10);

        //temporary doc. to be processed by Batch + String Iterator. then delete on finish
        Document doc=new Document(Name=uniqueName,Body=Blob.valueOf(csvString+''),FolderId=UserInfo.getUserId());
        insert doc;

        Test.startTest();
            BatchUploadManagedPayment b = new BatchUploadManagedPayment(null,uniqueName,'en',',');
            Database.executeBatch(b);
                         
        Test.stopTest();

            List<EBH_Project__c> createdProjectList = [SELECT Id,Name,RecordType.DeveloperName From EBH_Project__c];

            System.assertEquals(4, createdProjectList.size());

            for(EBH_Project__c eachProject : createdProjectList){
                System.assertEquals(BatchUploadManagedPayment.SELLER_MANAGED_PAYMENT_RECORD_TYPE, eachProject.RecordType.DeveloperName);
            }



    }



    @isTest static void createManagedPaymentFromCSVWithValidAndInValidCSVData(){

        init();
        insert sellers;
       
        String sellerContentOne = oracleIds[0]+','+invitationDates[0];
         // seller content 1 = correct
        
        String sellerContentTwo = (oracleIds[1]+'abc')+','+invitationDates[1];
         // seller content 2 = incorrect oracle id. seller is not  found.
        
        String sellerContentThree = oracleIds[2]+','+invitationDates[2];
        Id projectManagedPaymentRecordTypeId = ApexUtil.getRecordTypeByName('EBH_Project__c',BatchUploadManagedPayment.SELLER_MANAGED_PAYMENT_RECORD_TYPE).Id;
        EBH_Project__c projectManagedPayment = new EBH_Project__c(
            Name = 'Project ManagedPayment', 
            RecordTypeId = projectManagedPaymentRecordTypeId,
            EBH_Seller__c = sellers[2].Id
        );
        insert projectManagedPayment;
        // seller content 3 = incorrect because Managed Payment already exist
        
        String sellerContentFour = oracleIds[3]+','+(invitationDates[3].replaceAll('/', '+'));
        // seller content 4 = incorrect because incorrect Date format

        String csvString = 'seller_id;Outreach_dt\r'+sellerContentOne+'\r'+sellerContentTwo+'\r'+sellerContentThree+'\r'+sellerContentFour;

        String uniqueName = ApexUtil.genUniqueString(10);

        //temporary doc. to be processed by Batch + String Iterator. then delete on finish
        Document doc=new Document(Name=uniqueName,Body=Blob.valueOf(csvString+''),FolderId=UserInfo.getUserId());
        insert doc;

        Test.startTest();
        BatchUploadManagedPayment b = new BatchUploadManagedPayment(null,uniqueName,'en',',');
        Database.executeBatch(b);
                     
        Test.stopTest();

        
        List<EBH_Project__c> createdProjectList = [SELECT Id,Name,EBH_Seller__c From EBH_Project__c WHERE Id !=: projectManagedPayment.Id];

        System.assertEquals(1, createdProjectList.size());

        System.assertEquals(sellers[0].Id, createdProjectList[0].EBH_Seller__c);


    }


}