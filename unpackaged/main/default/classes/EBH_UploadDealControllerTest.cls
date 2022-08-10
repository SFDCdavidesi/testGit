@isTest
public with sharing class EBH_UploadDealControllerTest {
    
    
    @isTest static void testUploadDealFromCSV(){
        EBH_TestDataFactory.setUpCustomSettings();     
        //Map<String, Account> testDataMap = EBH_TestDataFactory.setUpAccountTriggerHandlerData();     
    	RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account testDataMap = new Account(Name='se1',RecordTypeID = sellerRecordType.Id);
        insert testDataMap;
       // String contentFile = 'eBay Artikelnummer;Verkäufer;Artikelbezeichnung;EAN;Verkäuferpreis;RRP/WAS;Streichpreis;Menge;frühester Dealtermin;Deals Format;Idealo Link;Amazon Link;ebay Link;Bild Link;AM comment;Verkäuferkommentar;Vertical;Kampagnenvorschlag;Verkäufer e-mail Adresse\n\r332111284852;%sellerName%;ESET MultiDevice Security 2017 FFP 5U DE|YVVV2E06;;19.99 €;WAS;21.99;250;16/2/2017;Value Hero;http://www.idealo.de/preisvergleich/OffersOfProduct/5101535_-multi-device-security-2017-de-5-geraete-1-jahr-ffp-eset.html;;;;Test Sourcer;Test Seller;Sport;;test@ebaytest.de;77;10:00;20:00 am;';
       // String contentFileDE = 'eBay Artikelnummer;Verkäufer;Artikelbezeichnung;EAN;Verkäuferpreis;RRP/WAS;Streichpreis;Menge;frühester Dealtermin;Deals Format;Idealo Link;Amazon Link;ebay Link;Bild Link;AM comment;Verkäuferkommentar;Vertical;Kampagnenvorschlag;Verkäufer e-mail Adresse\n\r332111284852;%sellerName%;ESET MultiDevice Security 2017 FFP 5U DE|YVVV2E06;;19,99 €;WAS;21,99;;16/2/2017;Value Hero;http://www.idealo.de/preisvergleich/OffersOfProduct/5101535_-multi-device-security-2017-de-5-geraete-1-jahr-ffp-eset.html;;;;Test Sourcer;Test Seller;Sport;;test@ebaytest.de;77;10:00;;';
        String contentFile = 'eBay item id,seller user id,product title,ean,seller price,RRP/ WAS,RRP/ WAS price,QTY,earliest deal date,deal format,idealo url,amazon url,ebay url,picture url,comment ebay,comment seller,category,campaign proposal,seller email adress,Site ID\n\r12312414,%sellerName%,test1,343,6000,32,12,330,20/7/2019,Primary,www.test.com,www.test.com,www.test.com,www.test.com,Testing Comment E2E,Testing Comment Buser,Beauty & Gesundheit,,sovantheany.dim@gmail.com,UK';
        String contentFileDE = 'eBay item id,seller user id,product title,ean,seller price,RRP/ WAS,RRP/ WAS price,QTY,earliest deal date,deal format,idealo url,amazon url,ebay url,picture url,comment ebay,comment seller,category,campaign proposal,seller email adress,Site ID\n\r12312414,%sellerName%,test1,343,6000,32,12,330,20/7/2019,Primary,www.test.com,www.test.com,www.test.com,www.test.com,Testing Comment E2E,Testing Comment Buser,Beauty & Gesundheit,,sovantheany.dim@gmail.com,UK';
        contentFile = contentFile.replace('%sellerName%',testDataMap.Name);
        contentFileDE = contentFileDE.replace('%sellerName%',testDataMap.Name);
        Test.startTest();
            Map<String, Object>mResult = EBH_UploadDealController.createDealFromCSV(testDataMap.Id, 'testFileName', contentFile,',','en',false);
            System.assert(Boolean.valueOf(mResult.get('isSuccess')));
            List<EBH_Deal__c> listDeals   = (List<EBH_Deal__c> )mResult.get('lstRecord');
            //System.assertEquals(listDeals[0].EBH_DealPrice__c,listDeals[0].EBH_SellerPrice__c,'pre-assign EBH_DealPrice__c = EBH_SellerPrice__c');
             
            Map<String, Object>mResult2 = EBH_UploadDealController.createDealFromCSV(testDataMap.Id, 'testFileName', contentFileDE,',','de',false);
            //System.assert(String.valueOf(mResult2.get('listError')).contains('Required field missing value'),' missing quantity as required field!');
            
            
            //System.assert(Boolean.valueOf(mResult2.get('isSuccess')));
        Test.stopTest();
        
    }
    
    @isTest static void testPreviewDealFromCSV(){
    	RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account testDataMap = new Account(Name='se1',RecordTypeID = sellerRecordType.Id);
        insert testDataMap;
        EBH_SpotlightCategory__c sc = new EBH_SpotlightCategory__c(EBH_SpotlightCategoryID__c='1111');
        insert sc; 
        EBH_DealRetailCampaign__c dsa1 = new EBH_DealRetailCampaign__c(EBH_Slots__c =2);
        insert dsa1;
        
        String contentFile = 'eBay item id,seller user id,product title,ean,seller price,deal price,deal start date,deal start time,deal end date,deal end time,RRP/ WAS,RRP/ WAS price,QTY,earliest deal date,deal format,spotlight category id,idealo url,amazon url,ebay url,picture url,comment ebay,comment seller,category,Retail Campaign ID,seller email adress,Site ID,owner\n\r12312414,%sellerName%,test1,13,200,20,,3:00,30/7/2019,5:00,10,9,50,5/7/19,Primary,1112,www.test.com,www.test.com,www.test.com,www.test.com,Test Suer ,Test Suer ,Immobilien,%RetailCampaignID%,sovantheany.dim@gmail.com,UK,%OwnerID%';
        String contentFileDE = 'eBay item id,seller user id,product title,ean,seller price,deal price,deal start date,deal start time,deal end date,deal end time,RRP/ WAS,RRP/ WAS price,QTY,earliest deal date,deal format,spotlight category id,idealo url,amazon url,ebay url,picture url,comment ebay,comment seller,category,Retail Campaign ID,seller email adress,Site ID,owner\n\r12312414,%sellerName%,test1,13,200,20,20/7/2019,3:00,30/7/2019,5:00,10,9,50,5/7/19,Primary,1111,www.test.com,www.test.com,www.test.com,www.test.com,Test Suer ,Test Suer ,Immobilien,%RetailCampaignID%,sovantheany.dim@gmail.com,UK,%OwnerID%';
        contentFile = contentFile.replace('%sellerName%',testDataMap.Name);
        contentFileDE = contentFileDE.replace('%sellerName%',testDataMap.Name);
        contentFile = contentFile.replace('%RetailCampaignID%',dsa1.Id);
        contentFileDE = contentFileDE.replace('%RetailCampaignID%',dsa1.Id);
        contentFile = contentFile.replace('%OwnerID%',UserInfo.getUserId());
        contentFileDE = contentFileDE.replace('%OwnerID%',UserInfo.getUserId());
        Test.startTest();
            Map<String, Object>mResult = EBH_UploadDealController.createDealFromCSV(testDataMap.Id, 'testFileName', contentFile,',','en',true);
            System.assert(Boolean.valueOf(mResult.get('isSuccess')));
            List<EBH_Deal__c> listDeals   = (List<EBH_Deal__c> )mResult.get('lstRecord');
            //System.assertEquals(listDeals[0].EBH_DealPrice__c,listDeals[0].EBH_SellerPrice__c,'pre-assign EBH_DealPrice__c = EBH_SellerPrice__c');
            Map<String, Object>mResult2 = EBH_UploadDealController.createDealFromCSV(testDataMap.Id, 'testFileName', contentFileDE,',','de',true);
            //System.assert(String.valueOf(mResult2.get('listError')).contains('Required field missing value'),' missing quantity as required field!');
            
            
            //System.assert(Boolean.valueOf(mResult2.get('isSuccess')));
            //testerror
            String contentFile2 = '123456788,testTH,Product Test Pro_1,13,60,50,15/03/2021/234/32423,3:00,15/04/2021,5:00,12,11,25,15/03/2021,Primary,56576789,www.test.com,www.test.com,www.test.com,www.test.com,Test ,Test  ,Immobilien,a0u7X000001nHu9QAE,sovantheany.dim@gaea-sys.com,DE,0053u000002puEDAAY';
        	Map<String, Object> mResult3 = EBH_UploadDealController.createDealFromCSV(testDataMap.Id, 'testFileName', contentFile2,';','en',true);
        Test.stopTest();
    }
            
}