public with sharing class clearGuestController {
    public Xotelia_Booking__c booking{get;set;}
    public String currentRecordId {get;set;}

    public String isBilling {get;set;}
    public Boolean isContactFieldVisible {get;set;}
    
    public String ElevatedFraudRiskValue { get; set; }
    public string mergeContactId {get;set;}
    public string contactId {get;set;}
    public String firstName {get;set;}
    public String lastName {get;set;}
    public String email {get;set;}
    public String phone {get;set;}
    
    public clearGuestController(ApexPages.StandardController controller) {
        isBilling = 'Yes';
        isContactFieldVisible = false;
        contactId = null;
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        booking = [select id,Private_comment__c,Elevated_Fraud_Risk__c,Billing_Contact__r.Name,Guest_Contact__c  from Xotelia_Booking__c where id=:currentRecordId ];
    }
    
    public PageReference redirect(){
        //clear data
        boolean isElevatedFraudRisk = False;
        Xotelia_Booking__c obj = [select id,Private_comment__c,Elevated_Fraud_Risk__c,Billing_Contact__c  from Xotelia_Booking__c where id=:currentRecordId ];
        obj.Screening_Decision__c = 'Clear';
        if(!String.isBlank(obj.Elevated_Fraud_Risk__c) ){
            isElevatedFraudRisk  =true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You must collect a security deposit to clear the guest.'));
            
        }
        else{
            obj.Elevated_Fraud_Risk__c = '';
            
        }
        
        if(!string.isBlank(obj.Private_comment__c)){
            obj.Private_comment__c += ' Manually cleared by ' + UserInfo.getName();
        }else{
            obj.Private_comment__c = ' Manually cleared by ' + UserInfo.getName();
        }
        

        if(isBilling == 'Yes'){
            if(obj.Billing_Contact__c != null) obj.Guest_Contact__c = obj.Billing_Contact__c;
        }else{
            if(String.isNotBlank(contactId)) obj.Guest_Contact__c = contactId;
        }

        obj.Checkin_Email_Send_Date__c = null;
        
        
        if(!isElevatedFraudRisk){
            update obj;
            PageReference pageRef = new PageReference('/'+currentRecordId );
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
        
    }

    public List<SelectOption> getElevatedFraudRisk()
    {
       List<SelectOption> options = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = Xotelia_Booking__c.Elevated_Fraud_Risk__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('', '-- None --'));
       for( Schema.PicklistEntry f : ple)
       {
           if(f.getValue() != 'On Hold - Fraud Possible'){
               options.add(new SelectOption(f.getLabel(), f.getValue()));
           }
            
       }     
       return options;
    }
    
    public PageReference Save(){
    
        try{
        
       

        system.debug('@@@@@@ ccc@@### ' + contactId + ' %%%% ' + mergeContactId);

        if(String.isNotBlank(contactId)  && String.isNotBlank(mergeContactId)){
            UnitBookingController.mergecontact(contactId, mergeContactId);
        }

        //clear data
        // if(booking.Elevated_Fraud_Risk__c == 'On Hold - Fraud Possible'){
        //     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must collect a security deposit to clear the guest.'));
        //     return null;
            
        // }
        // else{
            
            
            Xotelia_Booking__c obj = [select id,Private_comment__c,Billing_Contact__c  from Xotelia_Booking__c where id=:currentRecordId ];
            obj.Screening_Decision__c = 'Clear';
            
            if(String.isNotBlank(ElevatedFraudRiskValue)) obj.Elevated_Fraud_Risk__c = ElevatedFraudRiskValue;
            
            if(!string.isBlank(obj.Private_comment__c)){
                obj.Private_comment__c += '\n Manually cleared by ' + UserInfo.getName();
            }else{
                obj.Private_comment__c = '\n Manually cleared by ' + UserInfo.getName();
            }
            
            obj.Checkin_Email_Send_Date__c = null;
            obj.Send_Email_Upon_Clearing_Guest__c = true;
            
            if(booking.Guest_Contact__c == null){
                if(isBilling == 'Yes'){
                    if(obj.Billing_Contact__c != null) obj.Guest_Contact__c = obj.Billing_Contact__c;
                }else{
                    if(String.isNotBlank(contactId)) obj.Guest_Contact__c = contactId;
                }
            }
            
            update obj;
            
            PageReference pageRef = new PageReference('/'+currentRecordId );
            pageRef.setRedirect(true);
            return pageRef;
        // }
        
         }Catch(Exception ex){
             
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getmessage()));
         }
         return null;
    }
    
    
    @RemoteAction
    public static list<Contact> findExistingContacts(string email, string phone) { 
        System.debug('Inside getExistingContacts' + email);
        /*List<Contact> lst_contact = new List<Contact>();
        lst_contact = [SELECT Id, FirstName, LastName, Name, Email, Phone FROM Contact WHERE Email =: email OR Phone=: phone];
        System.debug('lst_contact :: ' + lst_contact);
        return lst_contact;*/
        
        String soql = 'select id, Name, FirstName, LastName, Email, Phone from Contact';

        string strwhere = '';
        if(!string.isBlank(email)){
            email = email.trim();
            if(string.isBlank(strwhere)) { strwhere = ' Email=: email '; } else { strwhere += ' or Email=: email '; }
        }

        if(!string.isBlank(phone)){
            phone = phone.replaceAll('\\D','');
            if(phone.length() == 10){
                phone = '1' + phone;
            }
            phone = phone.trim();
        }
        
        if(!string.isBlank(phone)){
            if(string.isBlank(strwhere)) { strwhere = ' Phone_Standardized__c=: phone '; } else { strwhere += ' or Phone_Standardized__c=: phone '; }
        }
        
        if(!string.isBlank(strwhere)){
            soql += ' where ' + strwhere;
        }
        
        soql += ' ORDER BY LastModifiedDate DESC';
        system.debug('@@@'+soql);   
        return Database.query(soql);

    }


    
    
    
    
}