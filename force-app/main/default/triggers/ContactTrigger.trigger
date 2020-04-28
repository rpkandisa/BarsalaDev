trigger ContactTrigger on Contact(before insert, before update) {
  if (Trigger.isBefore) {
    for (Contact c : Trigger.new) {
      if (!String.isblank(c.Phone) && c.Phone.contains(',')) {
        for (string s : c.Phone.split(',')) {
          c.Phone = s;
          break;
        }
      }
    }

    if (Trigger.isinsert || Trigger.isUpdate) {
      ContactTriggerHandler.DuplicateProcessonContact(
        Trigger.new,
        (Trigger.isInsert ? true : false)
      );
    }
  }

}
