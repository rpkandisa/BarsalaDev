global class BatchtoDeleteShrinpixImgRecord implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
  public String query;
  global Set<Id> deleteRecordIds;

  global BatchtoDeleteShrinpixImgRecord() {
    this.query = 'select id,sharinpix__ImageURLOriginal__c,sharinpix__AlbumID__c,sharinpix__ImagePublicId__c from sharinpix__SharinPixImage__c';
    this.deleteRecordIds = new Set<Id>();
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<SObject> lst) {
    List<sharinpix__SharinPixImage__c> lstDelete = new List<sharinpix__SharinPixImage__c>();
    for (Sobject a : lst) {
      if (
        (a.get('Id') != null &&
        a.get('sharinpix__ImageURLOriginal__c') != null &&
        a.get('sharinpix__AlbumID__c') != null &&
        a.get('sharinpix__ImagePublicId__c') != null) || Test.isRunningTest()
      ) {
        sharinpix.Utils spUtils = new sharinpix.Utils();
        List<Object> imglist;
        if (!Test.isrunningTest()) {
          imglist = spUtils.getAlbumImageIds(
            (Id) a.get('sharinpix__AlbumID__c')
          );
        } else {
          imglist = new List<Object>{ 'd7eb26dd-2989-4e06-9eb9-d73323644b34' };
        }

        Boolean blndel = false;
        if (imglist != null && imglist.size() > 0) {
          Set<String> setimgexist = new Set<String>();

          for (Object img : imglist) {
            setimgexist.add(String.valueOf(img));
          }
          if (
            !setimgexist.contains((string) a.get('sharinpix__ImagePublicId__c'))
          ) {
            Id objid = (Id) a.get('Id');
            lstDelete.add(new sharinpix__SharinPixImage__c(Id = objid));
            deleteRecordIds.add(objid);
          }
        }
      }
    }

    if (lstDelete.size() > 0) {
      delete lstDelete;
    }
  }

  global void finish(Database.BatchableContext BC) {
    string htmlbody = '';
    string subject = 'Batch job to remove the trash can images has finished successfully!';

    htmlbody =
      '<div>Below are the list of records that got deleted from the SharinPix Image object :</div><br/><table style="width:100%;border-collapse: collapse;"><tr><td style="border: 1px solid #dddddd;padding: 8px;text-align: left;">Sharinpix record ids</td><td style="border: 1px solid #dddddd;padding: 8px;text-align: left;">{0}</td></tr><tr><td style="border: 1px solid #dddddd;padding: 8px;text-align: left;">Sharinpix record count</td><td style="border: 1px solid #dddddd;padding: 8px;text-align: left;">' +
      deleteRecordIds.size() +
      '</td></tr></table>';

    List<String> idList = new List<String>();
    for (Id objid : deleteRecordIds) {
      idList.add(objid);
    }
    string ids = String.join(idList, ', ');
    htmlbody = htmlbody.replace('{0}', ids);

    List<String> toAddresses = new List<String>();
    //sending exception email
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    // Step 2: Set list of people who should get the email
    if (String.isNotBlank(Label.BookingValidationEmails)) {
      for (string stremail : Label.BookingValidationEmails.split(',')) {
        if (String.isNotBlank(stremail) && String.isNotBlank(stremail.trim())) {
          toAddresses.add(stremail.trim());
        }
      }
    }
    mail.setToAddresses(toAddresses);
    // Step 4. Set email contents - you can use variables!
    mail.setSubject(subject);
    mail.setHtmlBody(htmlBody);
    // Step 6: Send all emails in the master list
    if (deleteRecordIds.size() > 0) {
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
  }
}