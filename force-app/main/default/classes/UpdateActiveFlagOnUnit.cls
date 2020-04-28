/*
    This class is used to update the active flag on the unit records based on the start date, End date and Decision field values.
    
*/
public without sharing class UpdateActiveFlagOnUnit {
    @InvocableMethod(label='Update Active Flag on Unit' description='It is used to update Status field value based on the Active flag on the unit')
    public static void UpdateActiveInactiveStatus(List<Id> ids) {
        set<id> unitIds = new set<id>();
        unitIds.addall(ids);
        List<Unit__c> unitsToBeUpdated = new List<Unit__c>();
        
        for(Unit__c u : [Select Active__c, Status__c, End_Date__c, Start_Date__c, Decision__c from Unit__c where id in: unitIds]){
            if((System.today() <= u.End_Date__c && system.today() >= u.Start_Date__c) || u.End_Date__c == null || u.Decision__c == 'MTM'){
                u.Active__c = true;
            }
            else if(System.today() <= u.Start_Date__c){
                u.Active__c = true;
            }
            else{
                u.Active__c = false;
            }
            unitsToBeUpdated.add(u);
        }
        if(unitsToBeUpdated.size() > 0)
            Update unitsToBeUpdated;
    }
}