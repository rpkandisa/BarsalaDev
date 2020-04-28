global class BatchForBuildingUnitPriceOnUnitPrice implements Database.Batchable<sObject> {
  public String query;

  global BatchForBuildingUnitPriceOnUnitPrice() {
    this.query = 'SELECT id, Building_Unit_Set__c, Price_Date__c FROM Building_Unit_Set_Pricing__c';
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(
    Database.BatchableContext BC,
    List<Building_Unit_Set_Pricing__c> lst
  ) {
    ProcessBuildingUnitPricing.ProcessToSetUnitPriceRecord(lst);
  }

  global void finish(Database.BatchableContext BC) {
  }
}