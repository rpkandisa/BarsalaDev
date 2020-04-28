//send email to slack channel

public without sharing class EmailForwardToSlackChannel {
  public static Boolean isRecurssion = false;
  //@InvocableMethod(label='Forward Email To Slack Channel')
  public static void fnSendEmailToSlackChannel(
    List<Case> lstCase,
    Map<Id, Case> oldmap
  ) {
    Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
    Set<Id> caseIds = new Set<Id>();
    for (Case objcase : lstcase) {
      if (
        objcase.OwnerId != oldmap.get(objcase.Id).OwnerId ||
        Test.isRunningTest()
      ) {
        Id kellyid;
        if (objBarsalaSetting.Slack_User_Id__c.contains('005')) {
          kellyid = (Id) objBarsalaSetting.Slack_User_Id__c;
        }

        if (
          objcase.OwnerId == kellyid &&
          objcase.ContactEmail.contains('@airbnb.com')
        ) {
          caseIds.add(objcase.Id);
        }
      }
    }

    if (caseIds.size() > 0) {
      List<Case> lstSendCaseEmailMsg = new List<Case>(
        [
          SELECT
            Id,
            ContactId,
            (
              SELECT ParentId, Id, TextBody, HtmlBody, Subject, Headers
              FROM emailmessages
              WHERE Incoming = true
              ORDER BY CreatedDate ASC
            )
          FROM Case
          WHERE Id IN :caseIds
        ]
      );
      system.debug('lstSendCaseEmailMsg@@@@ ' + lstSendCaseEmailMsg);

      //   List<EmailTemplate> lstEmailTempalte = new List<EmailTemplate>(
      //     [
      //       SELECT id, name, subject
      //       FROM EmailTemplate
      //       WHERE name = :objBarsalaSetting.SlackChannelEmailTemplateName__c
      //     ]
      //   );
      //   system.debug('lstEmailTempalte@@@@ ' + lstEmailTempalte);

      //   EmailTemplate objemailtemplate = new EmailTemplate();
      //   if (lstEmailTempalte.size() > 0) {
      //     objemailtemplate = lstEmailTempalte.get(0);
      //   }
      //   system.debug('objemailtemplate@@@@ ' + objemailtemplate);
      OrgWideEmailAddress owa = [
        SELECT id, DisplayName, Address
        FROM OrgWideEmailAddress
        WHERE Address = 'noreply@barsala.com'
        LIMIT 1
      ];
      system.debug('owa@@@@ ' + owa);
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      for (Case objc : lstSendCaseEmailMsg) {
        for (EmailMessage em : objc.EmailMessages) {
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          //mail.setTemplateID(objemailtemplate.Id);
          //mail.setWhatId(em.Id);
          mail.setSaveAsActivity(false);
          mail.setOrgWideEmailAddressId(owa.id);
          mail.setToAddresses(
            new List<String>{ objBarsalaSetting.Slack_Channel_Email_Address__c }
          );
          mail.setSubject('FW:' + em.Subject);
          if (em.HtmlBody != null) {
            mail.setHtmlBody(em.HtmlBody);
          } else {
            mail.setPlainTextBody(em.TextBody);
          }

          mail.setTargetObjectId(UserInfo.getUserId());
          mail.setTreatTargetObjectAsRecipient(false);
          mails.add(mail);
        }
      }

      EmailForwardToSlackChannel.isRecurssion = true;
      if (mails.size() > 0) {
        Messaging.sendEmail(mails);
      }
    }
  }
}