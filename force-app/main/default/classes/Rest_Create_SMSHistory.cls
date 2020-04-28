@RestResource(urlMapping='/send_message/*')
global with sharing class Rest_Create_SMSHistory {
  @HttpPost
  global static void createSMSHistory() {
    Set<Id> smsIds = new Set<Id>();
    List<String> lstErrors = new List<String>();
    String responseJSON = '';

    RestRequest req = RestContext.request;
    System.debug(req);
    blob b = req.requestBody;
    string jsonStr = b.toString();

    try {
      List<SMSHistoryDetailsWrapper> lstSMSHistoryDetailsWrap = (List<SMSHistoryDetailsWrapper>) JSON.deserialize(
        jsonStr,
        List<SMSHistoryDetailsWrapper>.class
      );
      System.debug('lstSMSHistoryDetailsWrap : ' + lstSMSHistoryDetailsWrap);

      if (
        lstSMSHistoryDetailsWrap != null &&
        lstSMSHistoryDetailsWrap.size() > 0
      ) {
        Set<Id> accountIds = new Set<Id>();
        Integer count = 0;
        String ErrorMsg = '';
        List<RESTResponseWrapper> lstValidationRest = new List<RESTResponseWrapper>();
        for (SMSHistoryDetailsWrapper sms : lstSMSHistoryDetailsWrap) {
          RESTResponseWrapper restResWrap = new RESTResponseWrapper();

          restResWrap.sms = new SMSHistory();
          restResWrap.sms.senderPhoneNumber = sms.senderPhoneNumber;
          if (
            String.isBlank(sms.senderPhoneNumber) ||
            !sms.senderPhoneNumber.isNumeric() ||
            (sms.senderPhoneNumber.length() != 10 &&
            sms.senderPhoneNumber.length() != 11)
          ) {
            ErrorMsg += 'Invalid Sender PhoneNumber. ';
          }

          if (String.isNotBlank(sms.messageType) && sms.messageType == 'SMS') {
            restResWrap.sms.smsText = sms.smsText;
            if (String.isBlank(sms.smsText)) {
              ErrorMsg += 'SMS Text is mandatory. ';
            }
          }

          restResWrap.sms.messageType = sms.messageType;
          if (String.isBlank(sms.messageType)) {
            ErrorMsg += 'MessageType is null.';
          }
          // else if (
          //   sms.messageType == 'MMS' && String.isBlank(sms.mmsDetailName)
          // ) {
          //   restResWrap.sms.mms = new MMSDetail();
          //   restResWrap.sms.mms.mmsDetailName = sms.mmsDetailName;
          //   restResWrap.sms.mms.mmsURL = sms.mmsURL;
          //   restResWrap.sms.mms.messageType = 'MMS';
          //   ErrorMsg += 'mmsDetailName is mandatory for MMS messageType. ';
          // }

          restResWrap.sms.recipientPhoneNumber = sms.recipientPhoneNumber;
          if (String.isBlank(sms.recipientPhoneNumber)) {
            ErrorMsg += 'Invalid Recipient PhoneNumber. ';
          }

          restResWrap.sms.personAccountId = sms.personAccountId;
          if (sms.personAccountId == null) {
            ErrorMsg += 'ContactId is mandatory. ';
          } else {
            accountIds.add(sms.personAccountId);
          }

          if (String.isNotBlank(ErrorMsg)) {
            restResWrap.status = 'ERROR';
            restResWrap.statusDescription = ErrorMsg;
            lstValidationRest.add(restResWrap);
          }
          ErrorMsg = '';
          count++;
        }

        System.debug('ErrorMsg : ' + ErrorMsg);
        if (lstValidationRest != null && lstValidationRest.size() > 0) {
          responseJSON = stripJsonNulls(JSON.serialize(lstValidationRest));
          RestResponse res = RestContext.response;
          if (!Test.isRunningTest()) {
            res.responseBody = Blob.valueOf(responseJSON);
            res.statusCode = 400;
          }
        } else {
          System.debug('@@@@accountids@@@ ' + accountids);

          Map<Id, Id> mapAccIdvsContact = new Map<Id, Id>();
          for (Account acc : [
            SELECT Id, PersoncontactId
            FROM account
            WHERE Id IN :accountIds
          ]) {
            mapAccIdvsContact.put(acc.Id, acc.PersonContactId);
          }

          List<smagicinteract__smsMagic__c> lstSMS = new List<smagicinteract__smsMagic__c>();
          Map<Integer, smagicinteract__smsMagic__c> mapIntToSMS = new Map<Integer, smagicinteract__smsMagic__c>();
          Integer i = 0;
          for (SMSHistoryDetailsWrapper sms : lstSMSHistoryDetailsWrap) {
            smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
            smsObject.smagicinteract__SenderId__c = sms.senderPhoneNumber;
            smsObject.smagicinteract__PhoneNumber__c = sms.recipientPhoneNumber;
            smsObject.smagicinteract__Name__c = 'Barsala'; // records name
            smsObject.smagicinteract__ObjectType__c = 'Contact'; // record type
            smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
            smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
            smsObject.smagicinteract__SMSText__c = sms.smsText;
            if (String.isNotBlank(sms.automatedMessageType)) {
              smsObject.Automated_Message_Type__c = sms.automatedMessageType;
            }

            if (mapAccIdvsContact.containsKey(sms.personAccountId)) {
              smsObject.smagicinteract__Contact__c = mapAccIdvsContact.get(
                sms.personAccountId
              );
            } else {
              smsObject.smagicinteract__Contact__c = sms.personAccountId;
            }

            if (
              String.IsNotBlank(sms.messageType) &&
              sms.messageType.toUpperCase() == 'MMS'
            ) {
              smsObject.smagicinteract__Message_Type__c = sms.messageType;
            } else {
              smsObject.smagicinteract__Message_Type__c = 'SMS';
            }

            //lstSMS.add(smsObject);
            mapIntToSMS.put(i, smsObject);
            i++;
          }

          Map<Integer, RESTResponseWrapper> mapRESTResponseWrapper = new Map<Integer, RESTResponseWrapper>();
          if (mapIntToSMS.size() > 0) {
            //Insert mapIntToSMS.values();

            Integer index = 0;
            Map<Integer, smagicinteract__MMS_Detail__c> mapMMS = new Map<Integer, smagicinteract__MMS_Detail__c>();

            Database.SaveResult[] srList = Database.insert(
              mapIntToSMS.values(),
              false
            );
            for (Database.SaveResult sr : srList) {
              if (sr.isSuccess()) {
                // successful
                System.debug('Successfully SMSHistory ID: ' + sr.getId());
                smsIds.add(sr.getId());

                RESTResponseWrapper respWrap = new RESTResponseWrapper();
                respWrap.status = 'SUCCESS';

                SMSHistory smsWrap = new SMSHistory();
                smsWrap.smsHistoryId = sr.getId();

                smsWrap.senderPhoneNumber = lstSMSHistoryDetailsWrap[index]
                  .senderPhoneNumber;
                smsWrap.smsText = lstSMSHistoryDetailsWrap[index].smsText;
                smsWrap.recipientPhoneNumber = lstSMSHistoryDetailsWrap[index]
                  .recipientPhoneNumber;
                smsWrap.personAccountId = lstSMSHistoryDetailsWrap[index]
                  .personAccountId;
                smsWrap.messageType = lstSMSHistoryDetailsWrap[index]
                  .messageType;

                if (
                  String.isNotBlank(
                    lstSMSHistoryDetailsWrap[index].automatedMessageType
                  )
                ) {
                  smsWrap.automatedMessageType = lstSMSHistoryDetailsWrap[index]
                    .automatedMessageType;
                }
                respWrap.sms = smsWrap;

                if (
                  String.IsNotBlank(
                    lstSMSHistoryDetailsWrap[index].messageType
                  ) &&
                  lstSMSHistoryDetailsWrap[index].messageType.toUpperCase() ==
                  'MMS'
                ) {
                  smagicinteract__MMS_Detail__c mms = new smagicinteract__MMS_Detail__c();
                  mms.smagicinteract__SMS_History__c = sr.getId();
                  mms.smagicinteract__MMS_Type__c = 'External';
                  mms.smagicinteract__MMS_Url__c = lstSMSHistoryDetailsWrap[
                      index
                    ]
                    .mmsURL;
                  //mms.Name = lstSMSHistoryDetailsWrap[index].mmsDetailName;
                  mms.Name = generateRandomString();

                  mapMMS.put(index, mms);
                }

                mapRESTResponseWrapper.put(index, respWrap);
              } else {
                //failed
                for (Database.Error err : sr.getErrors()) {
                  RESTResponseWrapper respWrap = new RESTResponseWrapper();
                  respWrap.status = 'ERROR';
                  respWrap.statusDescription =
                    err.getStatusCode() +
                    ': ' +
                    err.getMessage();

                  SMSHistory smsWrap = new SMSHistory();
                  smsWrap.senderPhoneNumber = lstSMSHistoryDetailsWrap[index]
                    .senderPhoneNumber;
                  smsWrap.smsText = lstSMSHistoryDetailsWrap[index].smsText;
                  smsWrap.recipientPhoneNumber = lstSMSHistoryDetailsWrap[index]
                    .recipientPhoneNumber;
                  smsWrap.personAccountId = lstSMSHistoryDetailsWrap[index]
                    .personAccountId;
                  smsWrap.messageType = lstSMSHistoryDetailsWrap[index]
                    .messageType;
                  if (
                    String.isNotBlank(
                      lstSMSHistoryDetailsWrap[index].automatedMessageType
                    )
                  ) {
                    smsWrap.automatedMessageType = lstSMSHistoryDetailsWrap[
                        index
                      ]
                      .automatedMessageType;
                  }
                  respWrap.sms = smsWrap;
                  mapRESTResponseWrapper.put(index, respWrap);
                }
              }
              index++;
            }

            if (mapMMS.size() > 0) {
              Database.SaveResult[] srListMMS = Database.insert(
                mapMMS.values(),
                false
              );

              for (Integer idx : mapRESTResponseWrapper.keyset()) {
                RESTResponseWrapper wrpRest = mapRESTResponseWrapper.get(idx);

                for (Database.SaveResult srVar : srListMMS) {
                  if (
                    mapMMS.containsKey(idx) &&
                    wrpRest.sms.smsHistoryId ==
                    mapMMS.get(idx).smagicinteract__SMS_History__c
                  ) {
                    if (srVar.isSuccess()) {
                      MMSDetail mms = new MMSDetail();
                      mms.mmsHistoryId = srVar.getId();
                      mms.messageType = 'MMS';
                      //mms.mmsDetailName = mapMMS.get(idx).Name;
                      //mms.mmsDetailName = generateRandomString();
                      mms.mmsURL = mapMMS.get(idx).smagicinteract__MMS_Url__c;
                      wrpRest.sms.mms = mms;
                    }
                  }
                }
              }
            }

            if (smsIds.size() > 0) {
              fnPopulateBookingId(smsids);
            }
          }
          RestResponse res = RestContext.response;
          //System.debug('res: ' + res);
          responseJSON = stripJsonNulls(
            JSON.serialize(mapRESTResponseWrapper.values())
          ); //'SMSHistory created Successfully.';
          //System.debug('responseJSON: ' + responseJSON);
          if (!Test.isRunningTest()) {
            res.statusCode = 201;
            res.responseBody = Blob.valueOf(responseJSON);
          }
        }
      }
    } catch (Exception ex) {
      System.debug('Exception: ' + ex.getLineNumber() + ' ' + ex.getMessage());
      RestResponse res = RestContext.response;
      responseJSON = 'Exception: ' + ex.getMessage();
      res.responseBody = Blob.valueOf(responseJSON);
    }

    //System.debug('responseJSON: ' + responseJSON);
    //return responseJSON;
  }

  public static void fnPopulateBookingId(Set<Id> smsids) {
    Set<Id> setContactIds = new Set<Id>();
    List<smagicinteract__smsMagic__c> lstSMS = new List<smagicinteract__smsMagic__c>(
      [
        SELECT id, smagicinteract__Contact__c
        FROM smagicinteract__smsMagic__c
        WHERE id IN :smsIds
      ]
    );

    for (smagicinteract__smsMagic__c o : lstSMS) {
      setContactIds.add(o.smagicinteract__Contact__c);
    }

    if (setContactIds.size() > 0) {
      //map contains booking with Guest_ContactID, which lies between today date
      Map<Id, Xotelia_Booking__c> guestBookingMap = new Map<Id, Xotelia_Booking__c>();
      //map contains booking with Billing_ContactID, which lies between today date
      Map<Id, Xotelia_Booking__c> billingBookingMap = new Map<Id, Xotelia_Booking__c>();

      for (Xotelia_Booking__c booking : [
        SELECT
          id,
          Updated_Email__c,
          Guest_Contact__c,
          Guest_Contact__r.Email,
          Billing_Contact__c,
          Billing_Contact__r.Email,
          Start_Date__c,
          End_Date__c
        FROM Xotelia_Booking__c
        WHERE
          Start_Date__c <= TODAY
          AND End_Date__c >= TODAY
          AND (Guest_Contact__c IN :setContactIds
          OR Billing_Contact__c IN :setContactIds)
        ORDER BY Start_Date__c DESC, CreatedDate DESC
      ]) {
        if (booking.Guest_Contact__c != null)
          guestBookingMap.put(booking.Guest_Contact__c, booking);

        if (booking.Billing_Contact__c != null)
          billingBookingMap.put(booking.Billing_Contact__c, booking);
      }

      // if any map does finds the matcing contact id, we associate their booking with Task
      for (smagicinteract__smsMagic__c t : lstSMS) {
        if (guestBookingMap.containsKey(t.smagicinteract__Contact__c)) {
          t.Booking__c = guestBookingMap.get(t.smagicinteract__Contact__c).Id;
          //removing contact ids which are matched, so no need to process them in #2 process
          setContactIds.remove(t.smagicinteract__Contact__c);
        } else if (
          billingBookingMap.containsKey(t.smagicinteract__Contact__c)
        ) {
          t.Booking__c = billingBookingMap.get(t.smagicinteract__Contact__c).Id;
          //removing contact ids which are matched, so no need to process them in #2 process
          setContactIds.remove(t.smagicinteract__Contact__c);
        }
      }

      if (setContactIds.size() > 0) {
        for (Xotelia_Booking__c booking : [
          SELECT
            id,
            Updated_Email__c,
            Guest_Contact__c,
            Guest_Contact__r.Email,
            Billing_Contact__c,
            Billing_Contact__r.Email,
            Start_Date__c,
            End_Date__c
          FROM Xotelia_Booking__c
          WHERE
            Guest_Contact__c IN :setContactIds
            OR Billing_Contact__c IN :setContactIds
          ORDER BY Start_Date__c DESC, CreatedDate DESC
        ]) {
          if (booking.Guest_Contact__c != null) {
            if (!guestBookingMap.containsKey(booking.Guest_Contact__c))
              guestBookingMap.put(booking.Guest_Contact__c, booking);
            else if (
              booking.Start_Date__c > Date.Today() &&
              booking.Start_Date__c <=
              guestBookingMap.get(booking.Guest_Contact__c).Start_Date__c
            )
              guestBookingMap.put(booking.Guest_Contact__c, booking);
          }

          if (booking.Billing_Contact__c != null) {
            if (!billingBookingMap.containsKey(booking.Billing_Contact__c))
              billingBookingMap.put(booking.Billing_Contact__c, booking);
            else if (
              booking.Start_Date__c > Date.Today() &&
              booking.Start_Date__c <=
              billingBookingMap.get(booking.Billing_Contact__c).Start_Date__c
            )
              billingBookingMap.put(booking.Billing_Contact__c, booking);
          }
        }

        for (smagicinteract__smsMagic__c t : lstSMS) {
          if (guestBookingMap.containsKey(t.smagicinteract__Contact__c)) {
            t.Booking__c = guestBookingMap.get(t.smagicinteract__Contact__c).Id;
            //removing contact ids which are matched, so no need to process them in #2 process
            setContactIds.remove(t.smagicinteract__Contact__c);
          } else if (
            billingBookingMap.containsKey(t.smagicinteract__Contact__c)
          ) {
            t.Booking__c = billingBookingMap.get(t.smagicinteract__Contact__c)
              .Id;
            //removing contact ids which are matched, so no need to process them in #2 process
            setContactIds.remove(t.smagicinteract__Contact__c);
          }
        }
      }

      if (lstSMS.size() > 0) {
        update lstSMS;
      }
    }
  }

  public static String generateRandomString() {
    Blob blobKey = crypto.generateAesKey(128);
    String key = EncodingUtil.convertToHex(blobKey);
    return key;
  }

  public static string stripJsonNulls(string JsonString) {
    if (JsonString != null) {
      JsonString = JsonString.replaceAll('"[^"]*":null', ''); //basic removeal of null values
      JsonString = JsonString.replaceAll(',{2,}', ','); //remove duplicate/multiple commas
      JsonString = JsonString.replace('{,', '{'); //prevent opening brace from having a comma after it
      JsonString = JsonString.replace(',}', '}'); //prevent closing brace from having a comma before it
      JsonString = JsonString.replace('[,', '['); //prevent opening bracket from having a comma after it
      JsonString = JsonString.replace(',]', ']'); //prevent closing bracket from having a comma before it
    }
    return JsonString;
  }

  public class SMSHistoryDetailsWrapper {
    public String senderPhoneNumber;
    public String smsText;
    public String recipientPhoneNumber;
    public Id personAccountId;
    public String messageType; //It's a type of message such as MMS or SMS
    public String mmsDetailName; //It should be any value
    public String mmsURL; //It should be a publicly available
    public String automatedMessageType; //If the message is coming from an automated marketing campaign, this will be populated with what kind of campaign it came from
  }

  public class RESTResponseWrapper {
    public String status; //SUCCESS OR ERROR
    public String statusDescription;
    public SMSHistory sms;
  }

  public class SMSHistory {
    public Id smsHistoryId;
    public String senderPhoneNumber;
    public String smsText;
    public String recipientPhoneNumber;
    public Id personAccountId;
    public String messageType;
    public String automatedMessageType;
    public MMSDetail mms;
  }

  public class MMSDetail {
    public Id mmsHistoryId;
    public String messageType;
    public String mmsDetailName;
    public String mmsURL;
  }
}