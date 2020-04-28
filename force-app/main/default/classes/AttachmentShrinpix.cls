public without sharing class AttachmentShrinpix {

    @InvocableMethod(label='Account Image Update' description='It is used to update sharinpix images.')
    public static void getAccountNames(List<ID> ids) {
        List<String> accountNames = new List<String>();
        List<Account> accounts = new List<Account>([SELECT Id,Image_Sync_Action__c,(select id,name from attachments),(select id,sharinpix__FileName__c,sharinpix__Format__c from sharinpix__SharinPix_Images__r) FROM Account WHERE Id in :ids]);

        Map<Id,Account> mapUpdate = new Map<Id,Account>();

        Set<string> setFilename = new Set<String>();
        for (Account account : accounts) {

            for (sharinpix__SharinPixImage__c simg : account.sharinpix__SharinPix_Images__r) {
                setFilename.add(simg.sharinpix__FileName__c+'.'+simg.sharinpix__Format__c);
            }

            for (Attachment a : account.Attachments) {
                if(account.Image_Sync_Action__c == 'Create Image to Shrinpix Image'){
                    //account.Image_Sync_Action__c = 'Create Shrinpix Image Record';
                    if(!setFilename.contains(a.name)){
                        imageSyncQueueable syncImage = new imageSyncQueueable(a.Id,account.Id);
                        if(!Test.isRunningTest()){ System.enqueueJob(syncImage); }
                    }
                    
                }else if(account.Image_Sync_Action__c == 'Create Shrinpix Image Record' || setFilename.contains(a.name)){
                    //account.Image_Sync_Action__c = 'Delete Attachment';
                    deleteAttachmentQueueable delAttachment = new deleteAttachmentQueueable(a.Id,account.Id);
                    if(!Test.isRunningTest()){ System.enqueueJob(delAttachment); }
                }                
            }

            if(account.Image_Sync_Action__c == 'Create Image to Shrinpix Image'){
                account.Image_Sync_Action__c = 'Create Shrinpix Image Record';
            }else if(account.Image_Sync_Action__c == 'Create Shrinpix Image Record'){
                account.Image_Sync_Action__c = 'Delete Attachment';
            }
            mapUpdate.put(account.Id, new Account(Id = account.Id, Image_Sync_Action__c =account.Image_Sync_Action__c ));
        }

        if(mapUpdate.size()>0){
            update mapUpdate.values();
        }
    }

    // @future(callout=true)
    // public static void imagePostToServer(Id attachmentId){
    //     List<Attachment> lstatt = new List<Attachment>([select id,ParentId from Attachment where id=: attachmentId]);
    //     Id AccountId = null;
        
    //     for (Attachment att : lstatt) {
    //         AccountId = att.ParentId;    
    //     }

    //     if(AccountId != null){
    //         sharinpix.Utils utl = new sharinpix.Utils();        
    //         if(!Test.isRunningTest()){ object s = utl.uploadAttachment(attachmentId, AccountId); } 

    //         imageSyncQueueable syncImage = new imageSyncQueueable(attachmentId, AccountId);
    //         if(!Test.isRunningTest()){ System.enqueueJob(syncImage); }
    //     }

    // }
    
    // @future(callout=true)
    // public static void imageSyncfuture(Id attachmentId){
    //     List<Attachment> lstatt = new List<Attachment>([select id,ParentId from Attachment where id=: attachmentId]);
    //     Id AccountId = null;
        
    //     for (Attachment att : lstatt) {
    //         AccountId = att.ParentId;    
    //     }

    //     if(AccountId != null){
    //         sharinpix.imageSyncMigration.resyncAlbum(AccountId);

    //         //System.enqueueJob(new deleteAttachmentQueueable(attachmentId, AccountId)); 
    //     }

    // }
}