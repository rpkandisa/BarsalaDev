public with sharing class MergePersonAccountHandler {

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
        Set<string> setphone = new Set<string>();
        Set<string> setEmail = new Set<string>();

        for (Account objacc : lst) {
            if(!string.isblank(objacc.Phone_Standardized__pc)){
                setphone.add(objacc.Phone_Standardized__pc);
            }

            // if(!string.isblank(objacc.Mobile_Standardized__pc) && objacc.Mobile_Standardized__pc != '1' ){
            //     setphone.add(objacc.Mobile_Standardized__pc);
            // }

            if(!string.isblank(objacc.PersonEmail)){
                setEmail.add(objacc.PersonEmail);
            }
        }

        List<Account> lstFindDupAccount = new List<Account>();
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Account.fields.getMap();
        List<String> fieldsName = new List<String>( schemaFieldMap.keySet() );
        String query =
                ' SELECT ' + String.join(fieldsName, ',' ) +
                ' FROM ACCOUNT ' +
                ' WHERE  isPersonAccount=true and (PersonEmail in: setEmail  or Phone_Standardized__pc in:setphone ) order by LastModifiedDate desc,PersonEmail,Phone_Standardized__pc,Mobile_Standardized__pc  limit 100';
        lstFindDupAccount = Database.query(query);

        // List<Account> lstFindDupAccount = new List<Account>([SELECT ID, PersonEmail,Phone,PersonMobilePhone,Mobile_Standardized__pc,Phone_Standardized__pc FROM ACCOUNT where isPersonAccount=true and (PersonEmail in: setEmail  or Phone_Standardized__pc in:setphone ) order by LastModifiedDate desc,PersonEmail,Phone_Standardized__pc,Mobile_Standardized__pc ]); //or Mobile_Standardized__pc in:setphone

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