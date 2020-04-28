public without sharing class AccountTriggerDuplicateContact {
  public static boolean isrecursion = false;
  public static void DuplicateProcessonContact(
    List<Account> lst,
    Map<Id, Account> oldmap,
    Boolean isinsert
  ) {
    Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
    ID userID = UserInfo.getUserId();
    String userIDstr = System.Label.User_Ids;
    system.debug('userIDstr ::' + userIDstr);

    Set<Id> setUserToSkip = new Set<Id>();
    for (string strid : userIDstr.split(',')) {
      setUserToSkip.add((Id) strid);
    }
    system.debug('setUserToSkip ::' + setUserToSkip);

    if (
      !setUserToSkip.contains(userID) &&
      objBarsalaSetting.Check_duplicate_Contact_Via_Trigger__c
    ) {
      system.debug('user::' + userIDstr);
      AccountTriggerDuplicateContact.checkDuplicatContact(
        lst,
        oldmap,
        isinsert
      );
    }
  }

  public static void checkDuplicatContact(
    List<Account> contactList,
    Map<Id, Account> oldmap,
    Boolean isinsert
  ) {
    Set<String> AllEmails = new Set<String>();
    Set<String> AllPhones = new Set<String>();

    for (Account con : contactList) {
      if (!con.IsPersonAccount)
        continue;

      Boolean isupdateprocess = false;
      if (
        !isinsert &&
        (oldmap.get(con.id).PersonEmail != con.PersonEmail ||
        oldmap.get(con.id).phone != con.phone)
      ) {
        isupdateprocess = true;
      }

      if (!isinsert && !isupdateprocess)
        continue;

      if (String.isNotBlank(con.PersonEmail)) {
        AllEmails.add(con.PersonEmail);
      }

      if (string.isNotBlank(con.phone)) {
        String phone = con.Phone;
        phone = phone.replaceAll('\\D', '');
        if (phone.length() == 10) {
          phone = '1' + phone;
        }
        phone = phone.trim();
        AllPhones.add(phone);
      }
    }
    system.debug('AllEmails ::' + AllEmails);
    system.debug('AllPhones ::' + AllPhones);

    List<Contact> availableContactList = [
      SELECT id, Name, email, Phone_Standardized__c
      FROM Contact
      WHERE Email IN :AllEmails OR Phone_Standardized__c IN :AllPhones
    ];

    if (availableContactList != null && availableContactList.size() > 0) {
      Map<String, Integer> mapExistingRecords = new Map<String, Integer>();
      if (!isinsert) {
        system.debug('availableContactList ::' + availableContactList.size());
        system.debug('availableContactList ::' + availableContactList);
        for (Contact obj : availableContactList) {
          string strconkey = findcontactkeydata(obj);
          mapExistingRecords = addContactKey(strconkey, mapExistingRecords);
          mapExistingRecords = addContactKey(obj.Email, mapExistingRecords);
          mapExistingRecords = addContactKey(
            obj.Phone_Standardized__c,
            mapExistingRecords
          );
        }
      }
      System.debug('mapExistingRecords@@@@@ ' + mapExistingRecords);
      System.debug('isinsert@@@@@ ' + isinsert);

      for (Account c : contactList) {
        if (isinsert) {
          c.addError('You are trying to create a duplicate record!');
        } else {
          string strconkey = '';
          if (
            String.isNotBlank(c.PersonEmail) &&
            String.isNotBlank(c.Phone_Standardized__pc)
          ) {
            strconkey = findcontactkey(c);
          }
          System.debug('strconkey@@@@@ ' + strconkey);

          Boolean isfoundduplicate = false;
          if (
            (String.isnotblank(strconkey) &&
            checkContactExist(strconkey, mapExistingRecords) == true)
          ) {
            System.debug('strconkey@@@@@1 ' + strconkey);
            isfoundduplicate = true;
          } else if (
            (String.isNotBlank(c.PersonEmail) &&
            checkContactExist(c.PersonEmail, mapExistingRecords) == true)
          ) {
            isfoundduplicate = true;
            System.debug('strconkey@@@@@2 ' + strconkey);
          } else if (
            (String.isNotBlank(c.Phone_Standardized__pc) &&
            checkContactExist(c.Phone_Standardized__pc, mapExistingRecords) ==
            true)
          ) {
            isfoundduplicate = true;
            System.debug('strconkey@@@@@23 ' + strconkey);
          }
          System.debug('strconkey@@@@@1 ' + isfoundduplicate);
          if (isfoundduplicate) {
            c.addError('You are trying to create a duplicate record!');
          }
        }
      }
    }
  }

  public static string findcontactkeydata(Contact obj) {
    string strkey = '';
    if (String.isNotBlank(obj.Email)) {
      strkey = obj.Email;
    }

    if (String.isNotBlank(obj.Phone_Standardized__c)) {
      if (String.isBlank(strkey)) {
        strkey = obj.Phone_Standardized__c;
      } else {
        strkey += +'#' + obj.Phone_Standardized__c;
      }
    }

    return strkey;
  }

  public static string findcontactkey(Account obj) {
    string strkey = '';
    if (String.isNotBlank(obj.PersonEmail)) {
      strkey = obj.PersonEmail;
    }

    if (String.isNotBlank(obj.Phone_Standardized__pc)) {
      if (String.isBlank(strkey)) {
        strkey = obj.Phone_Standardized__pc;
      } else {
        strkey += +'#' + obj.Phone_Standardized__pc;
      }
    }

    return strkey;
  }

  public static Map<String, Integer> addContactKey(
    String strkey,
    Map<String, Integer> mapExistingRecords
  ) {
    if (String.isNotBlank(strkey)) {
      strkey = strkey.toLowerCase();
      System.debug('strkey#@#@#@ ' + strkey);
      Integer intcnt = 0;
      if (mapExistingRecords.containsKey(strkey)) {
        intcnt = mapExistingRecords.get(strkey);
        intcnt = intcnt + 1;
        mapExistingRecords.put(strkey, intcnt);
      } else {
        intcnt = intcnt + 1;
        mapExistingRecords.put(strkey, intcnt);
      }
    }
    return mapExistingRecords;
  }

  public static Boolean checkContactExist(
    String strkey,
    Map<String, Integer> mapExistingRecords
  ) {
    if (String.isNotBlank(strkey)) {
      strkey = strkey.toLowerCase();

      if (
        mapExistingRecords.containsKey(strkey) &&
        mapExistingRecords.get(strkey) > 0
      ) {
        return true;
      }
    }
    return false;
  }
}
