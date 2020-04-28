global class SMS_Creation {
  @InvocableMethod
  global static void SMS_CreationAndCaseLookup(List<WrapperClass> wrap) {
    String SMSId;
    String ConFirstName;
    String SMSText;
    String OwnerId;

    String APIServiceAccountProfileId = (Barsala_Settings__c.getOrgDefaults())
      .API_Service_Account_ProfileId__c;

    for (WrapperClass w : wrap) {
      SMSId = w.SMSHistoryId;
      ConFirstName = w.FirstName;
      SMSText = w.SMSText;
      OwnerId = w.OwnerId;
    }

  

    smagicinteract__smsMagic__c CurrentSMS = new smagicinteract__smsMagic__c();
    List<smagicinteract__smsMagic__c> lstSMS = new List<smagicinteract__smsMagic__c>(
      [
        SELECT
          id,
          smagicinteract__PhoneNumber__c,
          smagicinteract__Direction__c,
          smagicinteract__Previous_Message__c,
          smagicinteract__Previous_Message__r.Automated_Message_Type__c
        FROM smagicinteract__smsMagic__c
        WHERE id = :SMSId
      ]
    );
    if (lstSMS.size() > 0) {
      CurrentSMS = lstSMS.get(0);
    }

    //need to check "Text forwarded from" text in smsText
    System.debug('@@@@SMSText!!!! ' + SMSText);
    
    string str = SMSText;
    String n = '';
    if(string.isNotBlank(str) && String.isNotBlank(CurrentSMS.smagicinteract__PhoneNumber__c) && (CurrentSMS.smagicinteract__PhoneNumber__c.endsWith('5560') || CurrentSMS.smagicinteract__PhoneNumber__c.endsWith('5128')) ){
        Integer intloopexclude = 0;
        for(string s : str.tolowercase().split('text forwarded from: ')){   
            if(intloopexclude < 1) {
              intloopexclude++;
              continue;
            }
            System.debug('@@@@split number !!!! ' + s);
            Integer intnum = 0;
            for (Integer i=0; i<s.trim().length(); i++) {
                if (s.substring(i, i+1).isNumeric()) {
                    n += s.substring(i, i+1);
                    
                }   
                System.debug('@@@@ n !!!! ' + n);

                if(intnum > 13){
                  break;
                }
                intnum++;
            }
        }    
    }

    string currentPhoneNumberOnSMS = CurrentSMS.smagicinteract__PhoneNumber__c;

    System.debug('@@@@db phone!!!! ' + CurrentSMS.smagicinteract__PhoneNumber__c);
    if(String.isNotBlank(n)){
      CurrentSMS.smagicinteract__PhoneNumber__c = n;
    }

    System.debug('@@@@new number!!!! ' + n);

    System.debug('@@@@Account!!!! ' + CurrentSMS.smagicinteract__PhoneNumber__c);

    // List<Contact> lstContact = new List<Contact>([SELECT id, Name, MobilePhone, Phone, (SELECT id, Status FROM Cases) FROM Contact WHERE  Phone_Standardized__c =: CurrentSMS.smagicinteract__PhoneNumber__c Order by CreatedDate asc limit 1 ]); //Mobile_Standardized__c =: CurrentSMS.smagicinteract__PhoneNumber__c OR

    List<Contact> lstContact = new List<Contact>(); //Mobile_Standardized__c =: CurrentSMS.smagicinteract__PhoneNumber__c OR
    lstContact = findAllContact(
      CurrentSMS.smagicinteract__PhoneNumber__c,
      true
    );

    Contact objContactPhoneUpdate = new Contact();

    Contact smsContact = new Contact();
    Case smsCase = new Case();

    if (lstContact == null || lstContact.isEmpty()) {
      System.debug('@@@@SMS Contact not found ');

      //booking phone filed find
      Id ContactBillingId = null;
      for (Xotelia_Booking__c bk : [
        SELECT
          id,
          New_Phone_Standardized__c,
          Phone_Standardized__c,
          Billing_Contact__c,
          Guest_Contact__c
        FROM Xotelia_Booking__c
        WHERE Phone_Standardized__c = :CurrentSMS.smagicinteract__PhoneNumber__c
        ORDER BY createddate DESC
        LIMIT 1
      ]) {
        ContactBillingId = bk.Billing_Contact__c;
      }

      if (ContactBillingId == null) {
        for (Xotelia_Booking__c bk : [
          SELECT
            id,
            New_Phone_Standardized__c,
            Phone_Standardized__c,
            Billing_Contact__c,
            Guest_Contact__c
          FROM Xotelia_Booking__c
          WHERE
            New_Phone_Standardized__c = :CurrentSMS.smagicinteract__PhoneNumber__c
          ORDER BY createddate DESC
          LIMIT 1
        ]) {
          ContactBillingId = bk.Guest_Contact__c;
        }
      }

      if (ContactBillingId == null) {
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
          .get('Person Account')
          .getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = personAccountRecordTypeId;
        acc.FirstName = ConFirstName;
        acc.LastName = CurrentSMS.smagicinteract__PhoneNumber__c;
        acc.Phone = CurrentSMS.smagicinteract__PhoneNumber__c;
        insert acc;

        lstContact = findAllContact(
          CurrentSMS.smagicinteract__PhoneNumber__c,
          true
        );
        if (lstContact.size() > 0) {
          smsContact = lstContact.get(0);
        }
      } else {
        lstContact = findAllContact(String.valueof(ContactBillingId), false);
        if (lstContact.size() > 0) {
          smsContact = lstContact.get(0);

          // if phone field does not populate on contact object then update smsphone value to populate on contact phone field
          if (String.isBlank(smsContact.Phone)) {
            objContactPhoneUpdate = new Contact(Id = smsContact.Id);
            objContactPhoneUpdate.Phone = CurrentSMS.smagicinteract__PhoneNumber__c;
            update objContactPhoneUpdate;
          }
        }
      }

      // smsContact = new Contact(FirstName = ConFirstName, LastName = 'SMS to Case ' + CurrentSMS.smagicinteract__PhoneNumber__c, Phone = CurrentSMS.smagicinteract__PhoneNumber__c);//MobilePhone = CurrentSMS.smagicinteract__PhoneNumber__c
      // insert smsContact;
    } else if (lstContact.size() > 0) {
      smsContact = lstContact.get(0);
      List<Case> lstCase = new List<Case>(
        [
          SELECT id, Status
          FROM case
          WHERE ContactId = :smsContact.id AND Status != 'Closed'
          ORDER BY CreatedDate DESC
          LIMIT 1
        ]
      );
      if (lstCase.size() > 0) {
        smsCase = lstCase.get(0);
      }
    }

    //here we can check if contact have latest sms with out and that sms belongs to 'Out' direction and Automate field value 'Executive'
    List<smagicinteract__smsMagic__c> lstSMSDirectionOut = new List<smagicinteract__smsMagic__c>(
      [
        SELECT
          Id,
          Automated_Message_Type__c,
          smagicinteract__Case__c,
          smagicinteract__Case__r.Status
        FROM smagicinteract__smsMagic__c
        WHERE
          smagicinteract__Contact__c = :smsContact.Id
          AND smagicinteract__Direction__c = 'OUT'
        ORDER BY CreatedDate DESC
        LIMIT 1
      ]
    );
    Boolean blnAutoMsgType = false;
    if (smsContact.Id != null) {
      for (smagicinteract__smsMagic__c s : lstSMSDirectionOut) {
        if (
          s.Automated_Message_Type__c == 'Executive' &&
          (s.smagicinteract__Case__c == null ||
          s.smagicinteract__Case__r.Status == 'Closed')
        ) {
          if (
            s.smagicinteract__Case__c != null &&
            s.smagicinteract__Case__r.Status == 'Closed'
          ) {
            blnAutoMsgType = false;
          } else {
            blnAutoMsgType = true;
          }
        }
      }
    }
    System.debug('@@@@lstSMSDirectionOut ' + lstSMSDirectionOut);
    System.debug('@@@@blnAutoMsgType ' + blnAutoMsgType);

    Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
    System.debug(
      '@@@@Executive_Owner_Id__c ' + objBarsalaSetting.Executive_Owner_Id__c
    );
    System.debug('@@@@smsCase ' + smsCase);
    System.debug(
      '@@@@smsCase ' + UserInfo.getUserId() != APIServiceAccountProfileId
    );
    System.debug('@@@@smsCase ' + (smsCase.Id == null));

    if (
      (smsCase.Id == null &&
      UserInfo.getUserId() != APIServiceAccountProfileId) || blnAutoMsgType // (CurrentSMS.smagicinteract__Previous_Message__c != null && // CurrentSMS.smagicinteract__Previous_Message__r.Automated_Message_Type__c == // 'Executive')
    ) {
      System.debug('@@@@SMS Case not found ');
      smsCase = new Case(
        ContactId = smsContact.Id,
        Description = SMSText,
        origin = 'SMS',
        OwnerId = blnAutoMsgType
          ? objBarsalaSetting.Executive_Owner_Id__c
          : OwnerId,
        status = 'New',
        Subject = 'SMS to Case: ' + CurrentSMS.smagicinteract__PhoneNumber__c,
        SuppliedPhone = CurrentSMS.smagicinteract__PhoneNumber__c,
        Do_you_want_to_stop_auto_assign_Case__c = blnAutoMsgType
      );
      insert smsCase;

      if (lstSMSDirectionOut.size() > 0) {
        smagicinteract__smsMagic__c objsmshistorywithcaseupdate = new smagicinteract__smsMagic__c();
        for (smagicinteract__smsMagic__c s : lstSMSDirectionOut) {
          objsmshistorywithcaseupdate.Id = s.Id;
          objsmshistorywithcaseupdate.smagicinteract__Case__c = smsCase.Id;
        }
        update objsmshistorywithcaseupdate;
      }
    }

    if (CurrentSMS != null && CurrentSMS.Id != null) {
      if (UserInfo.getUserId() != APIServiceAccountProfileId) {
        CurrentSMS.smagicinteract__Case__c = smsCase.id;
      }
      CurrentSMS.smagicinteract__Contact__c = smsContact.Id;
      CurrentSMS.smagicinteract__PhoneNumber__c = currentPhoneNumberOnSMS;  // assign requested phone
      update CurrentSMS;
    }
  }

  global static List<Contact> findAllContact(
    string phonenumber,
    boolean isphone
  ) {
    List<Contact> lstContact = new List<Contact>();
    if (isphone) {
      lstContact = new List<Contact>(
        [
          SELECT id, Name, MobilePhone, Phone, (SELECT id, Status FROM Cases)
          FROM Contact
          WHERE Phone_Standardized__c = :phonenumber
          ORDER BY CreatedDate ASC
          LIMIT 1
        ]
      ); //Phone_Standardized__c
    } else {
      lstContact = new List<Contact>(
        [
          SELECT id, Name, MobilePhone, Phone, (SELECT id, Status FROM Cases)
          FROM Contact
          WHERE id = :phonenumber
          ORDER BY CreatedDate ASC
          LIMIT 1
        ]
      );
    }

    return lstContact;
  }

  global class WrapperClass {
    @InvocableVariable
    global String CaseSubject;

    @InvocableVariable
    global String ContPhone;

    @InvocableVariable
    global Id SMSHistoryId;

    @InvocableVariable
    global Id OwnerId;

    @InvocableVariable
    global String SMSText;

    @InvocableVariable
    global String FirstName;

    @InvocableVariable
    global String LastName;
  }
}