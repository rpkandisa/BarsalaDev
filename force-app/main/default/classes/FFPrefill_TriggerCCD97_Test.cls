/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
@IsTest
private class FFPrefill_TriggerCCD97_Test
{
    @IsTest
private static void testTrigger()
    {
   Test.startTest();
   Prospective_Building__c primaryObject= new Prospective_Building__c( Address__c='test', ZIP__c='test');
 insert primaryObject;
   Test.stopTest(); 
 System.assertNotEquals(primaryObject.Id,null);   
 }

 static String getPickValue(String objName, String fld){ 
 String firstPicklistVal=''; 
  Schema.SObjectType sobjectType= Schema.getGlobalDescribe().get(objName);   
  // Get a map of fields for the SObject 
 map<String, Schema.SObjectField> fieldMap = sobjectType.getDescribe().fields.getMap(); 
  // Get the list of picklist values for this field. 
 list<Schema.PicklistEntry> values = 
 fieldMap.get(fld).getDescribe().getPickListValues(); 
 // Add these values to the selectoption list. 
 if(values!=null && values.size()>0){ firstPicklistVal=values[0].getValue()+'';} 
 return firstPicklistVal; 
 } 

}