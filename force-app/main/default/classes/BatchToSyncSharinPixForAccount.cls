global class BatchToSyncSharinPixForAccount implements Database.Batchable<sObject>, Database.AllowsCallouts {
  public String query;

  global BatchToSyncSharinPixForAccount() {
    this.query = 'select id from Account where ispersonaccount=true and Is_Sync_Image_Process__c=true';
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Account> lst) {
    for (Account a : lst) {
      try {
        if (!Test.isRunningTest()) {
          sharinpix.imageSyncMigration.resyncAlbum(a.Id);
        }
      } catch (Exception e) {
        system.debug('Account Exception@@@@@' + a);
        system.debug('Account Exception@@@@@' + e.getMessage());
      }
      a.Is_Sync_Image_Process__c = false;
    }
    system.debug('Account@@@@@' + lst);
    if (lst.size() > 0) {
      update lst;
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}