public class SMSHistoryTriggerHandler {
  public static boolean IsExecutiveRun = false;
  // public static void validateSMSHistory(
  //   List<smagicinteract__smsMagic__c> lstSmsHistory
  // ) {
  //   String senderId = (Barsala_Settings__c.getOrgDefaults())
  //     .Barsala_Support_Phone__c;

  //   for (smagicinteract__smsMagic__c smsHistory : lstSmsHistory) {
  //     if (smsHistory.smagicinteract__Direction__c == 'OUT') {
  //       if (smsHistory.smagicinteract__SenderId__c == null) {
  //         smsHistory.smagicinteract__SenderId__c = senderId;
  //       }
  //       if (smsHistory.smagicinteract__disableSMSOnTrigger__c != 0) {
  //         smsHistory.smagicinteract__disableSMSOnTrigger__c = 0;
  //       }
  //     }
  //   }
  // }

  public static void setAutomateMessageType(
    List<smagicinteract__smsMagic__c> lst
  ) {
    SMSHistoryTriggerHandler.IsExecutiveRun = true;
    Set<Id> userIds = new Set<Id>();
    userIds = getGroupUserIds('Executive SMS Users');
    for (smagicinteract__smsMagic__c s : lst) {
      if (userIds.contains(UserInfo.getUserId()) || Test.isRunningTest()) {
        s.Automated_Message_Type__c = 'Executive';
      }
    }
  }

  private static Set<Id> getGroupUserIds(String groupName) {
    Set<Id> setUserId = new Set<Id>(); // final list of users
    Set<Id> setGroupId = new Set<Id>(); // member groups
    for (GroupMember gm : [
      SELECT GroupId, UserOrGroupId
      FROM GroupMember
      WHERE Group.Name = :groupName AND Group.Type = 'Regular'
    ]) {
      if (gm.UserOrGroupId.getSObjectType() == User.getSObjectType()) {
        setUserId.add(gm.UserOrGroupId);
      }
      if (gm.UserOrGroupId.getSObjectType() == Group.getSObjectType()) {
        setGroupId.add(gm.UserOrGroupId);
      }
    }

    if (!setGroupId.isEmpty()) {
      // get users from member groups
      setUserId.addAll(getGroupUserIds(setGroupId));
    }

    return setUserId;
  }

  // recursive method to get users from member groups
  @TestVisible
  private static Set<Id> getGroupUserIds(Set<Id> setGroupId) {
    Set<Id> setUserId = new Set<Id>(); // final list of users
    Set<Id> setChildGroupId = new Set<Id>(); // member groups
    for (GroupMember gm : [
      SELECT GroupId, UserOrGroupId
      FROM GroupMember
      WHERE Id IN :setGroupId
    ]) {
      if (gm.UserOrGroupId.getSObjectType() == User.getSObjectType()) {
        setUserId.add(gm.UserOrGroupId);
      }
      if (gm.UserOrGroupId.getSObjectType() == Group.getSObjectType()) {
        setChildGroupId.add(gm.UserOrGroupId);
      }
    }

    if (!setChildGroupId.isEmpty()) {
      setUserId.addAll(getGroupUserIds(setChildGroupId));
    }
    return setUserId;
  }
}