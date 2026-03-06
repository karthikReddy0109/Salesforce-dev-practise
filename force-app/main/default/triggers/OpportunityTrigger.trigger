trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate){
            OpportunityTriggerHandler.createTaskOnOppClosedWon(trigger.new, trigger.oldMap);
        }
    }
}