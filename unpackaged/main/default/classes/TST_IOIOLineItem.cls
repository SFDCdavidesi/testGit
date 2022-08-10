/*****************************************************************************************************************************
@ Author:      Mony Nou (mony.nou@gaea-sys.com)
@ Purpose:     US-0008416 test class for DARTObject
------------------------------------------------------------------------------------------------------------------------------
@ Change history:  26.10.2021 / Mony Nou / Created the method to cover all deprecated class related with IO & IO Line Item
------------------------------------------------------------------------------------------------------------------------------
@ Change history:  11.11.2021 / Mony Nou / US-0008358 - Add coverage for GW_MediaPlan
@*****************************************************************************************************************************/
@IsTest 
private class TST_IOIOLineItem {
    
    @isTest
    static void test_Method () {

        GW_Quote obj = new GW_Quote();

        GW_IO obj_1 = new GW_IO();

        IOLineItemMainTriggerHandler obj_2 = new IOLineItemMainTriggerHandler();

        ioMainTriggerHandler obj_3 = new ioMainTriggerHandler();

        GW_IO_LineItem_Junction obj_4 = new GW_IO_LineItem_Junction();

        IO__c io = new IO__c();
        insert io;

        IO_LineItem__c ioli = new IO_LineItem__c(
            IO__c = io.Id
        );
        insert ioli;


        Media_Plan__c mp = new Media_Plan__c();
        insert mp;

        MediaPlanMainTriggerHandler obj_5 = new MediaPlanMainTriggerHandler();
        
        //MN-11112021-US-0008358 
        GW_MediaPlan obj_6 = new GW_MediaPlan();

    }
}