trigger SharinPixTrigger on sharinpix__SharinPixImage__c (After Insert,After Update,After Delete,After Undelete)
{
    if(Trigger.isAfter)
        SharinPixTriggerHelper.updateTotalImages(Trigger.new,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete,Trigger.isUndelete);  
}