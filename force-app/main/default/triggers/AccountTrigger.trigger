trigger AccountTrigger on Account(
  before insert,
  before update,
  after insert,
  after update
) {
  if (Trigger.isBefore) {
    List<Contact> lstcontact = new List<Contact>();
    for (Account a : Trigger.new) {
      if (
        a.IsPersonAccount == true && !String.isblank(a.Phone) &&
        a.Phone.contains(',')
      ) {
        for (string s : a.Phone.split(',')) {
          a.Phone = s;
          break;
        }
      }

      if (a.IsPersonAccount == true && !String.isblank(a.Phone)) {
        a.Standardized_Phone_For_DeDupe__pc = a.Phone.replaceAll('\\D', '');
        if (a.Standardized_Phone_For_DeDupe__pc.length() == 10) {
          a.Standardized_Phone_For_DeDupe__pc =
            '1' + a.Standardized_Phone_For_DeDupe__pc;
        }

        a.Standardized_Phone_For_DeDupe__pc = a.Standardized_Phone_For_DeDupe__pc.trim();
      }
    }

    if (Trigger.isinsert || Trigger.isUpdate) {
      if (!AccountTriggerDuplicateContact.isrecursion) {
        AccountTriggerDuplicateContact.isrecursion = true;
        AccountTriggerDuplicateContact.DuplicateProcessonContact(
          Trigger.new,
          Trigger.oldMap,
          (Trigger.isInsert ? true : false)
        );
      }
    }
  }

  if (Trigger.isAfter) {
    //Call API for Person Account First Name
    //Updated Code on 15th JAN 2020

    set<Id> setPersonAccountIds = new Set<Id>();

    if (Trigger.IsInsert) {
      for (Account acc : Trigger.new) {
        if (acc.IsPersonAccount && acc.FirstName != null) {
          setPersonAccountIds.add(acc.Id);
        }
      }
    } else if (Trigger.IsUpdate) {
      for (Account acc : Trigger.new) {
        if (
          acc.IsPersonAccount &&
          Trigger.oldMap.get(acc.Id).FirstName != acc.FirstName
        ) {
          setPersonAccountIds.add(acc.Id);
        }
      }
    }

    if (setPersonAccountIds != null && setPersonAccountIds.size() > 0) {
      AccountTriggerHandler.GenderizeAPICallout(setPersonAccountIds);
    }
  }
}