@istest
private class CopadoUserStoryTriggerHandlerTest {
    @testSetup
    public static void setupdata(){
         insert new EBH_ActiveTriggers__c(Name = 'EBH Trigger Controller',
                                         CopadoUserStory__c=true
                                         );            
        
    }

    static testMethod void testCUS(){
        Id rtUSId = ApexUtil.getRecordTypeByName('copado__User_Story__c','User_Story').Id;
        copado__User_Story__c cus = new copado__User_Story__c(BA_Priority__c='Medium',Business_Value_Points__c=300,RecordTypeId=rtUSId);
        cus.copado__User_Story_Title__c='test';
        cus.Description__c='test';
        cus.copado__Technical_Specifications__c='test';
            insert cus;
            TEst.startTest();
            cus.Description__c='test2';
            update cus;
            Test.stopTest();
    }
    
    
    static testMethod void testCUS3(){
        Id rtUSId = ApexUtil.getRecordTypeByName('copado__User_Story__c','User_Story').Id;
        copado__User_Story__c cus = new copado__User_Story__c(BA_Priority__c='Medium',Business_Value_Points__c=300,RecordTypeId=rtUSId);
        cus.copado__User_Story_Title__c='test';
        cus.Description__c='test';
        cus.copado__Technical_Specifications__c='';
            insert cus;
            TEst.startTest();
            Insert cus.clone();
            Test.stopTest();
        }

    @isTest
	static void testcheckDependency(){
        Id rtUSId = ApexUtil.getRecordTypeByName('copado__User_Story__c','User_Story').Id;
        copado__User_Story__c cus_parents = new copado__User_Story__c(copado__User_Story_Title__c='test cus_parents',Description__c='test 0001',copado__Technical_Specifications__c='test test 001',copado__Status__c ='Draft',BA_Priority__c='Medium',Business_Value_Points__c=300,RecordTypeId=rtUSId);
        copado__User_Story__c cus_child1 = new copado__User_Story__c(copado__User_Story_Title__c='test cus_child1',Description__c='test 0002',copado__Technical_Specifications__c='test test 002',copado__Status__c ='Draft',BA_Priority__c='Medium',Business_Value_Points__c=300,RecordTypeId=rtUSId);
        copado__User_Story__c cus_child2 = new copado__User_Story__c(copado__User_Story_Title__c='test cus_child2',Description__c='test 0003',copado__Technical_Specifications__c='test test 003',copado__Status__c ='Draft',BA_Priority__c='Medium',Business_Value_Points__c=300,RecordTypeId=rtUSId);
        insert new List<copado__User_Story__c>{cus_parents,cus_child1,cus_child2};
        copado__Team_Dependency__c usd1 = new copado__Team_Dependency__c(copado__Dependent_User_Story__c = cus_child1.Id,copado__Provider_User_Story__c = cus_parents.Id,Relationship__c='Binded');
        copado__Team_Dependency__c usd2= new copado__Team_Dependency__c(copado__Dependent_User_Story__c = cus_child2.Id,copado__Provider_User_Story__c = cus_child1.Id,Relationship__c='Binded');
        insert new List<copado__Team_Dependency__c>{usd1,usd2};
        //insert cus_parents;

        Test.startTest();
            cus_parents.copado__Status__c ='Technical Review';
            update cus_parents;
            copado__User_Story__c updateChild1 =[select Id,copado__Status__c from copado__User_Story__c where Id=:cus_child1.Id];
            System.assertEquals(updateChild1.copado__Status__c,'Technical Review');
            copado__User_Story__c updateChild2 =[select Id,copado__Status__c from copado__User_Story__c where Id=:cus_child2.Id];
            System.assertEquals(updateChild2.copado__Status__c,'Technical Review');
        Test.stopTest();

    }
    
    @isTest
	static void testUpdateProjectStatus(){
        Id rtUSId = ApexUtil.getRecordTypeByName('copado__User_Story__c','User_Story').Id;
        Hive_Project__c p = new Hive_Project__c(name='Testint project',Status__c='New');
        insert p;
        copado__User_Story__c cus_parents = new copado__User_Story__c(Hive_Project__c=p.Id,copado__User_Story_Title__c='test cus_parents',Description__c='test 0001',copado__Technical_Specifications__c='test test 001',copado__Status__c ='Draft',BA_Priority__c='Medium',Business_Value_Points__c=300,RecordTypeId=rtUSId);
        copado__User_Story__c cus_child1 = new copado__User_Story__c(Hive_Project__c=p.Id,copado__User_Story_Title__c='test cus_child1',Description__c='test 0002',copado__Technical_Specifications__c='test test 002',copado__Status__c ='Draft',BA_Priority__c='Medium',Business_Value_Points__c=300,RecordTypeId=rtUSId);
        copado__User_Story__c cus_child2 = new copado__User_Story__c(Hive_Project__c=p.Id,copado__User_Story_Title__c='test cus_child2',Description__c='test 0003',copado__Technical_Specifications__c='test test 003',copado__Status__c ='Draft',BA_Priority__c='Medium',Business_Value_Points__c=300,RecordTypeId=rtUSId);
        insert new List<copado__User_Story__c>{cus_parents,cus_child1,cus_child2};
        copado__Sprint__c sp = new copado__Sprint__c (Name='test Sprint 1');
        insert sp;
        Test.startTest();
        cus_parents.copado__Sprint__c = sp.Id;
       	update cus_parents;
        //System.assertEquals('Development', [select Status__c From Hive_Project__c where ID =: p.Id].Status__c);
        cus_parents.copado__Status__c = 'Deployed in PROD';
        update cus_parents;
        //System.assertEquals('Development', [select Status__c From Hive_Project__c where ID =: p.Id].Status__c);
        cus_child1.copado__Sprint__c = sp.Id;
        cus_child1.copado__Status__c = 'Duplicated';
        cus_child2.copado__Sprint__c = sp.Id;
        cus_child2.copado__Status__c = 'Closed - Complete';
        update new List<copado__User_Story__c>{cus_child1,cus_child2};
        //System.assertEquals('Completed', [select Status__c From Hive_Project__c where ID =: p.Id].Status__c);
        Test.stopTest();
    }

    @isTest
	static void testPriorityChanged(){

        // 08.07.2022 / Sophal Noch / US-0011960 

        Id rtUSId = ApexUtil.getRecordTypeByName('copado__User_Story__c','User_Story').Id;
        Hive_Project__c p = new Hive_Project__c(name='Testint project',Status__c='New');
        insert p;
        copado__Sprint__c sp = new copado__Sprint__c (Name='Salami Stream',copado__Status__c ='In progress');
        insert sp;

        copado__User_Story__c us = new copado__User_Story__c(Hive_Project__c=p.Id,copado__Status__c='Approved',copado__Sprint__c=sp.Id,copado__User_Story_Title__c='test cus_parents',Description__c='test 0001',copado__Technical_Specifications__c='test test 001',BA_Priority__c='Medium',Business_Value_Points__c=300,RecordTypeId=rtUSId);
        insert us;
        us.BA_Priority__c = 'High';
        List<copado__User_Story__c> listUs  = new List<copado__User_Story__c>();
        listUs.add(us);
        Test.startTest();
            List<Database.SaveResult> saveResult = Database.update(listUs, false);
            System.assertEquals(false,saveResult[0].isSuccess());
            System.assertEquals(Label.ErrorChangeBAPriorityWhenApproved,saveResult[0].getErrors()[0].getMessage());
        Test.stopTest();

    }
}