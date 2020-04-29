public without sharing class RollupContact {
  @InvocableMethod(
    label='Rollup Contact'
    description='Rollup works based on billing contact and guest contact id on Booking'
  )
  public static void fnRollupcontact(List<wrpRollupContact> lstwrp) {
    Set<Id> setContactIds = new Set<Id>();
    for (wrpRollupContact wrp : lstwrp) {
      if (String.isNotBlank(wrp.contactId)) {
        setContactIds.add((Id) wrp.contactId);
      }
      if (String.isNotBlank(wrp.guestcontactId)) {
        setContactIds.add((Id) wrp.guestcontactId);
      }
    }

    system.debug('setContactIds@@@@@ ' + setContactIds);

    Map<Id, Contact> mapContact = new Map<Id, Contact>();
    for (Contact c : [
      SELECT
        id,
        Bookings_Count__c,
        Guest_Bookings_Count__c,
        Total_Spend__c,
        (
          SELECT id, Billing_Contact__c, Total_taxed__c
          FROM Xotelia_Bookings1__r
          WHERE Status__c = 'Active'
        ),
        (
          SELECT id, Total_taxed__c, Guest_Contact__c
          FROM Xotelia_Bookings__r
          WHERE Status__c = 'Active'
        )
      FROM contact
      WHERE Id IN :setContactIds
    ]) {
      system.debug('setContactIds@@@@@ ' + c.Id);

      Contact objcon = new Contact(Id = c.Id, Total_Spend__c = 0);
      for (Xotelia_Booking__c bc : c.Xotelia_Bookings1__r) {
        // Billing Contact
        if (bc.Total_taxed__c != null && bc.Total_taxed__c > 0) {
          objcon.Total_Spend__c += bc.Total_taxed__c;
        }
      }

      Integer count = 0;
      for (Xotelia_Booking__c c2 : c.Xotelia_Bookings1__r) {
        count++;
      }
      objcon.Bookings_Count__c = count;

      Integer count1 = 0;
      for (Xotelia_Booking__c c1 : c.Xotelia_Bookings__r) {
        count1++;
      }
      objcon.Guest_Bookings_Count__c = count1;
      mapContact.put(c.Id, objcon);
    }

    system.debug('mapContact@@@@@ ' + mapContact);

    if (mapContact.size() > 0) {
      //update mapContact.values();
      Database.SaveResult[] srList = Database.update(
        mapContact.values(),
        false
      );
      String errorMessage = '';
      Integer intexception = 0;
      for (Database.SaveResult sr : srList) {
        if (sr.isSuccess()) {
        } else {
          errorMessage =
            'Hi Salesforce Admin,<br/><br/>' +
            'Following error occured while updating the contact record via Rollup on Billing Contact Flow:<br/> <br/>';

          // Operation failed, so get all errors
          for (Database.Error err : sr.getErrors()) {
            errorMessage +=
              'Update failed for Id: ' +
              sr.getId() +
              ' - Reason(s): <br/> <br/>';
            errorMessage +=
              err.getStatusCode() +
              ': ' +
              err.getMessage() +
              '<br/> <br/>';
          }
        }
        intexception++;
      }
      if (String.isNotBlank(errorMessage) || Test.IsrunningTest()) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List<String> lstToAddress = new List<String>();
        for (String str : label.BookingValidationEmails.split(',')) {
          if (!string.isblank(str)) {
            lstToAddress.add(str.trim());
          }
        }
        message.setToAddresses(lstToAddress);
        message.setReplyTo('noreply@barsala.com');
        message.setSenderDisplayName('Barsala Support');
        message.setSubject('Rollup on Billing Contact Exception');
        message.setHtmlBody(errorMessage);
        mails.add(message);

        Messaging.sendEmail(mails);
      }
    }
  }

  public class wrpRollupContact {
    @InvocableVariable(required=true)
    public String contactId;

    @InvocableVariable
    public string guestcontactId;
  }
}