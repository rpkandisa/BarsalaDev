global class BatchtoDeleteShrinpixImages implements Database.Batchable<sObject>, Database.AllowsCallouts {
  public String query;

  global BatchtoDeleteShrinpixImages() {
    this.query = 'select id from Account where ispersonaccount=true and Is_Sync_Image_Process__c=true';
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<SObject> lst) {
    for (SObject a : lst) {
      if (a.get('Id') != null) {
        DeleteSharinpixImage.deleteImage((Id) a.get('Id'));
      }
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}