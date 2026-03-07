public with sharing class AccountTriggerHandler {
    public static void preventDupAccByPhoneNum(List<Account> accList, Map<Id, Account> accOldMap){
        Set<String> incomingPhones = new Set<String>();
        for(Account acc : accList){
            if(acc.Phone != null && acc.Phone.trim() != ''){
                incomingPhones.add(acc.Phone);
            }
        }
        if(incomingPhones.isEmpty()) return;
        // Query existing phone numbers
        List<Account> existingAccPhones = [SELECT Id, Phone FROM Account WHERE Phone IN: incomingPhones];
        Map<String, Id> phoneToAccMap = new Map<String, Id>();
        // Iterate on exisiting phones and add it to map
        for(Account acc : existingAccPhones){
            phoneToAccMap.put(acc.Phone, acc.Id);
        }
        // Check for duplicates
        for(Account acc : accList){
            if(acc.Phone == null || acc.Phone.trim() == '') continue;
            if(phoneToAccMap.containsKey(acc.Phone)){
                Id existingAccId = phoneToAccMap.get(acc.Phone);
                if(acc.Id == existingAccId) continue;
                acc.addError('Account with phone number ' + acc.Phone + ' already exists. Duplicate phone numbers are not allowed');
            }
        }
    }

    public static void aggOppRevByStage(Id accountId){
        if(accountId == null) return;
        List<AggregateResult> result = [SELECT stageName stage, SUM(Amount) totalAmount FROM Opportunity WHERE AccountId =: accountId GROUP BY stageName]; 
        if(result.isEmpty()) return;
        Map<String, Decimal> stageToAmount = new Map<String, Decimal>();
        for(AggregateResult ar : result){
            stageToAmount.put((String)ar.get('stage'), (Decimal)ar.get('totalAmount'));
        }
        System.debug(stageToAmount);
    }
}