@RestResource(urlMapping='/merge/*')
global class MergePersonAccountRestAPI {
    
    @HttpPost 
    global static ResponseMessage mergeRecords(String masterId,string mergeId) {
        
        ResponseMessage response;
        
        Set<Id> ids = new Set<Id>{masterId,mergeId};
        List<Account> lstFindDupAccount = new List<Account>();
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Account.fields.getMap();
        List<String> fieldsName = new List<String>( schemaFieldMap.keySet() );
        String query =
                ' SELECT ' + String.join(fieldsName, ',' ) +
                ' FROM ACCOUNT ' +
                ' WHERE  Id IN :ids';
        lstFindDupAccount = Database.query(query);

        Map<Id,Account> mapAccounts = new Map<Id,Account>();

        Boolean blnMobAppUser = false;
        for (Account objacc : lstFindDupAccount) {
            if(objacc.Mobile_App_User__pc){
                blnMobAppUser = true;
            }
            mapAccounts.put(objacc.Id, objacc);
        }

       if(mapAccounts.size()>0){
            //check masterid name
            //cheking airecall account and normal account
            if((mapAccounts.containsKey(masterId) && mapAccounts.get(masterId).Name.tolowercase().contains('aircall person')) && (mapAccounts.containsKey(mergeId) && !mapAccounts.get(mergeId).Name.tolowercase().contains('aircall person'))){
                string tempid = masterId;
                masterId = mergeId;
                mergeId = tempid;
            }
           
        }

        Integer cnt = 0;
        if(blnMobAppUser){
            for (Account objacc : lstFindDupAccount) {
                if(objacc.Mobile_App_User__pc){
                    cnt++;
                    masterId = objacc.Id;
                }else{
                    mergeId = objacc.Id;
                }
            }
        }
        

        if(cnt > 1){
            return new ResponseMessage('FAIL','We could not merge these 2 customers as the mobile app user (checkbox) is selected on both the customers!', '');
        }else{
        
            Map<Id, Account> mapMasterAccount = new Map<Id, Account>(lstFindDupAccount);            
            Database.MergeResult[] result = Database.merge(new Account(Id = masterId), new List<Account>{ new Account(Id = mergeId) }, false);  
            for(Database.MergeResult res : result){
                if (!res.isSuccess()) {
                    for(Database.Error err : res.getErrors()){
                        return new ResponseMessage('FAIL',err.getMessage(), '');
                    }
                }
            }            
            return fnMergePersonAccount(mapMasterAccount,masterId,mergeId);
        }
    }
    
    global static ResponseMessage fnMergePersonAccount(Map<Id,Account> mapMasterAccount, string masterId,String mergeId)
    {
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Account.fields.getMap();
        List<String> fieldsName = new List<String>( schemaFieldMap.keySet() );
		ResponseMessage response;

        Map<Id,Account> mapAccount = new Map<Id,Account>();
        Boolean isAccMasterChange = false;
        for (Account a : mapMasterAccount.values()) {

            if(a.Id == masterId) continue;
            
            isAccMasterChange = false;            
            Account m = new Account(Id = masterId);
            if(mapMasterAccount.containsKey(m.Id)){
                m = mapMasterAccount.get(m.Id);
            }
            for (String fieldName: schemaFieldMap.keySet()) {
                try { 
                    DescribeFieldResult fieldDescribe = schemaFieldMap.get(fieldName).getDescribe();
                    if(m.get(fieldName) == null && a.get(fieldName) != null && fieldDescribe.isAccessible() && fieldDescribe.isUpdateable()){
                        isAccMasterChange = true;
                        m.put(fieldName, a.get(fieldName)); 
                    }

                } catch (SObjectException e)    { 
                    return new ResponseMessage('FAIL', e.getMessage(), '');
                }
            }
            if(isAccMasterChange){
                mapAccount.put(m.Id, m);
            }             
           
        }

        if(mapAccount.size()>0){
            Database.SaveResult[] result = Database.update(mapAccount.values(), false);
            
            for(Database.SaveResult res : result){
                if (!res.isSuccess()) {
                    for(Database.Error err : res.getErrors()){
                        return new ResponseMessage('FAIL',err.getMessage(), '');
                    }
                }
            }
        }
        
        return new ResponseMessage('SUCCESS','Successfully Merged', masterId);
    }
    
    global class ResponseMessage
    {
        public string MessageStatus;
        public string MessageText;
        public string masterId;
        
        public ResponseMessage(string status,string text, string masterId)
        {
            this.MessageStatus = status;
            this.MessageText = text;
            this.masterId = masterId;
        }
    }
    
}