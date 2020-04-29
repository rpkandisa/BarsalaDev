public with sharing class SendBulkSMSFromBuildingController {
    public List<wrapContact> wrapContactList {get; set;}
    public List<wrapContact> selectedContact{get;set;}
    
    public Id buildingId{get; set;}
    
    public SendBulkSMSFromBuildingController(ApexPages.StandardController stdController){
        buildingId  = Apexpages.currentPage().getParameters().get('Id');
        String builId = buildingId;
        if(builId != null){
            builId = builId.substring(0,builId.length()-3);  
        }
        system.debug('buildingId :'+buildingId);
        system.debug('builId :'+builId);
        Datetime todaydt = system.now();
        List<Xotelia_Booking__c> bookingList = [SELECT id,name,Building_Id__c,Start_date__c,End_date__c,Status__c,Guest_Contact__r.Name,Guest_Contact__r.Phone,Guest_Contact__r.Email,Unit__c FROM Xotelia_Booking__c WHERE 
                                                Building_Id__c =:builId AND 
                                                Status__c ='Active' AND 
                                                Guest_Contact__c != null AND
                                               Start_date__c<= :todaydt AND 
                                               End_date__c >= :todaydt];
        system.debug('bookingList :'+bookingList);
        
        wrapContactList = new List<wrapContact>();
        for(Xotelia_Booking__c book :bookingList){
            wrapContact wrap = new wrapContact();
            wrap.conId = book.Guest_Contact__c;
            wrap.conName = book.Guest_Contact__r.Name;
            wrap.conPhone = book.Guest_Contact__r.Phone;
            wrap.conEmail = book.Guest_Contact__r.Email;
            wrap.BookingName = book.Name;
            wrap.BookingId = book.Id;
            wrap.Unit = book.Unit__c;
            wrap.isSelected = false;            
            wrapContactList.add(wrap);
        }
    }
    
    public PageReference  selectedContacts(){
        Set<Id> conIds = new Set<Id>();
        selectedContact = new List<wrapContact>();
        for(wrapContact wrapCon : wrapContactList) {
            if(wrapCon.isSelected) {
                selectedContact.add(wrapCon);
            }
        }
        PageReference pageref = page.smagicinteract__BulkSMS_Contact;
        pageref.setRedirect(true);
        return pageref;
    }
    
    public class wrapContact {
        public Id conId {get; set;}
        public String conName {get; set;}
        public String conPhone {get; set;}
        public String conEmail {get; set;}
        public String BookingName {get; set;}
        public Id BookingId {get; set;}
        public Boolean isSelected {get; set;}
        public String Unit {get; set;}
        
       
        
    }  
    
}