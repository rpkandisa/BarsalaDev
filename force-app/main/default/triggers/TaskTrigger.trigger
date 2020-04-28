trigger TaskTrigger on Task (after insert, after update) {
    Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
    if(trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) && !TaskTriggerHandler.isRecursion && objBarsalaSetting.Enable_to_set_Booking_on_Task__c){
        TaskTriggerHandler.populateBookingId();
    }
}