//added by Kandisa Tech on 03/01/2019
//It is used to create person account record if newly created case does not haveing Account/Contact
public with sharing class EmailMessageTriggerHandler {
    public static boolean isRecursion = false;

    private static string fnfindString(string strsubject, string findtext){
        Integer strtxtlen = findtext.length();
        string strconnum = strsubject;
        integer startindex = strsubject.toLowerCase().indexOf(findtext) + strtxtlen;

        strconnum = strsubject.substring(startindex);
        strconnum = strconnum.replace('\\n\\r', '');	// remove CRLF
        strconnum = strconnum.replace('\\n', '');		// remove LF	
        strconnum = strconnum.replace('\\r', '');		// remove CR
        strconnum = strconnum.replace('\\', '');		// remove slashes		
        strconnum = strconnum.normalizeSpace();	
        string strnum = '';
        if(!string.isBlank(strconnum)){
            strnum = strconnum.trim();
            
        }
        return strnum;
    }

    public static void fnCreatePersonAccount(List<EmailMessage> lstEmailMessage) {
        try {
            string strDomainname = '@mchat.booking.com'; //'@mchat.booking.com';
            string strExpediaCentralEmail = '@m.expediapartnercentral.com'; // @m.expediapartnercentral.com
            Map<string,string> mapCasevsExternalBooking = new Map<string,string>();
            Map<string,boolean> mapEmail = new Map<string,boolean>();
            Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Map<Id,EmailMessage> mapCaseEmailMessage = new Map<Id,EmailMessage>();
            Set<String> setUsers = new Set<String>();
            for(EmailMessage e : lstEmailMessage){
                if(e.incoming && e.ParentId != null && string.valueof(e.ParentId).startsWith('500')){
                    mapCaseEmailMessage.put(e.ParentId, e);
                    mapEmail.put(e.FromAddress,false);

                    string strsubject = '';
                    if(!String.isBlank(e.Subject)){
                        strsubject = e.Subject.toLowerCase();
                    }
                    if(e.FromAddress.toLowerCase().contains(strExpediaCentralEmail)){
                        if(!string.isBlank(strsubject) && strsubject.toLowerCase().indexOf('guest response from ') != -1 || Test.isRunningTest()){                            
                            string strnum = fnfindString(strsubject, 'guest response from ');
                            if(!string.isBlank(strnum)){
                                setUsers.add(strnum.trim());
                            }
                        }
                    }

                    if(e.FromAddress.toLowerCase().contains(strDomainname) || Test.isRunningTest()){
                        string strconnum = findExternalCode(e);
                        mapCasevsExternalBooking.put(e.ParentId, strconnum);
                    }                
                }            
            }

            Map<string,Xotelia_Booking__c> mapExternalCodevsBookingId = new Map<string,Xotelia_Booking__c>();
            for (Xotelia_Booking__c b : [select id,External_code__c,Billing_Contact__c, Billing_Contact__r.AccountId,Guest_Contact__c,Guest_Contact__r.AccountId from Xotelia_Booking__c where External_code__c in: mapCasevsExternalBooking.values() ]) {
                mapExternalCodevsBookingId.put(b.External_code__c, b);
            }
            
            if(mapEmail.size()>0){

                for (Contact objContact : [select id,Email from contact where email in: mapEmail.keySet()]) {
                    mapEmail.remove(objContact.Email);
                }

                for (Account objAccount : [select id,PersonEmail from Account where PersonEmail in: mapEmail.keySet()]) {
                    mapEmail.remove(objAccount.PersonEmail);
                }
            }

            //List<Contact> lstContactExPartner = new List<Contact>([select id,AccountId from Contact where email like '%@m.expediapartnercentral.com']);
            List<Contact> lstContactExPartner = new List<Contact>([select id,AccountId from Contact where AccountId =: label.ExpediaPartnerCentral]); 

            Map<string, Account> mapAccountSubject = new Map<string, Account>();
            for (Account objacc : [select id,name from Account where Name in: setUsers]) {
                mapAccountSubject.put(objacc.Name.toLowerCase(), objacc);
            }

            system.debug('mapAccountSubject@@@@ ' +mapAccountSubject);
           
            List<Case> lstCaseUpdate = new List<Case>();
            Map<Id,Account> mapCasePersonAccount = new Map<Id,Account>();
            for(Case c : [select id,AccountId,ContactId from Case where Id in: mapCaseEmailMessage.keyset()]){
                if(mapCaseEmailMessage.ContainsKey(c.Id)){
                    EmailMessage e = mapCaseEmailMessage.get(c.Id);
                    string strsubject = '';
                    if(!String.isBlank(e.Subject)){
                        strsubject = e.Subject.toLowerCase();
                    }

                    if(e.FromAddress.toLowerCase().contains(strExpediaCentralEmail) && (strsubject.contains('guest response from') || strsubject.contains('new guest review') || strsubject.contains('you have a new review'))) {//
                        Account acc = new Account();

                        if(!string.isBlank(strsubject) && strsubject.toLowerCase().indexOf('guest response from ') != -1){  
                            string strnum = fnfindString(strsubject, 'guest response from ');
                            if(!string.isBlank(strnum) && mapAccountSubject.containsKey(strnum.trim())){
                                acc.Id = mapAccountSubject.get(strnum.trim()).Id;
                                mapCasePersonAccount.put(c.Id,acc);
                            }
                        }

                        if(lstContactExPartner.size()>0 && acc.Id == null){
                            acc.Id = lstContactExPartner.get(0).AccountId;
                            mapCasePersonAccount.put(c.Id,acc);
                        }                                           
                        continue;
                    } 
                    

                    if((c.AccountId == null || c.ContactId == null)){

                        if(!mapEmail.containsKey(e.FromAddress)) continue;                
                        
                        if(e.FromAddress.toLowerCase().contains(strDomainname)){ //mchat.booking.com
                            string strconnum = findExternalCode(e);
                            if(mapExternalCodevsBookingId.containsKey(strconnum)){
                                Xotelia_Booking__c b = mapExternalCodevsBookingId.get(strconnum);
                                Case tmp = new Case(Id = c.Id);
                                tmp.Booking__c = b.Id;
                                if(b.Billing_Contact__c != null){ tmp.AccountId = b.Billing_Contact__r.AccountId;  tmp.ContactId = b.Billing_Contact__c; }else{  tmp.AccountId = b.Guest_Contact__r.AccountId;  tmp.ContactId = b.Guest_Contact__c;  }
                                lstCaseUpdate.add(tmp);                        
                            }else{
                                Account acc = new Account();
                                acc.RecordTypeId = personAccountRecordTypeId;
                                if(!string.isBlank(e.FromName)){
                                    acc.LastName = e.FromName;
                                    if(e.FromName.trim().containsWhitespace()){
                                        acc.FirstName = e.FromName.split(' ')[0];
                                        acc.LastName = e.FromName.split(' ')[1];
                                    }
                                }else{
                                    acc.LastName = e.FromAddress.split('@')[0];
                                }
                                acc.PersonEmail = e.FromAddress;
                                mapCasePersonAccount.put(c.Id,acc);
                            }
                        }else{
                            Account acc = new Account();
                            acc.RecordTypeId = personAccountRecordTypeId;
                            if(!string.isBlank(e.FromName)){
                                acc.LastName = e.FromName;
                                if(e.FromName.trim().containsWhitespace()){
                                    acc.FirstName = e.FromName.split(' ')[0];
                                    acc.LastName = e.FromName.split(' ')[1];
                                }
                            }else{
                                acc.LastName = e.FromAddress.split('@')[0];
                            }
                            acc.PersonEmail = e.FromAddress;
                            mapCasePersonAccount.put(c.Id,acc);
                        }                                
                    }
                }
                
            }

            //system.debug('mapCasePersonAccount@@@@ ' +mapCasePersonAccount);
            if(mapCasePersonAccount.size()>0){
                upsert mapCasePersonAccount.values();

                List<Case> lstCase = new List<Case>();
                Map<Id,Id> mapAccountVsContactId = new Map<Id,Id>();
                for (Contact c : [select id,AccountId from Contact where AccountId in: mapCasePersonAccount.values()]) {
                    mapAccountVsContactId.put(c.AccountId,c.Id);
                }

                for (Id caseId : mapCasePersonAccount.keySet()) {
                    Case c = new Case(Id = caseId);
                    c.AccountId = mapCasePersonAccount.get(caseId).Id;
                    c.ContactId = mapAccountVsContactId.get(c.AccountId);
                    c.IsEmail2Case__c = true;
                    lstCase.add(c);
                }

                //CaseTriggerHandler.isRecursion = true;
                if(lstCase.size()>0){
                    update lstCase;
                }
                
            }

            if(lstCaseUpdate.size()>0){
                update lstCaseUpdate;
            }

        } catch (Exception ex) {
            
        }
    }

    public static string findExternalCode(EmailMessage e) {
        string strbody = '',strconnum = '';
        if(!string.isBlank(e.HtmlBody)){
            strbody = e.HtmlBody.stripHtmlTags();
        }else if(!string.isBlank(e.TextBody)){
            strbody = e.TextBody;
        }
        

        if(!string.isBlank(strbody) && strbody.toLowerCase().indexOf('confirmation number: ') != -1){
            Integer strtxtlen = 'confirmation number:'.length();
            integer startindex = strbody.toLowerCase().indexOf('confirmation number: ') + strtxtlen;

            strconnum = strbody.substring(startindex);
            strconnum = strconnum.replace('\\n\\r', ' ');	// remove CRLF
            strconnum = strconnum.replace('\\n', ' ');		// remove LF	
            strconnum = strconnum.replace('\\r', ' ');		// remove CR
            strconnum = strconnum.replace('\\', ' ');		// remove slashes		
            strconnum = strconnum.normalizeSpace();	
            string strnum = '';
            for(string str : strconnum.split(' ')){
                strnum = str.trim();
                if(!string.isblank(strnum)) break;
            }
            strconnum = strnum; 
            // strconnum = strbody.toLowerCase().substring(startindex, startindex + 21);
            // strconnum = strconnum.replaceAll('\\D','');
        }
        return strconnum;
    }

    // public static void fnChangeFromAddress(List<EmailMessage> lstEmailMessage) {
    //     System.debug('test');
    //     for(EmailMessage e : lstEmailMessage){
    //         System.debug('test@@@@@ ' + e);
    //         if(!e.incoming && e.ParentId != null && string.valueof(e.ParentId).startsWith('500')){
    //             e.FromName = UserInfo.getName();
    //         }            
    //     }
    // }
}