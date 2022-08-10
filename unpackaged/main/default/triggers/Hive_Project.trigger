trigger Hive_Project on Hive_Project__c (before insert, before update, before delete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            
        }else if(Trigger.isUpdate){
            HiveProjectTriggerHandler.validateCompletedStatus(Trigger.new, Trigger.newMap);
        }else if(Trigger.isDelete){
           
        }
    }
}