/**
 * We are comparing Unit Price of Barsala_Price_Modeled_Final__c and Barsala_Price_Modeled_Final_Copy__c field and if both the fields value does not matach then we need to update Barsala_Price_Modeled_Final_Copy__c field value from Barsala_Price_Modeled_Final__c
 */

global class BatchToUpdateBarsalaPriceModel implements Database.Batchable<sObject>,Schedulable {

    global void execute(SchedulableContext SC) {
        BatchToUpdateBarsalaPriceModel b = new BatchToUpdateBarsalaPriceModel(); 
        Database.executebatch(b,200);
     }

    public String query;
  
    global BatchToUpdateBarsalaPriceModel() {
      this.query = 'select id,Barsala_Price_Modeled_Final__c,Barsala_Price_Modeled_Final_Copy__c from Unit_Pricing__c where UNITPRICE_DATE__c >= LAST_YEAR ';
    }
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(query);
    }
  
    global void execute(Database.BatchableContext BC, List<Unit_Pricing__c> lst) {
        List<Unit_Pricing__c> lstUpdate = new List<Unit_Pricing__c>();
        for(Unit_Pricing__c objup : lst){
            if(objup.Barsala_Price_Modeled_Final__c != objup.Barsala_Price_Modeled_Final_Copy__c){
                lstUpdate.add(new Unit_Pricing__c(Id = objup.Id, Barsala_Price_Modeled_Final_Copy__c = objup.Barsala_Price_Modeled_Final__c));
            }
        }

        if(!lstUpdate.isEmpty() && lstUpdate.size() > 0){
            Database.update(lstUpdate, false);
        }
    }
  
    global void finish(Database.BatchableContext BC) {
    }
  }