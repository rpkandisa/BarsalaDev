trigger AttachmentTrigger on Attachment(after insert) {
  if (
    Trigger.isAfter &&
    Trigger.isInsert &&
    AttachmentTriggerHelper.isquablecall
  ) {
    Map<String, List<String>> personAccAttch = new Map<String, List<String>>();
    for (Attachment att : Trigger.new) {
      if (att.ParentId.getSObjectType().getDescribe().getName() == 'Account') {
        if (personAccAttch.containsKey(att.ParentId)) {
          personAccAttch.get(att.ParentId).add(att.Id);
        } else {
          personAccAttch.put(att.ParentId, new List<String>{ (att.Id) });
        }
      }
    }
    System.debug('personAccAttch :: ' + personAccAttch);
    AttachmentTriggerHelper.addAttachmentToSharinPix(personAccAttch);
  }
}