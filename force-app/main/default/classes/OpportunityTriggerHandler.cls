public with sharing class OpportunityTriggerHandler {
    public static void createTaskOnOppClosedWon(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        // 1. Create a task when opportunity is set to closed won
        /**
         * Task Details:
         *      Subject : Post-Sale Follow-Up: <Opportunity Name>
         *      Due date : 3 days from today
         *      Priority : High, Status : Not Started, Assigned to Opp owner id,        related to opp.
         */
        List<Task> tasksToCreate = new List<Task>();
        for(Opportunity opp : oppList){
            Opportunity oldOpp = oppOldMap.get(opp.Id);
            if((oldOpp == null && opp.StageName == 'Closed Won') || (oldOpp != null && oldOpp.StageName != 'Closed Won' && opp.StageName == 'Closed Won')){
                Task tsk = new Task();
                tsk.Subject = 'Post-Sale Follow-Up: ' + opp.Name;
                tsk.ActivityDate = System.today().addDays(3);
                tsk.Priority = 'High';
                tsk.Status = 'Not Started';
                tsk.OwnerId = opp.OwnerId;
                tsk.WhatId = opp.Id;
                tasksToCreate.add(tsk);
            }
        }
        if(tasksToCreate.isEmpty()) return;
        insert tasksToCreate;
    }
}