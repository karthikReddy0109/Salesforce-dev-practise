public with sharing class OpportunityTriggerHandler {
    public class opportunityNotificationService{
        public String opportunityId;
        public String opportunityName;
        public Decimal amount;
        public String ownerName;
    }

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

    // This method is for future method async practise
    public static void onOppClosedWon(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        Set<Id> oppIdSet = new Set<Id>();
        for(Opportunity opp : oppList){
            Opportunity oldOpp = oppOldMap.get(opp.Id);
            if((oldOpp == null && opp.StageName == 'Closed Won') || (oldOpp != null && oldOpp.StageName != 'Closed Won' && opp.StageName == 'Closed Won')){
                oppIdSet.add(opp.Id);
            }
        }
        if(oppIdSet.isEmpty()) return;
        notifyExternalSystem(oppIdSet);
    }

    // Write a future method to make a callout on opportunity closes
    @future(callout = true)
    public static void notifyExternalSystem(Set<Id> oppIdSet){
        List<Opportunity> closedWonOpps = [SELECT Id, Name, Amount, OwnerId FROM Opportunity WHERE Id IN: oppIdSet];
        List<opportunityNotificationService> payload = new List<opportunityNotificationService>();
        for(Opportunity opp : closedWonOpps){
            opportunityNotificationService oppPayload = new opportunityNotificationService();
            oppPayload.opportunityId = opp.Id;
            oppPayload.opportunityName = opp.Name;
            oppPayload.amount = opp.Amount;
            oppPayload.ownerName = opp.OwnerId;
            payload.add(oppPayload);
        }
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://jsonplaceholder.typicode.com/posts');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(payload));
        req.setTimeout(10000);

        try{
            Http http = new Http();
            HttpResponse response = http.send(req);
            if(response.getStatusCode() >= 200 && response.getStatusCode() < 300){
                System.debug('Notified external system successfully');
            }else{
                System.debug('Callout failed : ' + response.getStatusCode() + ' ' + response.getBody());
            }
        }catch(Exception e){
            System.debug('Callout Exception : ' + e.getMessage());
        }
    }
}