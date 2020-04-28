/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
trigger FFPrefill_TriggerCCD97 on Prospective_Building__c
    (after insert)
{
 if  (trigger.isAfter  &&  trigger.isInsert) { 
List<Prospective_Building__c>  newlyInsertedItems =  [SELECT  Id ,  Insurance_formstack_link__c FROM  Prospective_Building__c WHERE  Id  IN :trigger.new] ; 
List<string> ids = new List<string>();
 for ( Prospective_Building__c e  : newlyInsertedItems) { 
ids.add(e.id); 
} 
 VisualAntidote.FastFormsUtilities.DoUpdateRecords( 'Prospective_Building__c' ,  'Insurance_formstack_link__c' ,  'a231Q000001sF3vQAE' ,  ids,null );  
 update newlyInsertedItems;}
}