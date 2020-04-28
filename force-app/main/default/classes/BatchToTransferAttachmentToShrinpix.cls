//
global class BatchToTransferAttachmentToShrinpix implements Database.Batchable<sObject>, Database.AllowsCallouts {
  public String query;

  global BatchToTransferAttachmentToShrinpix() {
    this.query = 'select id,Name,Is_Sync_Image_Process__c,IDoc_file_id__pc,IDSelfie_file_id__pc,(select id,name from Attachments) from Account where ispersonaccount=true and Is_Sync_Image_Process__c=true ';
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Account> lst) {
    for (Account a : lst) {
      string strnm = 'Government-Issued-ID-' + a.Name.replace(' ', '-');
      string strnm1 = 'Government-Issued-ID-Selfie-' + a.Name.replace(' ', '-');
      for (Attachment att : a.Attachments) {
        if (att.Name == strnm || att.Name == strnm1) {
          sharinpix.Utils utl = new sharinpix.Utils();
          if (!Test.isRunningTest()) {
            utl.uploadAttachment(att.Id, a.Id);
          }
        }
      }
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}