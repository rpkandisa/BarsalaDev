//calculate rollup for billing and guest contact and total spent
global class contactUpdateBatch implements Database.Batchable<sObject> {
    public String query;     
    global contactUpdateBatch() {
        this.query = 'SELECT ID FROM Contact';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> lst) {
    
        List<RollupContact.wrpRollupContact> lstwrp = new List<RollupContact.wrpRollupContact>();
        for (Contact contact : lst) {
            RollupContact.wrpRollupContact conId = new RollupContact.wrpRollupContact();
            conId.contactId = contact.Id;
            lstwrp.add(conId);
        }
        RollupContact.fnRollupcontact(lstwrp);
    
    }
    
    global void finish(Database.BatchableContext BC) {}        
   
}