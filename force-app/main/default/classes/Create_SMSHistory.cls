global without sharing class Create_SMSHistory {
  @InvocableMethod
  global static void createSMSHistory(List<wrpsmshistory> lst) {
    List<smagicinteract__smsMagic__c> lstSMS = new List<smagicinteract__smsMagic__c>();
    for (wrpsmshistory wrp : lst) {
      String senderId = wrp.senderPhoneNumber; // Please replace the 'smsMagic' with your relevant sender ID.
      //String senderId = '';
      String templateText = wrp.smsText; // you can fetch the template text by querying the record on smagicinteract__SMS_Template__c object

      smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
      smsObject.smagicinteract__SenderId__c = senderId;
      smsObject.smagicinteract__PhoneNumber__c = wrp.recepientPhoneNumber;
      smsObject.smagicinteract__Name__c = 'Barsala'; // records name
      smsObject.smagicinteract__ObjectType__c = 'Contact'; // record type
      smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
      smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
      smsObject.smagicinteract__SMSText__c = templateText;
      smsObject.smagicinteract__Contact__c = wrp.contactId;
      lstSMS.add(smsObject);
    }

    if (lstSMS.size() > 0) {
      insert lstSMS;
    }
  }

  global class wrpsmshistory {
    @InvocableVariable
    global String senderPhoneNumber;

    @InvocableVariable
    global String smsText;

    @InvocableVariable
    global String recepientPhoneNumber;

    @InvocableVariable
    global Id contactId;
  }
}