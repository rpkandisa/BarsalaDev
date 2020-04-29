public class TestSentryApplication {
  public static void updatePersonAccount(List<Xotelia_Booking__c> triggerNew) {
    try {
      Id currentUserId = UserInfo.getUserId();
      User activeUser = [
        SELECT Email
        FROM User
        WHERE Id = :currentUserId
        LIMIT 1
      ];
      Account acc; //= new List<Account>();
      if (activeUser != null) {
        acc = [
          SELECT id, PersonEmail
          FROM Account
          WHERE IsPersonAccount = true AND PersonEmail = :activeUser.Email
          LIMIT 1
        ];
      }

    //   List<Xotelia_Booking__c> bookingList = new List<Xotelia_Booking__c>();
    //   for (Xotelia_Booking__c booking : triggerNew) {
    //     if (
    //       booking.Two_Factor_Screening_Approval_Decision__c != null &&
    //       acc != null
    //     ) {
    //       booking.Two_Factor_Screening_Approval_Employee__c = acc.Id;
    //       bookingList.add(booking);
    //     }
    //   }
    } catch (Exception e) {
      Sentry.record(e);
      throw e;
    }
  }
}