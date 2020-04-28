//Developed By Kandisa Technologies on 20-12-2018

global class ZendeskAttachmentBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    Global String Query;

    Global ZendeskAttachmentBatch(String Query){
        this.Query = Query;
    }

    Global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    Global void execute(Database.BatchableContext BC,List<sObject> lst){  
        for(sobject o : lst){
            //ZendeskIntegration.findAttachementByticketId(o.get('Name'),o.get('Id'));
            ZendeskIntegration.findAttachementByticketId(string.valueof(o.get('Name')), string.valueof(o.get('Id')));
        }        
    }
    
    Global void finish(Database.BatchableContext BC){
    }
}