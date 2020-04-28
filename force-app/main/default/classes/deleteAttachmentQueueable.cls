global class deleteAttachmentQueueable  implements Queueable,Database.AllowsCallouts {

    String attId = '';
    String albumId = '';
    
    global deleteAttachmentQueueable(String attId, String albumId)
    {
        this.attId = attId;
        this.albumId =  albumId;
    }
    
    global void execute(QueueableContext context) 
    {
        //if(!Test.isRunningTest()){ sharinpix.imageSyncMigration.resyncAlbum(albumId); }
        
        Attachment att = new Attachment();
        att.Id = attId;
        if(!Test.isRunningTest()) { delete att; }
    }
    
}