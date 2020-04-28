global class AddExternalUserWizardCtrl {
    
    @AuraEnabled
    public static ExternalUserWrapper initializeWrapper(){
        ExternalUserWrapper UserWrapper = new ExternalUserWrapper();
        UserWrapper.isHousekeeper = true;
        UserWrapper.isDefaultRate = true;  
        
        UserWrapper.x1BDRate = 40;
        UserWrapper.x2BDRate = 40;
        UserWrapper.x3BDRate = 80;
        
        UserWrapper.sunMinCap = 1;
        UserWrapper.monMinCap = 1;
        UserWrapper.tueMinCap = 1;
        UserWrapper.wedMinCap = 1;
        UserWrapper.thuMinCap = 1;
        UserWrapper.friMinCap = 1;
        UserWrapper.satMinCap = 1;
        
        return UserWrapper;
    }
    
    @AuraEnabled
    public static boolean IsDuplicateEmail(String email){
        
        String queryStr = 'FIND \'' + email + '\' IN ALL FIELDS RETURNING Contact(Email), Lead(Email)';
        List<List<SObject>> searchList = search.query(queryStr);
        System.debug(searchList);
        if(searchList != null && searchList.size() > 0){
            return true;
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static ResponseMessage CreateExternalUser(ExternalUserWrapper exUerWrap){
        
        System.debug('exUerWrap: ' + exUerWrap);
        ResponseMessage resMsg = new ResponseMessage();
        
        if(exUerWrap.isHousekeeper){
            resMsg = AddUserForHouseKeeper(exUerWrap);                
        }else{
            resMsg = AddUserForBuildingOwner(exUerWrap); 
        }
        
        System.debug('resMsg: ' + resMsg);
        return resMsg;
        
    }
    
    //Create User for Housekeeper
    public static ResponseMessage AddUserForHouseKeeper (ExternalUserWrapper exUerWrap){
        
        ResponseMessage resMsg = new ResponseMessage();
        try{
            List<Account> lstAccounts = [Select Id FROM Account WHERE Name = 'Barsala Housekeeping' LIMIT 1];
            
            Contact con = new Contact();
            con.AccountId = lstAccounts[0].Id;
            
            String Name = exUerWrap.name;
            if(Name.contains(' ')){
                List<String> nameStr = exUerWrap.Name.split(' ',2);
                con.FirstName = nameStr[0];
                con.LastName = nameStr[1];
            }else{
                con.LastName = Name;
            }
            
            con.Email = exUerWrap.email;
            con.Phone = exUerWrap.phone;
            con.MailingCity = exUerWrap.cityName;
            Insert Con;
            System.debug(con);
            
            
            Profile profile1 = [Select Id from Profile where name = 'Partner Community - Housekeeping'];
            User portalUser = new User(
                ProfileId = profile1.Id,
                Username = con.Email + '.part'+ System.now().millisecond() ,
                Alias = 'sfdc',
                Email=con.Email+'.inactive',
                EmailEncodingKey='UTF-8',
                Firstname= con.FirstName,
                Lastname= con.LastName,
                ContactId = con.Id,
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago',
                X1BD_Rate__c = exUerWrap.x1BDRate,
                X2BD_Rate__c = exUerWrap.x2BDRate,
                X3BD_Rate__c = exUerWrap.x3BDRate,
                Deep_Clean_Rate_Premium__c = exUerWrap.deepCleanRatePremium,
                Studio_Rate__c = exUerWrap.studioRate
                
            );
            Insert portalUser;
            
            //Set User to Inactive
            setUserInactive(portalUser.Id);
                
            //Add record of Housekeepers
            Housekeepers__c hk = new Housekeepers__c();
            hk.City__c = exUerWrap.cityId;
            hk.Related_User__c = portalUser.Id;
            hk.Status__c = 'Inactive';
            hk.Sun_Min_Cap__c = exUerWrap.sunMinCap;
            hk.Mon_Min_Cap__c = exUerWrap.monMinCap;
            hk.Tue_Min_Cap__c = exUerWrap.tueMinCap;
            hk.Wed_Min_Cap__c = exUerWrap.wedMinCap;
            hk.Thu_Min_Cap__c = exUerWrap.thuMinCap;
            hk.Fri_Min_Cap__c = exUerWrap.friMinCap;
            hk.Sat_Min_Cap__c = exUerWrap.satMinCap;
            Insert hk;
            
            resMsg.isSucceed = true;            
            resMsg.message = 'External user for Housekeeper added successfully.';
            
        }catch(Exception ex){
            resMsg.isSucceed = false;
            resMsg.message = 'Error: ' + ex.getLineNumber() + ': '  + ex.getMessage();
        }
        return resMsg;
    }
    
    public static ResponseMessage AddUserForBuildingOwner(ExternalUserWrapper exUerWrap){
        
        ResponseMessage resMsg = new ResponseMessage();
        try{
            //Create External User for Building Owner
            Account acc = new Account();
            acc.Name = exUerWrap.buildingName + ' Owner';
            Insert acc;
            
            //Create contact for owner
            Contact con = new Contact();
            con.AccountId = acc.Id;
            
            //If name of owner is not provided, use Account name as Contact Name
            if(String.isNotBlank(exUerWrap.name)){
                String Name = exUerWrap.name;
                if(Name.contains(' ')){
                    List<String> nameStr = exUerWrap.Name.split(' ',2);
                    con.FirstName = nameStr[0];
                    con.LastName = nameStr[1];
                }else{
                    con.LastName = Name;
                }
            }else{
                con.LastName = exUerWrap.buildingName + ' Owner';
            }
            
            con.Email = exUerWrap.email;
            con.Phone = exUerWrap.phone;
            con.MailingCity = exUerWrap.cityName;
            Insert Con;
            System.debug(con);
            
            Profile profile1 = [Select Id from Profile where name = 'Owner Community'];
            User portalUser = new User(
                ProfileId = profile1.Id,
                Username = con.Email + '.owner.'+ System.now().millisecond() ,
                Alias = 'sfdc',
                Email=con.Email+'.inactive',
                EmailEncodingKey='UTF-8',
                Firstname= con.FirstName,
                Lastname= con.LastName,
                ContactId = con.Id,
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago'
                
            );
            Insert portalUser;
            
            //Set User to Inactive
            setUserInactive(portalUser.Id);        
            
            //Assign Permission sets to Buiding Owner
            AssignPermissionSetToUser(portalUser.Id);
            
            //Share Report folder with Building Owner
            shareReportFolderwithOwner(portalUser.Id);
            
            resMsg.isSucceed = true;            
            resMsg.message = 'External user for Building Owner added successfully.';
           
        }catch(Exception ex){
            resMsg.isSucceed = false;
            resMsg.message = 'Error: ' + ex.getLineNumber() + ': '  + ex.getMessage();
        }
        return resMsg;
    }
    
    @future
    public static void AssignPermissionSetToUser(Id UserId){
        List<PermissionSet> lstPermissionSets = [SELECT Id, Name, Label  FROM PermissionSet WHERE Name = 'CalendarAnything_Default_Permission_Set'];
        if(lstPermissionSets != null && lstPermissionSets.size() > 0){
            List<PermissionSetAssignment> pSetAssignments = new List<PermissionSetAssignment>();
            
            for(PermissionSet pset : lstPermissionSets){
                PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = pset.Id, AssigneeId = UserId);
                pSetAssignments.add(psa);
            }
            Insert pSetAssignments;
        }
    }
    
    @future
    public static void setUserInactive(Id UserId){
        List<User> usersToInactive = [SELECT Id, IsActive FROM User WHERE Id =: UserId LIMIT 1];
        if(usersToInactive != null && usersToInactive.size() > 0){
            usersToInactive[0].IsActive = False;
            Update usersToInactive[0];
        }
    }
    
    @future(callout=true)
    public static void shareReportFolderwithOwner(Id UserId){
        List<Folder> lstFolder = [SELECT Id, name, DeveloperName, Type 
                                  FROM Folder 
                                  WHERE (DeveloperName = 'Owner_Community' AND Type = 'Report') LIMIT 1];
        
        if(lstFolder != null && lstFolder.size() > 0){
            
            System.debug('Folder Details: ' + lstFolder[0]);
            Id folderId = lstFolder[0].Id;
            
            String body = '{ "shares" : [ { "accessType" : "view", "shareType" : "user", "shareWithId" : "' + UserId + '" } ] }';
            
            System.debug('Body: ' + body);
            
            String endpoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v41.0/folders/' + folderId + '/shares';
            
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setBody(body);
            
            HTTP http = new http();
            HttpResponse res = http.send(req);
            System.debug('Response: ' + res);
        }
        
    }
    
    public class ExternalUserWrapper{
        
        @AuraEnabled public boolean isHousekeeper {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String email {get;set;}
        @AuraEnabled public String cityId {get;set;}
        @AuraEnabled public String cityName {get;set;}
        @AuraEnabled public String phone {get;set;}
        @AuraEnabled public String buildingId {get;set;}
        @AuraEnabled public String buildingName {get;set;}        
        
        @AuraEnabled public boolean isDefaultRate {get;set;}
        @AuraEnabled public Double x1BDRate {get;set;}
        @AuraEnabled public Double x2BDRate {get;set;}
        @AuraEnabled public Double x3BDRate {get;set;}
        @AuraEnabled public Double deepCleanRatePremium {get;set;}
        @AuraEnabled public Double studioRate {get;set;}       
        
        @AuraEnabled public Double sunMinCap {get;set;}
        @AuraEnabled public Double monMinCap {get;set;}
        @AuraEnabled public Double tueMinCap {get;set;}
        @AuraEnabled public Double wedMinCap {get;set;}
        @AuraEnabled public Double thuMinCap {get;set;}
        @AuraEnabled public Double friMinCap {get;set;}
        @AuraEnabled public Double satMinCap {get;set;}        
    }
    
    public class ResponseMessage{
        @AuraEnabled public boolean isSucceed {get;set;}
        @AuraEnabled public String message {get;set;}
    }
    
}