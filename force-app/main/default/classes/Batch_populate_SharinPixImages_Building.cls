global class Batch_populate_SharinPixImages_Building implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    public String query; 
    
    global Batch_populate_SharinPixImages_Building() {
        this.query = 'select id from Building__c';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Building__c> lst) {
    
    for(Building__c b :lst)
        {
           system.debug('Building id***'+b.id);
           if(!test.isrunningtest() )
           {
               sharinpix.imageSyncMigration.resyncAlbum(b.id);
           }
        }
    
    }
    
    global void finish(Database.BatchableContext BC) {}
        
   
  }