/*
    Description: It is used to perfom merge person account records only
    Createdby Kandisa technologies 
 */

global class BatchToMergePersonAccount implements Database.Batchable<sObject>{

   public String soql;

   global BatchToMergePersonAccount(){
      soql = 'SELECT ID, PersonEmail,Phone,PersonMobilePhone,Mobile_Standardized__pc,Phone_Standardized__pc FROM ACCOUNT where isPersonAccount=true and Booking_Exists__pc=true and Is_Duplicate__pc=true  order by LastModifiedDate Asc'; //  and PersonEmail=\'rpdemo@abc.com\'
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(soql);
   }

   global void execute(Database.BatchableContext BC, List<Account> lst){       
       MergePersonAccountHandler.MergePersonAccount(lst); 
   }

   global void finish(Database.BatchableContext BC){
   }
}