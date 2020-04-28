//Developed By Kandisa Technologies on 10-01-2020

global class BatchToUpdatePersonDataByBooking implements Database.Batchable<sObject>, Database.AllowsCallouts {
  public String soql;
  public Integer intFlagType;

  global BatchToUpdatePersonDataByBooking(Integer intFlagType) {
    this.soql = 'SELECT ID, IDSelfie_file_id__c,IDoc_file_id__c,Guest_Contact__c FROM Xotelia_Booking__c where Guest_Contact__r.isPersonAccount=true and (Guest_Contact__r.IDoc_file_id__c = \'\' Or  Guest_Contact__r.IDSelfie_file_id__c = \'\')  and (IDSelfie_file_id__c != null or IDoc_file_id__c != null) ';

    string strlbl = label.BatchLimit;
    if (strlbl.contains('.') == false) {
      this.soql += ' limit ' + strlbl;
    }

    //this.soql = 'SELECT ID, IDSelfie_file_id__c,IDoc_file_id__c,Guest_Contact__c FROM Xotelia_Booking__c where id = \'a003K000000xMLOQA2\'';
    this.intFlagType = intFlagType;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(soql);
  }

  global void execute(
    Database.BatchableContext BC,
    List<Xotelia_Booking__c> lst
  ) {
    set<Id> conids = new Set<Id>();
    for (Xotelia_Booking__c o : lst) {
      if (o.Guest_Contact__c != null) {
        conids.add(o.Guest_Contact__c);
      }
    }

    Map<Id, Account> mapAccount = new Map<Id, Account>();
    for (Account a : [
      SELECT Id, Name, IDoc_file_id__pc, IDSelfie_file__pc, PersonContactId
      FROM Account
      WHERE PersonContactId IN :conids
    ]) {
      if (a.PersonContactId != null) {
        mapAccount.put(a.PersonContactId, a);
      }
    }

    List<Attachment> lstAtt = new List<Attachment>();
    for (Xotelia_Booking__c o : lst) {
      if (o.Guest_Contact__c != null) {
        Attachment att = new Attachment();

        if (
          intFlagType == 0 && String.isNotBlank(o.IDoc_file_id__c) &&
          (o.IDoc_file_id__c.toLowerCase()).startsWith('http')
        ) {
          att = new Attachment();
          att = BookingPersonIdentity.findImageOnBooking(
            o.Guest_Contact__c,
            o.IDoc_file_id__c,
            0
          );
          if (att != null && att.ParentId != null) {
            lstAtt.add(att);
          }
        }
        if (
          intFlagType == 1 && String.isNotBlank(o.IDSelfie_file_id__c) &&
          (o.IDSelfie_file_id__c.toLowerCase()).startsWith('http')
        ) {
          att = new Attachment();
          att = BookingPersonIdentity.findImageOnBooking(
            o.Guest_Contact__c,
            o.IDSelfie_file_id__c,
            1
          );
          if (att != null && att.ParentId != null) {
            lstAtt.add(att);
          }
        }
        if (intFlagType == 2 && mapAccount.containsKey(o.Guest_Contact__c)) {
          Account objAcc = mapAccount.get(o.Guest_Contact__c);
          string strnm =
            'Government-Issued-ID-' + objAcc.Name.replace(' ', '-');
          for (Attachment a : [
            SELECT id, parentid
            FROM attachment
            WHERE parentid = :objAcc.Id AND name = :strnm
          ]) {
            sharinpix.Utils utl = new sharinpix.Utils();
            if (!Test.isRunningTest()) {
              object s = utl.uploadAttachment(a.Id, objAcc.Id);
            }
          }
        }

        if (intFlagType == 3 && mapAccount.containsKey(o.Guest_Contact__c)) {
          Account objAcc = mapAccount.get(o.Guest_Contact__c);

          string strnmselfie =
            'Government-Issued-ID-Selfie-' + objAcc.Name.replace(' ', '-');
          for (Attachment a : [
            SELECT id, parentid
            FROM attachment
            WHERE parentid = :objAcc.Id AND name = :strnmselfie
          ]) {
            sharinpix.Utils utl = new sharinpix.Utils();
            if (!Test.isRunningTest()) {
              object s = utl.uploadAttachment(a.Id, objAcc.Id);
            }
          }
        }

        if (intFlagType == 4 && mapAccount.containsKey(o.Guest_Contact__c)) {
          Account objAcc = mapAccount.get(o.Guest_Contact__c);

          string strnm =
            'Government-Issued-ID-' + objAcc.Name.replace(' ', '-');
          for (Attachment a : [
            SELECT id, parentid
            FROM attachment
            WHERE parentid = :objAcc.Id AND name = :strnm
          ]) {
            if (!Test.isRunningTest()) {
              sharinpix.imageSyncMigration.resyncAlbum(objAcc.Id);
            }
          }
        }

        if (intFlagType == 5 && mapAccount.containsKey(o.Guest_Contact__c)) {
          Account objAcc = mapAccount.get(o.Guest_Contact__c);

          string strnmselfie =
            'Government-Issued-ID-Selfie-' + objAcc.Name.replace(' ', '-');
          for (Attachment a : [
            SELECT id, parentid
            FROM attachment
            WHERE parentid = :objAcc.Id AND name = :strnmselfie
          ]) {
            if (!Test.isRunningTest()) {
              sharinpix.imageSyncMigration.resyncAlbum(objAcc.Id);
            }
          }
        }

        if (intFlagType == 6 && mapAccount.containsKey(o.Guest_Contact__c)) {
          Account objAcc = mapAccount.get(o.Guest_Contact__c);

          string strnm =
            'Government-Issued-ID-' + objAcc.Name.replace(' ', '-');

          delete [
            SELECT id, parentid
            FROM attachment
            WHERE parentid = :objAcc.Id AND name = :strnm
          ];
        }

        if (intFlagType == 7 && mapAccount.containsKey(o.Guest_Contact__c)) {
          Account objAcc = mapAccount.get(o.Guest_Contact__c);

          string strnmselfie =
            'Government-Issued-ID-Selfie-' + objAcc.Name.replace(' ', '-');

          delete [
            SELECT id, parentid
            FROM attachment
            WHERE parentid = :objAcc.Id AND name = :strnmselfie
          ];
        }
      }
    }

    if (lstAtt.size() > 0) {
      AttachmentTriggerHelper.isquablecall = false;
      insert lstAtt;
    }
  }

  global void finish(Database.BatchableContext BC) {
    if (intFlagType == 0 && !Test.isRunningTest()) {
      BatchToUpdatePersonDataByBooking b = new BatchToUpdatePersonDataByBooking(
        1
      );
      Database.executeBatch(b, 1);
    } else if (intFlagType == 1 && !Test.isRunningTest()) {
      BatchToUpdatePersonDataByBooking b = new BatchToUpdatePersonDataByBooking(
        2
      );
      Database.executeBatch(b, 1);
    } else if (intFlagType == 2 && !Test.isRunningTest()) {
      BatchToUpdatePersonDataByBooking b = new BatchToUpdatePersonDataByBooking(
        3
      );
      Database.executeBatch(b, 1);
    } else if (intFlagType == 3 && !Test.isRunningTest()) {
      BatchToUpdatePersonDataByBooking b = new BatchToUpdatePersonDataByBooking(
        4
      );
      Database.executeBatch(b, 1);
    } else if (intFlagType == 4 && !Test.isRunningTest()) {
      BatchToUpdatePersonDataByBooking b = new BatchToUpdatePersonDataByBooking(
        5
      );
      Database.executeBatch(b, 1);
    } else if (intFlagType == 5 && !Test.isRunningTest()) {
      BatchToUpdatePersonDataByBooking b = new BatchToUpdatePersonDataByBooking(
        6
      );
      Database.executeBatch(b, 20);
    } else if (intFlagType == 6 && !Test.isRunningTest()) {
      BatchToUpdatePersonDataByBooking b = new BatchToUpdatePersonDataByBooking(
        7
      );
      Database.executeBatch(b, 20);
    }
  }
}