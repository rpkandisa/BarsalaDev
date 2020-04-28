global class uploadAttachmentQueueable implements Queueable, Database.AllowsCallouts  
{
    global String attId = '';
    global String albumId = '';
    
    global uploadAttachmentQueueable(String attId,String albumId)
    {
        this.attId = attId;
        this.albumId = albumId;
    }
    
    global void execute(QueueableContext context) 
    {
        sharinpix.Utils utl = new sharinpix.Utils();
        
        if(!Test.isRunningTest()){ object s = utl.uploadAttachment(attId, albumId); } 

        // imageSyncQueueable syncImage = new imageSyncQueueable(attId,albumId);
        // if(!Test.isRunningTest()){ System.enqueueJob(syncImage); }

        //AttachmentShrinpix.imageSyncfuture(attId);
    }
}