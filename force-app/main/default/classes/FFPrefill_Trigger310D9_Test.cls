/**
 * Auto Generated and Deployed by Fast Prefill - Fast Forms
 **/
@IsTest
private class FFPrefill_Trigger310D9_Test
{
    @IsTest
private static void testTrigger()
    {
   Test.startTest();
   Xotelia_Booking__c primaryObject= new Xotelia_Booking__c( External_code__c='test');
 insert primaryObject;
  System.assert(Limits.getFutureCalls()>0);
 Test.stopTest();   
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