/**
 * It's used to convert business account to person account when new task created by Aircall
 */

public without sharing class ProcessToConvertBusinessToPersonAccount {

    @InvocableMethod(label='Convert Business Account to Person Account While Creating Task from Aircall')
    public static void convertAccountToPersonAccount(List<wrpbusinesstoperson> lstwrp) {

        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Map<Id,Account> mapAccount = new Map<Id,Account>();
        List<Account> lstDeleteAccount = new List<Account>(); // in this list we can keep the account list
        for (wrpbusinesstoperson wrp : lstwrp) {
            Account objacc = new Account(RecordTypeId=personAccountRecordTypeId);
            objacc.LastName = 'Aircall Person Account '+ wrp.phone;
            objacc.Phone = wrp.phone;
            mapAccount.put(wrp.taskid, objacc);

            lstDeleteAccount.add(new Account(Id = wrp.businessaccountid));
        }

        if(mapAccount.size()>0){
            Database.insert(mapAccount.values(),false); // createing new person account

            List<Task> lstTask = new List<Task>();
            for (Id tskid : mapAccount.keySet()) {
                Task objtsk = new Task(Id = tskid);
                objtsk.WhatId = mapAccount.get(tskid).Id;
                lstTask.add(objtsk);
            }

            Database.update(lstTask,false); // updating task with new person account

            Database.delete(lstDeleteAccount,false); // removing business account
        }        
    }


    public class wrpbusinesstoperson {
        @InvocableVariable(required=true)
        public ID taskid;

        @InvocableVariable(required=true)
        public String phone;

        @InvocableVariable(required=true)
        public Id businessaccountid;
    }
}