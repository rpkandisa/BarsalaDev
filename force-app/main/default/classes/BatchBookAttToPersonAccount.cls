global class BatchBookAttToPersonAccount implements Database.Batchable<sObject>, Database.AllowsCallouts {
  public String query;
  public Boolean isIdoc = false;

  global BatchBookAttToPersonAccount() {
    this.query = 'Select id,IDoc_file_id__c,IDSelfie_file_id__c,Guest_Contact__c,Guest_Contact__r.Account.name,Guest_Contact__r.AccountId,Guest_Contact__r.IDoc_file_id__c,Guest_Contact__r.IDSelfie_file_id__c from Xotelia_Booking__c where (IDoc_file_id__c like \'00P%\' or IDSelfie_file_id__c like \'00P%\' ) and (Guest_Contact__r.IDoc_file_id__c = null Or Guest_Contact__r.IDSelfie_file_id__c = null) ';

    system.debug('qry#### ' + this.query);
    this.isIdoc = true;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(
    Database.BatchableContext BC,
    List<Xotelia_Booking__c> lst
  ) {
    try {
      for (Xotelia_Booking__c b : lst) {
        sharinpix.Utils utl = new sharinpix.Utils();
        if (isIdoc) {
          utl.uploadAttachment(b.IDoc_file_id__c, b.Guest_Contact__r.AccountId);
        } else {
          utl.uploadAttachment(
            b.IDSelfie_file_id__c,
            b.Guest_Contact__r.AccountId
          );
        }
      }
    } catch (Exception e) {
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}