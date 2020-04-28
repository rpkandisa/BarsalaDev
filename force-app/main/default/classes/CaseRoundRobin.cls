public without sharing class CaseRoundRobin {
    public static boolean isRecursion = false;
    public static boolean isRecursionEscalate = false;

    @future
    public static void fnRoundRobinOwnerAssignmentfuture(Set<Id> caseIds) {
        fnRoundRobinOwnerAssignment(caseIds, false);
    }

    public static void SetContact(Map<string,Id> mapEmailvsCaseId){
        List<Contact> lstContact = new List<Contact>([select id,Email from Contact where email in: mapEmailvsCaseId.keySet() order by CreatedDate desc]);

        List<Case> lstCase = new List<Case>();
        Set<string> contactEmails = new Set<string>();
        string stremail = '';
        for(Contact c : lstContact){
            stremail = c.Email.tolowercase();
            if(!contactEmails.Contains(stremail)){
                Case objcase = new Case();
                objcase.Id = mapEmailvsCaseId.get(stremail);
                contactEmails.add(stremail);               
                objcase.ContactId = c.Id;
                lstCase.add(objcase);                
            }
        }

        if(lstCase.size()>0){
            CaseRoundRobin.isRecursion = true;
            update lstCase;
        }

    }

    public static void fnRoundRobinOwnerAssignmentWithoutfuture(Set<Id> caseIds) {
        fnRoundRobinOwnerAssignment(caseIds, false);
    }


    public static void fnRoundRobinOwnerAssignment(Set<Id> caseIds, Boolean IsManager) {
        Datetime dt = System.now();
        Time t = System.Time.newInstance(dt.hour(), dt.minute(), 1, 1);

        List<Team_Schedule__c> lst = new List<Team_Schedule__c>();

        string soql = 'Select Id,User__c,Auto_Assign__c from Team_Schedule__c where User__r.isActive=true ';
        string strWhere = fnfindwherequery(dt, IsManager);
        if(!string.isBlank(strWhere)){
            soql += ' and ' + strWhere; 
        }

        soql += ' order by Team_Number__c ASC ';
        //System.debug('soql@@@@ ' + soql);
        lst = Database.query(soql);
        //System.debug('lst@@@@ ' + lst);
        Map<Integer,Id> mapTS = new  Map<Integer,Id>();
        Integer lastAutoAssign = 0;
        for(Team_Schedule__c ts : lst){
            mapTS.put(Integer.valueOf(ts.Auto_Assign__c), ts.User__c);
            lastAutoAssign = Integer.valueOf(ts.Auto_Assign__c);
        }

        //System.debug('mapTS@@@@ ' + mapTS);
        //System.debug('lastAutoAssign@@@@ ' + lastAutoAssign);

        Integer decAutoAssignNumber = 0;
        Barsala_Round_Robin__c objbrr = new Barsala_Round_Robin__c();
        Map<String, Barsala_Round_Robin__c> mapWeekDaySettings = Barsala_Round_Robin__c.getAll();
        if(mapWeekDaySettings != null && mapWeekDaySettings.size() > 0){
            objbrr = findLastAssignee(dt, mapWeekDaySettings);            
            decAutoAssignNumber = Integer.valueOf(objbrr.Auto_Assign_Number__c);
        }

        //System.debug('objbrr@@@@ ' + objbrr);
        //System.debug('decAutoAssignNumber@@@@ ' + decAutoAssignNumber);

        List<Case> lstCase = new List<Case>();
        Id currentAssignee  = null;
        Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
        for(Case objcasedata : [SELECT id,Escalation_Date__c, Priority, Escalate__c, Do_you_want_to_stop_auto_assign_Case__c from Case where id in: caseIds]){
            
            if(objcasedata.Do_you_want_to_stop_auto_assign_Case__c)  continue;
            
            Id caseId = objcasedata.Id;
            for (Integer intAutoAssign : mapTS.keySet()) {                
                if(intAutoAssign > decAutoAssignNumber){
                    currentAssignee = mapTS.get(intAutoAssign);
                    decAutoAssignNumber = intAutoAssign;
                    if(lastAutoAssign == intAutoAssign) decAutoAssignNumber = 0;                    
                    break;
                }
            }

            //System.debug('decAutoAssignNumber@@@@ ' + decAutoAssignNumber);

            if(currentAssignee == null){
                for (Integer intAutoAssign : mapTS.keySet()) {                                       
                    currentAssignee = mapTS.get(intAutoAssign);
                    decAutoAssignNumber = intAutoAssign;                   
                    break;
                }

                if(mapTS.size() == 0){
                    currentAssignee = (Id)objBarsalaSetting.Case_Assignment_Queue_Id__c;
                }
            }     

            //System.debug('currentAssignee@@@@ ' + currentAssignee); 
            //System.debug('decAutoAssignNumber@@@@ ' + decAutoAssignNumber);        

            if(currentAssignee != null){

                //System.debug('decAutoAssignNumber@@@@ ' + objcasedata);

                Case objcase = new Case(Id = caseId);

                if(objcasedata.Escalation_Date__c == null){
                    objcase.Escalation_Date__c = System.now();
                    objcasedata.Escalation_Date__c = System.now();
                    objcase = fnRoundRobinDate(objcasedata);
                }
                objcase.OwnerId = currentAssignee;  
                if(IsManager){
                    objcase.Escalate__c = '1';
                }
                if(String.valueof(currentAssignee).startsWithIgnoreCase('00G') || objBarsalaSetting.Enable_Escalation_Level__c == false){
                    objcase.Escalation_Date__c = null;
                    objcase.Escalation_Level_1__c = null;
                    objcase.Escalation_Level_1_Reminder__c = null;
                    objcase.Escalation_Level_2__c = null;
                    objcase.Escalation_Level_2_Reminder__c = null;
                }
                lstCase.add(objcase);
            }            
        }

        if(lstCase.size() > 0){
            CaseRoundRobin.isRecursion = true;
            System.debug('lstCase@@@@ ' + lstCase);
            update lstCase;
            System.debug('lstCase@@@@ ' + lstCase);
        }

        if(objbrr != null && objbrr.Id != null && !IsManager){
            System.debug('decAutoAssignNumber@@@@ ' + decAutoAssignNumber);
            objbrr.Auto_Assign_Number__c = decAutoAssignNumber;
            Update objbrr;
        }

    }

    @TestVisible
    private static string fnfindwherequery(Datetime dt, Boolean IsManager){
        if(dt.format('EEEE') == 'Monday'){
            return ' Mon_End__c >=: t and Mon_Start__c <=: t and Mon_Manager__c=' + IsManager ;
        }else if(dt.format('EEEE') == 'Tuesday'){
            return ' Tue_End__c >=: t and Tue_Start__c <=: t and Tue_Manager__c=' + IsManager ;
        }else if(dt.format('EEEE') == 'Wednesday'){
            return ' Wed_End__c >=: t and Wed_Start__c <=: t and Wed_Manager__c=' + IsManager ;
        }else if(dt.format('EEEE') == 'Thursday'){
            return ' Thu_End__c >=: t and Thu_Start__c <=: t and Thu_Manager__c=' + IsManager ;
        }else if(dt.format('EEEE') == 'Friday'){
            return ' Fri_End__c >=: t and Fri_Start__c <=: t and Fri_Manager__c=' + IsManager ;
        }else if(dt.format('EEEE') == 'Saturday'){
            return ' Sat_End__c >=: t and Sat_Start__c <=: t and Sat_Manager__c=' + IsManager ;
        }else if(dt.format('EEEE') == 'Sunday'){
            return ' Sun_End__c >=: t and Sun_Start__c <=: t and Sun_Manager__c=' + IsManager ;
        }
        return '';
    }

    @TestVisible
    private static Barsala_Round_Robin__c findLastAssignee(Datetime dt, Map<String, Barsala_Round_Robin__c> mapWeekDaySettings){
        if(dt.format('EEEE') == 'Monday'){
            return mapWeekDaySettings.get(dt.format('EEEE'));
        }else if(dt.format('EEEE') == 'Tuesday'){
            return mapWeekDaySettings.get(dt.format('EEEE'));
        }else if(dt.format('EEEE') == 'Wednesday'){
            return mapWeekDaySettings.get(dt.format('EEEE'));
        }else if(dt.format('EEEE') == 'Thursday'){
            return mapWeekDaySettings.get(dt.format('EEEE'));
        }else if(dt.format('EEEE') == 'Friday'){
            return mapWeekDaySettings.get(dt.format('EEEE'));
        }else if(dt.format('EEEE') == 'Saturday'){
            return mapWeekDaySettings.get(dt.format('EEEE'));
        }else if(dt.format('EEEE') == 'Sunday'){
            return mapWeekDaySettings.get(dt.format('EEEE'));
        }
        return null;
    }

    public static void fnRoundRobinOwnerAssignmentEscalation(List<Case> lstCase, Map<Id,Case> mapCase) {
        Set<Id> setCases = new Set<Id>();
        List<Case> lstUpdateCase = new List<Case>();
        
        for (Case objcase : lstCase) {           
            Case objcaselevel = new Case(Id = objcase.Id, Escalation_Date__c = objcase.Escalation_Date__c, Priority = objcase.Priority, Escalate__c = objcase.Escalate__c);

            //System.debug('objcase@@@@@@@' + objcase);
            if(objcase.Do_you_want_to_stop_auto_assign_Case__c == true) continue;
            //System.debug('fnRoundRobinOwnerAssignmentEscalation@@@@@@@' + mapCase.get(objcase.Id));
            if(mapCase.containsKey(objcase.Id) && mapCase.get(objcase.Id).Escalation_Date__c != objcase.Escalation_Date__c && objcase.Escalation_Date__c != null){   
                //System.debug('objcase@@@@@@@111' + objcase);             
                objcaselevel = fnRoundRobinDate(objcaselevel);
                if(objcase.Escalate__c == null || mapCase.get(objcase.Id).Escalate__c == objcase.Escalate__c)
                    lstUpdateCase.add(objcaselevel);
            }

            if(mapCase.containsKey(objcase.Id) && mapCase.get(objcase.Id).Escalate__c != objcase.Escalate__c){
                if(objcase.Escalate__c == '1' ){//&& (objcase.Status == 'New' || objcase.Status == 'Open')
                    setCases.add(objcase.Id);
                }else if(objcase.Escalate__c == '2'){
                    //Case objcaselevel2 = new Case(Id = objcase.Id, Escalation_Date__c = objcase.Escalation_Date__c);
                    objcaselevel.OwnerId = (Id)label.Escalate_Level_2_UserId; 
                    lstUpdateCase.add(objcaselevel);
                }else if(objcase.Escalate__c == '3'){
                    //Case objcaselevel3 = new Case(Id = objcase.Id, Escalation_Date__c = objcase.Escalation_Date__c);
                    objcaselevel.OwnerId = (Id)label.Escalate_Level_3_UserId; 
                    lstUpdateCase.add(objcaselevel); 
                }
            }
        }

        if(setCases.size()>0){
            fnRoundRobinOwnerAssignment(setCases, true);
        }

        if(lstUpdateCase.size()>0){
            CaseRoundRobin.isRecursionEscalate = true;
            Update lstUpdateCase;
        }        
    }

    public static Case fnRoundRobinDate(Case obj){
        Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
        Decimal decHours = 0;
        if(objBarsalaSetting.Case_Priority_High_Hrs__c != null && !String.IsBlank(obj.Priority) && obj.Priority == 'High'){
            decHours = objBarsalaSetting.Case_Priority_High_Hrs__c;
        }
        if(objBarsalaSetting.Case_Priority_Low_Hrs__c != null && !String.IsBlank(obj.Priority)  && obj.Priority == 'Low'){
            decHours = objBarsalaSetting.Case_Priority_Low_Hrs__c;
        }
        if(objBarsalaSetting.Case_Priority_Normal_Hrs__c != null && !String.IsBlank(obj.Priority)  && obj.Priority == 'Normal'){
            decHours = objBarsalaSetting.Case_Priority_Normal_Hrs__c;
        }
        if(objBarsalaSetting.Case_Priority_Urgent_Hrs__c != null && !String.IsBlank(obj.Priority) && obj.Priority == 'Urgent'){
            decHours = objBarsalaSetting.Case_Priority_Urgent_Hrs__c;
        }

        if(decHours > 0){
            decHours = decHours/24;
        }

        Datetime dt = obj.Escalation_Date__c;
        if(string.isblank(obj.Escalate__c)){
            obj.Escalation_Level_1__c = dt + decHours;
            obj.Escalation_Level_1_Reminder__c = obj.Escalation_Level_1__c.addMinutes(-5);
            obj.Escalation_Level_2__c = obj.Escalation_Level_1__c + decHours;
            obj.Escalation_Level_2_Reminder__c = obj.Escalation_Level_2__c.addMinutes(-5);

            /* obj.Escalation_Level_1__c = dt.addMinutes(2);
             obj.Escalation_Level_1_Reminder__c = dt.addMinutes(1);
             obj.Escalation_Level_2__c = dt.addMinutes(4);
             obj.Escalation_Level_2_Reminder__c = dt.addMinutes(3);*/
        }
        else if(obj.Escalate__c == '1'){
            obj.Escalation_Level_2__c = dt + decHours;
            obj.Escalation_Level_2_Reminder__c = obj.Escalation_Level_2__c.addMinutes(-5);

            //obj.Escalation_Level_2__c = dt.addMinutes(6);
            //obj.Escalation_Level_2_Reminder__c = dt.addMinutes(5);
        }
        return obj;
    }
}