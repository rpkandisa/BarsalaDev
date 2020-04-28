global class ContactDuplicationBatch implements Database.Batchable<sObject> {
    
    public String query; 
    
    global ContactDuplicationBatch() {
        this.query = 'Select Id, AccountId, IsPersonAccount, LastName, FirstName, Phone, MobilePhone, Email,Mobile_Standardized__c,Phone_Standardized__c FROM Contact';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> lst) {
        
        Set<Id> setContactIds = new Set<Id>(); // it is used to check booking records exist for contact or not

        for (Xotelia_Booking__c b : [select id,Guest_Contact__c,Billing_Contact__c from Xotelia_Booking__c where Guest_Contact__c in: lst Or Billing_Contact__c in: lst limit 49999]) {
            if(b.Guest_Contact__c != null){
                setContactIds.add(b.Guest_Contact__c);
            }
            if(b.Billing_Contact__c != null){
                setContactIds.add(b.Billing_Contact__c);
            }
        }


        Set<string> setphone = new Set<string>();
        Set<string> setEmail = new Set<string>();

        for (Contact c : lst) {
            if(!string.isblank(c.Phone_Standardized__c)){
                setphone.add(c.Phone_Standardized__c);
            }
            if(string.isblank(c.Phone_Standardized__c) && !string.isblank(c.Mobile_Standardized__c)){ // it is used to verify mobile exist but phone field does not exist
                if(c.Mobile_Standardized__c != '1'){
                    setphone.add(c.Mobile_Standardized__c);
                }                
            }

            if(!string.isblank(c.Email)){
                setEmail.add(c.Email);
            }
        }

        Map<Id,Contact> mapFindDupContact = new Map<Id,Contact>([SELECT ID,Is_Duplicate__c,Booking_Exists__c FROM Contact WHERE  (Email in: setEmail  or Phone_Standardized__c in:setphone or Mobile_Standardized__c in: setphone ) order by LastModifiedDate desc,Email,Phone_Standardized__c,Mobile_Standardized__c  limit 49999]);

        List<Contact> lstUpdate = new List<Contact>();
        for (Contact c : lst) {
            Contact obj = new Contact(Id = c.Id);
            if(setContactIds.contains(c.Id)){                
                obj.Booking_Exists__c = true;  
            }

            if(mapFindDupContact.size()>1){
                obj.Is_Duplicate__c = true;
                lstUpdate.add(obj);
            }            
        }

        if(lstUpdate.size()>0) {
            update lstUpdate;
        }
    
    }
    
    global void finish(Database.BatchableContext BC) {}
        
   
  }