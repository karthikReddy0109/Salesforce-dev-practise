public with sharing class ContactTriggerHandler {
    public static void handleContactUpdate(List<Contact> conList){
        for(Contact con : conList){
            con.Last_Modified_By_Trigger__c = UserInfo.getName();
            con.Trigger_Fire_Count__c = con.Trigger_Fire_Count__c == null ? 1 : con.Trigger_Fire_Count__c + 1;
        }
        // update conList;
    }

    
}