global class Batch_populate_SharinPixImages_ForUnit implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    public String query; 
    
    global Batch_populate_SharinPixImages_ForUnit() {
        this.query = 'select id from Unit__c';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> lst) {
    
    for(SObject u :lst)
        {
           system.debug('Unit id***'+u.id);
           if(!test.isrunningtest() )
           {
               sharinpix.imageSyncMigration.resyncAlbum(u.id);
           }
        }
    
    }
    
    global void finish(Database.BatchableContext BC) {}
        
   
  }