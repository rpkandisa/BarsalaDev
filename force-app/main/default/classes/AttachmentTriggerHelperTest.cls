@isTest
public class AttachmentTriggerHelperTest {

    @isTest
    public static void testAttachment()
    {
        Account acc = new Account();
        Id RecordId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.RecordTypeId = RecordId;
        acc.LastName = 'Test Person Account';
        Insert acc;
        
        List<Attachment> attLST = new List<Attachment>();
        Attachment attach=new Attachment();   	
    	attach.Name='Unit First Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit First Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=acc.id;
        attLST.add(attach);
        
        Attachment attach2=new Attachment();   	
    	attach2.Name='Unit Second Test Attachment';
    	Blob bodyBlob2=Blob.valueOf('Unit Secong Test Attachment Body');
    	attach2.body=bodyBlob2;
        attach2.parentId=acc.id;
        attLST.add(attach2);
        
        insert attLST;

        AttachmentShrinpix.getAccountNames(new List<Id>{ acc.Id });

        acc.Image_Sync_Action__c = 'Create Shrinpix Image Record';
        update acc;

        AttachmentShrinpix.getAccountNames(new List<Id>{ acc.Id });
        
        uploadAttachmentQueueable uploadIMG = new uploadAttachmentQueueable(attLST[0].Id,acc.Id);
        imageSyncQueueable imgSYNC = new imageSyncQueueable(attLST[0].Id,acc.Id);
        deleteAttachmentQueueable delAttachment = new deleteAttachmentQueueable(attLST[0].Id,acc.Id);
        
        Test.startTest();
        
        System.enqueueJob(uploadIMG);
        uploadIMG.execute(null);
        
		System.enqueueJob(imgSYNC);
        imgSYNC.execute(null);
        
        System.enqueueJob(delAttachment);
		delAttachment.execute(null);


		        
        Test.stopTest();
        
    }
    
}