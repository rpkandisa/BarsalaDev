public class ContactTriggerHandler {
  public static void DuplicateProcessonContact(
    List<Contact> lst,
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
      ContactTriggerHandler.checkDuplicatContact(lst, isinsert);
    }
  }

  public static void checkDuplicatContact(
    List<Contact> contactList,
    Boolean isinsert
  ) {
    Set<String> AllEmails = new Set<String>();
    Set<String> AllPhones = new Set<String>();

    for (Contact con : contactList) {
      if (String.isNotBlank(con.Email)) {
        AllEmails.add(con.Email);
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
        for (Contact obj : availableContactList) {
          string strconkey = findcontactkey(obj);
          mapExistingRecords = addContactKey(strconkey, mapExistingRecords);
          mapExistingRecords = addContactKey(obj.Email, mapExistingRecords);
          mapExistingRecords = addContactKey(
            obj.Phone_Standardized__c,
            mapExistingRecords
          );
        }
      }

      System.debug('isinsert@@@@@ ' + isinsert);

      for (Contact c : contactList) {
        if (isinsert) {
          c.addError('You are trying to create a duplicate record!');
        } else {
          string strconkey = '';
          if (
            String.isNotBlank(c.Email) &&
            String.isNotBlank(c.Phone_Standardized__c)
          ) {
            strconkey = findcontactkey(c);
          }

          Boolean isfoundduplicate = false;
          if (
            (String.isnotblank(strconkey) &&
            checkContactExist(strconkey, mapExistingRecords) == true)
          ) {
            isfoundduplicate = true;
          } else if (
            (String.isNotBlank(c.Email) &&
            checkContactExist(c.Email, mapExistingRecords) == true)
          ) {
            isfoundduplicate = true;
          } else if (
            (String.isNotBlank(c.Phone_Standardized__c) &&
            checkContactExist(c.Phone_Standardized__c, mapExistingRecords) ==
            true)
          ) {
            isfoundduplicate = true;
          }

          if (isfoundduplicate) {
            c.addError('You are trying to create a duplicate record!');
          }
        }
      }
    }
  }

  public static string findcontactkey(Contact obj) {
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

  public static Map<String, Integer> addContactKey(
    String strkey,
    Map<String, Integer> mapExistingRecords
  ) {
    if (String.isNotBlank(strkey)) {
      strkey = strkey.toLowerCase();

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
        mapExistingRecords.get(strkey) > 1
      ) {
        return true;
      }
    }
    return false;
  }
}
