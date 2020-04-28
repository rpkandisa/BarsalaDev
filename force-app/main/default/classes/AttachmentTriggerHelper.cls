public class AttachmentTriggerHelper {
  public static Boolean isquablecall = true;

  public static void addAttachmentToSharinPix(
    Map<String, List<String>> personAccAttch
  ) {
    if (isquablecall) {
      List<Account> lstAccount = new List<Account>();
      for (Account acc : [
        SELECT IsPersonAccount
        FROM Account
        WHERE Id = :personAccAttch.keySet() AND IsPersonAccount = true
      ]) {
        for (String attId : personAccAttch.get(acc.Id)) {
          uploadPhoto(attId, acc.Id);
        }
        lstAccount.add(
          new Account(
            Id = acc.Id,
            Image_Sync_Action__c = 'Create Image to Shrinpix Image'
          )
        );
      }

      if (lstAccount.size() > 0) {
        update lstAccount;
      }
    }
  }

  // public static void uploadPhoto(String attachmentId)
  // {
  //     if(!Test.isRunningTest())
  //     {
  //         AttachmentShrinpix.imagePostToServer  (attachmentId);
  //     }
  // }

  public static void uploadPhoto(String attachmentId, String albumId) {
    if (!Test.isRunningTest()) {
      uploadAttachmentQueueable uploadAttachment = new uploadAttachmentQueueable(
        attachmentId,
        albumId
      );
      System.enqueueJob(uploadAttachment);
    }
  }
}