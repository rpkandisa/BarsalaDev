trigger QAAssignmentTrigger on QA_Assignment__c (after insert, after update, after delete) {
    Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
    if(!objBarsalaSetting.Turn_off_QA_Assignment_Trigger__c && trigger.isafter) {
        if(trigger.isinsert && !QAAssignmentHandler.isQARecursion){
            QAAssignmentHandler.UpdateNextPreviousQA(trigger.new); 
        }

        if(trigger.isupdate && !QAAssignmentHandler.isBookingQARecursion && !objBarsalaSetting.TurnOff_QA_Cleaning_Create_On_UnitChange__c){
            QAAssignmentHandler.QANextPrevChangeOnUpdate(trigger.new,trigger.oldmap);
        }

        if(trigger.isdelete && !QAAssignmentHandler.isQARecursion){
            QAAssignmentHandler.updateQAOnDelete(trigger.old); 
        }
    }
}