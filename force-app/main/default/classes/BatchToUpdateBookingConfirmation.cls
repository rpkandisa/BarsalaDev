//Created by kandisatech and it is used to update booking Confirmation field
global class BatchToUpdateBookingConfirmation implements Database.Batchable<sObject>, Database.AllowsCallouts {

   public String soql;

   global BatchToUpdateBookingConfirmation(){
      soql = 'select id,Confirmation_Code__c from Xotelia_Booking__c where Confirmation_Code__c = null ';
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(soql);
   }

   global void execute(Database.BatchableContext BC, List<Xotelia_Booking__c> lst){       
       BookingConfirmationCode.updateBookingConfirmationCode(lst,false);
   }

   global void finish(Database.BatchableContext BC){
   }
}