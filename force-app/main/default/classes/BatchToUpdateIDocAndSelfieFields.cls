global class BatchToUpdateIDocAndSelfieFields implements Database.Batchable<sObject>, Database.AllowsCallouts {
  public String query;

  global BatchToUpdateIDocAndSelfieFields() {
    this.query = 'select id from Account where ispersonaccount=true and Is_Sync_Image_Process__c=true';
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Account> lst) {
    //,(select id,sharinpix__FileName__c,sharinpix__ImageURLOriginal__c  from sharinpix__SharinPix_Images__r)
    Map<Id, List<sharinpix__SharinPixImage__c>> mapAccvsSharinpixImgList = new Map<Id, List<sharinpix__SharinPixImage__c>>();
    for (sharinpix__SharinPixImage__c simg : [
      SELECT
        id,
        sharinpix__FileName__c,
        sharinpix__ImageURLOriginal__c,
        sharinpix__Account__c
      FROM sharinpix__SharinPixImage__c
      WHERE sharinpix__Account__c IN :lst
    ]) {
      if (mapAccvsSharinpixImgList.containsKey(simg.sharinpix__Account__c)) {
        mapAccvsSharinpixImgList.get(simg.sharinpix__Account__c).add(simg);
      } else {
        mapAccvsSharinpixImgList.put(
          simg.sharinpix__Account__c,
          new List<sharinpix__SharinPixImage__c>{ simg }
        );
      }
    }

    Map<Id, Account> mapAcc = new Map<Id, Account>();
    for (Account a : lst) {
      Account objacc = new Account(Id = a.Id);
      if (mapAccvsSharinpixImgList.containsKey(a.Id)) {
        for (
          sharinpix__SharinPixImage__c img : mapAccvsSharinpixImgList.get(a.Id)
        ) {
          if (
            img.sharinpix__FileName__c.startsWith('Government-Issued-ID-') &&
            img.sharinpix__FileName__c.contains('-Selfie') == false
          ) {
            objacc.IDoc_file_id__pc = img.sharinpix__ImageURLOriginal__c;
          } else if (
            img.sharinpix__FileName__c.startsWith('Government-Issued-ID-') &&
            img.sharinpix__FileName__c.contains('-Selfie') == true
          ) {
            objacc.IDSelfie_file_id__pc = img.sharinpix__ImageURLOriginal__c;
          }
          mapAcc.put(a.Id, objacc);
        }
      }
    }
    system.debug('Account@@@@@' + mapAcc.values());
    if (mapAcc.size() > 0) {
      update mapAcc.values();
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}