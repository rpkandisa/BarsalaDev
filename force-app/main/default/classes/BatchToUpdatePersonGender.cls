global class BatchToUpdatePersonGender implements Database.Batchable<sObject>, Database.AllowsCallouts {
  public String query;

  global BatchToUpdatePersonGender() {
    this.query = 'select id,FirstName from Account where ispersonaccount=true and FirstName != null';

    //this.query = 'select id,FirstName from Account where ispersonaccount=true and FirstName != null and id in(\'0013K000002d24e\',\'0013K000002e74Q\')';
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Account> lst) {
    Set<Id> accids = new Set<Id>();
    for (Account a : lst) {
      if (String.isNotBlank(a.FirstName)) {
        accids.add(a.Id);
      }
    }
    if (accids.size() > 0) {
      AccountTriggerHandler.GenderizeAPICalloutWithoutFuture(accids);
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}