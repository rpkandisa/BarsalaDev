//added by kandisa tech on 21/10/2019
public with sharing class AirBnBMergePersonAccountHandler {

    public static void DupeMergeAccount(List<Account> lst, Id masterId){
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Account.fields.getMap();
        List<String> fieldsName = new List<String>( schemaFieldMap.keySet() );
        String query = ' SELECT ' +  String.join( fieldsName, ',' ) + ' FROM ACCOUNT WHERE  id =:masterId ';
        List<Account> lstMasterAccount = new List<Account>();
        lstMasterAccount = Database.query(query);

        Map<Id, Account> mapMasterAccount = new Map<Id, Account>(lstMasterAccount);

        Map<Id,Account> mapAccount = new Map<Id,Account>();
        Boolean isAccMasterChange = false;
        for (Account a : lst) {

            if(a.Id == masterId) continue;
            
            isAccMasterChange = false;            
            Account m = new Account(Id = masterId);
            if(mapMasterAccount.containsKey(m.Id)){
                m = mapMasterAccount.get(m.Id);
            }
            for (String fieldName: schemaFieldMap.keySet()) {
                try { 
                    
                    if(m.get(fieldName) == null && a.get(fieldName) != null){
                        isAccMasterChange = true;
                        m.put(fieldName, a.get(fieldName)); 
                    }

                    if(fieldName == 'Total_Spend__pc' || fieldName == 'bookings_count__pc' || fieldName == 'guest_bookings_count__pc'){
                        if(a.get(fieldName) != null && m.get(fieldName) != null ){ //&& m.get(fieldName) != a.get(fieldName)
                            isAccMasterChange = true;
                            decimal decSpendAmt = 0;
                            decSpendAmt = ((decimal)m.get(fieldName)) + ((decimal)a.get(fieldName));
                            m.put(fieldName, decSpendAmt);
                            //m.put(fieldName, a.get(fieldName)); 
                        }
                    }
                } catch (SObjectException e)    { 
                    // Intentional capture 
                }
            }
            if(isAccMasterChange){
                mapAccount.put(m.Id, m);
            }             
           
        }

        if(mapAccount.size()>0){
            update mapAccount.values();
        }
    }
    
    public static void MergePersonAccount(List<Account> lst){
        Set<string> setAirbnbIds = new Set<string>();

        for (Account objacc : lst) {
            if(!string.isblank(objacc.Airbnb_ID__pc)){
                setAirbnbIds.add(objacc.Airbnb_ID__pc);
            }
        }

        List<Account> lstFindDupAccount = new List<Account>();
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Account.fields.getMap();
        List<String> fieldsName = new List<String>( schemaFieldMap.keySet() );
        String query =
                ' SELECT ' + String.join(fieldsName, ',' ) +
                ' FROM ACCOUNT ' +
                ' WHERE  isPersonAccount=true and Airbnb_ID__pc in:setAirbnbIds order by LastModifiedDate desc,PersonEmail,Phone_Standardized__pc,Mobile_Standardized__pc  limit 100';
        lstFindDupAccount = Database.query(query);

        system.debug('@@@@@duplicate ' + lstFindDupAccount);

        // Map<string,List<Id>> mapmatchAccounts = new Map<string,List<Id>>();
        
        if(lstFindDupAccount.size()>0){
            Savepoint sp = Database.setSavepoint();
            Account master = new Account(Id = lstFindDupAccount.get(0).Id);

            DupeMergeAccount(lstFindDupAccount, master.Id);

            List<Account> lstMergeAcc = new List<Account>();
            List<Dup_Merge_Log__c> lstLog = new List<Dup_Merge_Log__c>();
            for (Account a : lstFindDupAccount) {
                if(a.Id == master.Id){
                    continue;
                }
                lstMergeAcc.add(new Account(Id = a.Id));
                if(lstMergeAcc.size() == 2){
                    Database.MergeResult[] result = Database.merge(master, lstMergeAcc, false);
                    Integer idxMerge = 0;
                    for(Database.MergeResult res : result){
                        if (!res.isSuccess()) {
                            for(Database.Error err : res.getErrors()){
                                lstLog.add(MergeLog(string.valueof(master.Id), string.valueOf(lstMergeAcc.get(idxMerge).Id),err.getMessage()));
                            }
                        }
                        idxMerge++;
                    }
                    lstMergeAcc = new List<Account>();
                }
            }

            if(lstMergeAcc.size() > 0){
                Integer idxMerge = 0;
                Database.MergeResult[] result = Database.merge(master, lstMergeAcc, false);
                for(Database.MergeResult res : result){
                    if (!res.isSuccess()) {
                        for(Database.Error err : res.getErrors()){
                            lstLog.add(MergeLog(string.valueof(master.Id), string.valueOf(lstMergeAcc.get(idxMerge).Id),err.getMessage()));
                        }
                    }
                    idxMerge++;
                }
            }

            if(lstLog.size()>0){                
                Database.rollback(sp); // if any exception occur in calculation then we will do rollback                
                insert lstLog;
            }
        } 
    }

    public static Dup_Merge_Log__c MergeLog(string masterId, string mergeid, string strException){
        Dup_Merge_Log__c obj = new Dup_Merge_Log__c();
        obj.Merge_Account_Id__c = mergeid;
        obj.Master_Account_Id__c = masterId;
        obj.Exception__c = strException;
        return obj;

    }


}