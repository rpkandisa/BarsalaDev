global class imageSyncQueueable implements Queueable, Database.AllowsCallouts {
  String attId = '';
  String albumId = '';

  global imageSyncQueueable(String attId, String albumId) {
    this.attId = attId;
    this.albumId = albumId;
  }

  global void execute(QueueableContext context) {
    try {
      if (!Test.isRunningTest()) {
        sharinpix.imageSyncMigration.resyncAlbum(albumId);
      }
    } catch (Exception e) {
    }

    // deleteAttachmentQueueable delAttachment = new deleteAttachmentQueueable(attId, albumId);
    // if(!Test.isRunningTest()){ System.enqueueJob(delAttachment); }
  }
}