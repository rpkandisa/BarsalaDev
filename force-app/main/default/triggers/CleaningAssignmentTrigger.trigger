trigger CleaningAssignmentTrigger on Cleaning_Assignment__c (after insert, after update, after delete) {

    Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
    if(!objBarsalaSetting.Turn_off_Cleaning_Assignment_Trigger__c && trigger.isafter) {

        if(trigger.isinsert && !CleaningAssignmentHandler.isCleaningRecursion){
            CleaningAssignmentHandler.UpdateNextPreviousCleaning(trigger.new); 
        }

        if(trigger.isupdate && !CleaningAssignmentHandler.isBookingCleaningRecursion && !objBarsalaSetting.TurnOff_QA_Cleaning_Create_On_UnitChange__c){
            CleaningAssignmentHandler.CleaningNextPrevChangeOnUpdate(trigger.new,trigger.oldmap); 
        }

        if(trigger.isdelete && !CleaningAssignmentHandler.isCleaningRecursion){
            CleaningAssignmentHandler.updateCleaningOnDelete(trigger.old); 
        } 
    }
}