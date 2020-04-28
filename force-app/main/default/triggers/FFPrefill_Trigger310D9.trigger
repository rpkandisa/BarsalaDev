/**
 * Auto Generated and Deployed by Fast Prefill - Fast Forms
 **/
trigger FFPrefill_Trigger310D9 on Xotelia_Booking__c
    (after insert)
{
 if  (trigger.isAfter  &&  trigger.isInsert) { 
List<Xotelia_Booking__c>  newlyInsertedItems =  [SELECT  Id ,  update_payment_link__c FROM  Xotelia_Booking__c WHERE  Id  IN :trigger.new] ; 
List<string> ids = new List<string>();
 for ( Xotelia_Booking__c e  : newlyInsertedItems) { 
ids.add(e.id); 
} 
 VisualAntidote.FastFormsUtilities.UpdateRecordsWithURL ( 'Xotelia_Booking__c' ,  'update_payment_link__c' ,  'a2336000000mRSpAAM' ,  ids );  
 update newlyInsertedItems;}
}