global class BatchToCreateBuildingUnitSetPriceRecord implements Database.Batchable<sObject> {
  public String query;

  global BatchToCreateBuildingUnitSetPriceRecord() {
    this.query = 'select id,Name,Building__c,IsRecordProcess__c from Building_Unit_Set__c where Building__c != null and IsRecordProcess__c=false ';
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(
    Database.BatchableContext BC,
    List<Building_Unit_Set__c> lst
  ) {
    ProcessBuildingUnitPricing.processBuildingUnitSet(lst);
  }

  global void finish(Database.BatchableContext BC) {
  }
}