trigger AccountTrigger on Account (before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            AccountTriggerHandler.preventDupAccByPhoneNum(trigger.new, trigger.oldMap);
        }
    }
}