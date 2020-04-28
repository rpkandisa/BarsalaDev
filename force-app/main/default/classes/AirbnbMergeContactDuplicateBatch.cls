//Merge airbnb id records
//developed by kandisa tech on 21/10/2019
global class AirbnbMergeContactDuplicateBatch implements Database.Batchable<sObject>{
     public String soql;

   global AirbnbMergeContactDuplicateBatch(){
      soql = 'SELECT ID, PersonEmail,Phone,PersonMobilePhone,Airbnb_ID__pc FROM ACCOUNT where isPersonAccount=true and Is_Airbnb_Id_duplicate__pc=true  order by LastModifiedDate Asc'; //  and PersonEmail=\'rpdemo@abc.com\'
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(soql);
   }

   global void execute(Database.BatchableContext BC, List<Account> lst){       
       AirBnBMergePersonAccountHandler.MergePersonAccount(lst); 
   }

   global void finish(Database.BatchableContext BC){
   }
}