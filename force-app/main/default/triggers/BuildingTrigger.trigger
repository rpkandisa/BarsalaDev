trigger BuildingTrigger on Building__c (after insert, after update) {
    
    if(Barsala_Settings__c.getOrgDefaults().Enable_Building_Trigger__c ){
        
        if(Trigger.isafter && (Trigger.isInsert || Trigger.IsUpdate) && !BuildingTriggerHandler.isRecursive){
            BuildingTriggerHandler.isRecursive = true;
            if(Trigger.isInsert){
                BuildingTriggerHandler.BuildingOwnerChanged(Trigger.new, Trigger.oldMap, true);
            }else if(Trigger.IsUpdate){
                BuildingTriggerHandler.BuildingOwnerChanged(Trigger.new, Trigger.oldMap, false);
            }
            
        }
    }
    
}