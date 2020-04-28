/*
 * Author: kandisa Technology
 * Date: 21/04/2020
 * Description: Populate Building owner on booking.
 * 
 */

global class PopulateBuildingOwnerOnBookingBatch implements  Database.Batchable<sObject>, Database.Stateful {

    public Date dt = System.today();
    public Set<id> setBuildingIds = new Set<Id>();
    public String query = 'Select Id, status__c, End_date__c, Product__r.Building__c, Product__r.Building__r.Building_Owner__c,  Building_Owner__c from Xotelia_Booking__c where Status__c = \'Active\' AND End_date__c >=: dt ';
    
    global boolean hasError;
    global List<String> exception_List;
    global String [] email = new String[] {'rahul.g@kandisatech.com', 'r.patel@kandisatech.com'};

        
    public PopulateBuildingOwnerOnBookingBatch(string soql, Date paramdt, Set<Id> setId){
        this.query = soql;
        this.dt = paramdt;
        this.setBuildingIds  = new Set<Id>();
        this.setBuildingIds = setid;        
        hasError = false;
        exception_List = new List<String>();
    }
    
    global Database.Querylocator start (Database.BatchableContext BC){
        
        return database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<Xotelia_Booking__c> scope){
        
        for(Xotelia_Booking__c booking : scope){
            if(String.isNotBlank(booking.Product__r.Building__r.Building_Owner__c)){
                booking.building_owner__c = booking.Product__r.Building__r.Building_Owner__c;
            }
        }

        
        Database.SaveResult[] SaveResultList = database.update(scope,false); 
        for(integer i =0; i<scope.size();i++){
            String msg='';
            If(!SaveResultList[i].isSuccess()){
                hasError = true;
                msg += scope.get(i).id + '\n'+'Error: "';        
                for(Database.Error err: SaveResultList[i].getErrors()){  
                    msg += err.getmessage()+'"\n\n';
                } 
            }
            if(msg!='')
                exception_List.add(msg);
        } 
        //system.debug('exception_List**'+exception_List);
        
        
    }
    
    global void finish(Database.BatchableContext BC){
         if(hasError) 
         {
             system.debug('exception_List**'+exception_List);
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             // Below code will fetch the job Id
             AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
             
             // below code will send an email to User about the status
             mail.setToAddresses(email);
             mail.setSenderDisplayName('Barsala Support');
             mail.setSubject('PopulateBuildingOwnerOnBookingBatch batch failed');
             mail.setPlainTextBody('\n'+'Hi,'+'\n'+'\n'+'The Batch Apex job processed '
                                   + a.TotalJobItems+' batches, There were following errors: '+ String.join(exception_List , ' , ' ) +'\n'+'\n'+'Thanks,'+'\n'+'Salesforce Administrator');
             Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
             
         }
    }
}