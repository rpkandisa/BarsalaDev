global class UpdateUnitCountBatch implements Database.batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext info){ 
        return Database.getQueryLocator([SELECT id,Active_Unit_Count__c,(SELECT id,status__c FROM Units__r WHERE Status__c = 'Active') FROM Building__c]); 
    }     
    global void execute(Database.BatchableContext info, List<Building__c> scope){
        Map<id,Integer> buildingMap = new Map<id,Integer>();
        List<Building__c> bulList = new List<Building__c>();
        for(Building__c bul: scope){
            Building__c bd = new Building__c(id=bul.id);
            integer Num=0;
            for(Unit__c u : bul.Units__r){
                Num++;
                
            }
            bd.Active_Unit_Count__c = Num;
            bulList.add(bd);
        }
        
        if(bulList.size() >0){
           Database.update(bulList,false) ;
        } 
    }
    
    
    global void finish(Database.BatchableContext info){}
    
}