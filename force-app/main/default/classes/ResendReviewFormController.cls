public without sharing class ResendReviewFormController {
    public String currentRecordId {get;set;}
    public ResendReviewFormController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
    }
    
    
    public PageReference sendSMS(){
        
        try{
        smagicinteract__smsMagic__c smsObject;
        Xotelia_Booking__c  currBooking = [SELECT id,Billing_Contact__c,Text_Review_Message__c,Billing_Contact__r.Phone ,Billing_Contact__r.Phone_Standardized__c,Phone_Standardized__c,Phone_number__c FROM Xotelia_Booking__c WHERE id =:currentRecordId limit 1];
              
        
        /*if(string.isblank(currBooking.Text_Review_Message__c)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'"Text_Review_Message" cannot be blank, please populate the "Text_Review_Message" in order to use this feature.'));
            return null;
        }*/
        
        if(currBooking.Billing_Contact__c != null && string.isblank(currBooking.Billing_Contact__r.Phone)){
            if(string.isblank(currBooking.Phone_number__c)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please populate the phone number on the Billing Contact.'));
                return null;
            }
        }
        
        if(currBooking.Billing_Contact__c != null && currBooking.Billing_Contact__r.Phone_Standardized__c != Null ){
           Integer result = currBooking.Billing_Contact__r.Phone_Standardized__c.length();
            if(result >= 7){
                String senderId = label.SMSSenderNumber; // Please replace the 'smsMagic' with your relevant sender ID.                
                //String senderId = '';
                String templateText = currBooking.Text_Review_Message__c; // you can fetch the template text by querying the record on smagicinteract__SMS_Template__c object
                
                smsObject = new smagicinteract__smsMagic__c();                
                smsObject.smagicinteract__SenderId__c = senderId;                
                smsObject.smagicinteract__PhoneNumber__c = currBooking.Billing_Contact__r.Phone_Standardized__c;                
                smsObject.smagicinteract__Name__c = 'Barsala'; // records name                
                smsObject.smagicinteract__ObjectType__c = 'Contact'; // record type                
                smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object                
                smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();                
                smsObject.smagicinteract__SMSText__c = templateText;
                smsObject.smagicinteract__Contact__c = currBooking.Billing_Contact__c;
                smsObject.Booking__c = currentRecordId; 

                

                Database.insert(smsObject, false);


                fnUpdateSMS(smsObject.Id);
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Message Sent Successfully!'));
                return null;
                
                //PageReference pageRef = new PageReference('/'+smsObject.id);
                //pageRef.setRedirect(true);
                //return pageRef;
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please populate valid Phone number.'));
                return null;
            }
        }
        else if(currBooking.Phone_Standardized__c != Null){
            Integer result = currBooking.Phone_Standardized__c.length();
            if(result >= 7){
        
                String senderId = label.SMSSenderNumber;  // Please replace the 'smsMagic' with your relevant sender ID. 
                String templateText = currBooking.Text_Review_Message__c; // you can fetch the template text by querying the record on smagicinteract__SMS_Template__c object
                
                smsObject = new smagicinteract__smsMagic__c();
                smsObject.smagicinteract__SenderId__c = senderId;        
                smsObject.smagicinteract__PhoneNumber__c = currBooking.Phone_Standardized__c;        
                smsObject.smagicinteract__Name__c = 'Barsala'; // records name        
                smsObject.smagicinteract__ObjectType__c = 'Contact'; // record type        
                smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
                smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();        
                smsObject.smagicinteract__SMSText__c = templateText;
                smsObject.Booking__c = currentRecordId;  
                smsObject.smagicinteract__Contact__c = currBooking.Billing_Contact__c;
                Database.insert(smsObject, false);


                fnUpdateSMS(smsObject.Id);

                // if(!String.isblank(smsObject.smagicinteract__SMSText__c) && (smsObject.smagicinteract__SMSText__c.contains('https://'))){
                //     smsObject.SMSText_Original__c = smsObject.smagicinteract__SMSText__c;
                //     smsObject.smagicinteract__SMSText__c = findURLReplace(smsObject.smagicinteract__SMSText__c);
                // }
                // Database.update(smsObject);
                
                //PageReference pageRef = new PageReference('/'+smsObject.id);
                //pageRef.setRedirect(true);
                //return pageRef;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Message Sent Successfully!'));
                return null;
                
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please populate valid Phone number.'));
                return null;
            }              
        }
        
        }catch(Exception e){
            ApexPages.addmessages(e);
            return null;
        }

        return Null;
        
    }
    
    public static void fnUpdateSMS(Id smsId){
        smagicinteract__smsMagic__c objsms = new smagicinteract__smsMagic__c();
        objsms = [select id,SMSText_Original__c,smagicinteract__SMSText__c from smagicinteract__smsMagic__c where id=: smsId ];

        if(!String.isblank(objsms.smagicinteract__SMSText__c) && (objsms.smagicinteract__SMSText__c.contains('https://'))){
            objsms.SMSText_Original__c = objsms.smagicinteract__SMSText__c;
            objsms.smagicinteract__SMSText__c = findURLReplace(objsms.smagicinteract__SMSText__c);
        }
        Database.update(objsms, false);

    }

    public static string findURLReplace(string strURL){       
        Integer intIndex = strURL.indexOf('https:');
        Integer intIndex2 = strURL.indexOf('~');        
        String res = strURL.substring(intIndex , intIndex2);
        string s = strURL.replace(res,'<url-hidden> ');
        return s;
    }


    
        
    }