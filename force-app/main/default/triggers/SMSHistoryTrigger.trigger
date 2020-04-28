trigger SMSHistoryTrigger on smagicinteract__smsMagic__c(before insert) {
  Barsala_Settings__c BarsalaSetting = Barsala_Settings__c.getOrgDefaults();
  //Boolean isTriggerActive = BarsalaSetting.Enable_SMSHistory_for_API_Service_Accout__c;
  //String APIServiceAccountProfileId = BarsalaSetting.API_Service_Account_ProfileId__c;

  // if (
  //   isTriggerActive && UserInfo.getProfileId() == APIServiceAccountProfileId
  // ) {
  //   if (Trigger.IsBefore && Trigger.IsInsert) {
  //     SMSHistoryTriggerHandler.validateSMSHistory(Trigger.New);
  //   }
  // }

  if (
    Trigger.IsBefore &&
    Trigger.IsInsert &&
    !SMSHistoryTriggerHandler.IsExecutiveRun
  ) {
    SMSHistoryTriggerHandler.setAutomateMessageType(Trigger.New);
  }

}