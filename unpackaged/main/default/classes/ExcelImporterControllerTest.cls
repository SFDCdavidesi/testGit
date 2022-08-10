/*********************************************************************************************************************************
@ Class:          ExcelImporterControllerTest
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        US-0011643 - SPIKE Implement Excel import module using JS to support copy paste
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:  17.06.2022 / Sophal Noch / Created the class.
*********************************************************************************************************************************/
@isTest
private class ExcelImporterControllerTest {
    @isTest
    private static void testUploadExcel(){

        //17.06.2022 / Sophal Noch / US-0011643 : test method for ExcelImporterController methods

        ApexPages.currentPage().getParameters().put('template','test');
        new ExcelImporterController();
        ExcelImporterController.getExcelImporterTemplate('test');

        Map<String,String> mapObject = new Map<String,String>{'Name'=>'Test1'};

        Map<String,Object> mapResult;

        Test.startTest();
            mapResult = ExcelImporterController.saveRecords('Account','Insert', new List<Map<String,String>>{mapObject});
            System.assertEquals(null, mapResult.get('error'));

            Account insertedAccount = [Select Id, Name From Account Where Name = 'Test1'];
            mapObject.put('Id',insertedAccount.Id);
            mapResult = ExcelImporterController.saveRecords('Account','Update', new List<Map<String,String>>{mapObject});
            System.assertEquals(null, mapResult.get('error'));


            mapObject.remove('Id');
            mapObject.put('Name','Test2');
            mapResult = ExcelImporterController.saveRecords('Account','Upsert', new List<Map<String,String>>{mapObject});
            System.assertEquals(null, mapResult.get('error'));

        Test.stopTest();



    }
}