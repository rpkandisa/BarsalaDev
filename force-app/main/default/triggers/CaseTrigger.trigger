//created by Kandisatech on 03/01/2018
//Auto-assign to first email responding agent
trigger CaseTrigger on Case (before insert, before update, after Update, after insert) {
    /*system.debug('@@@ populateBookingOnCase=='+CaseTriggerHandler.isRecursion);
    if(trigger.isBefore && trigger.isInsert){
        system.debug('@@@ populateBookingOnCase- before insert -');
        system.debug('@@@ populateBookingOnCase- before insert -'+trigger.new[0].ContactId);
    }
    if(trigger.isAfter && trigger.isInsert){ 
        system.debug('@@@ populateBookingOnCase- after insert -');
        system.debug('@@@ populateBookingOnCase- after insert -'+trigger.new[0].ContactId);
    }
    if(trigger.isBefore && trigger.isUpdate){
        system.debug('@@@ populateBookingOnCase- before update -');
        system.debug('@@@ populateBookingOnCase- before update -'+trigger.new[0].ContactId);
    }
    if(trigger.isAfter && trigger.isUpdate){
        system.debug('@@@ populateBookingOnCase- after update -');
        system.debug('@@@ populateBookingOnCase- after update -'+trigger.new[0].ContactId);
    }*/

    Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
    

    if(!objBarsalaSetting.Do_you_want_to_stop_to_run_Case_trigger__c || Test.isRunningTest()) {

        //to send email to slack channel when case gets updated with owner kelly and email contain @airbnb.com
        if(trigger.isAfter && trigger.isUpdate && !EmailForwardToSlackChannel.isRecurssion && objBarsalaSetting.Forward_Email_on_Slack_Channel__c){ 
            EmailForwardToSlackChannel.fnSendEmailToSlackChannel(trigger.new, trigger.oldMap);
        }

        if(trigger.isBefore && !CaseTriggerHandler.isRecursion){        
            if(trigger.isInsert){

                //system.debug('@@@ trigger.new -' + trigger.new);

                CaseTriggerHandler.populateBookingOnCase(trigger.new, trigger.isAfter);

                //for (Case objc : trigger.new) {
                    //if(objc.Escalation_Date__c == null){
                        //objc.Escalation_Date__c = System.now();
                    //}
                //}
            }               
        }

         

        if(trigger.isAfter ){   
            //Auto-assign to first email responding agent        
            if(trigger.isInsert){              
                if(!CaseRoundRobin.isRecursion && objBarsalaSetting.Enable_Round_Robin_Trigger__c){
                    Map<string,Id> mapEmailvsCaseId = new Map<string,Id>();
                    List<Case> lstCase = new List<Case>();
                    Set<Id> caseIds = new Set<Id>();
                    String strlablesupportemail = objBarsalaSetting.Support_Email_for_Close_Case__c;
                    
                    for (Case obj : trigger.new){
                        if(obj.ContactId == null && !string.isblank(obj.SuppliedEmail)){
                            mapEmailvsCaseId.put(obj.SuppliedEmail.tolowercase(), obj.Id);
                        }
                    }

                    if(mapEmailvsCaseId.size()>0){
                        CaseRoundRobin.SetContact(mapEmailvsCaseId); 
                    }

                    for (Case obj : [select id,contactid,contact.Email,SuppliedEmail,Do_you_want_to_stop_auto_assign_Case__c from Case where id in: trigger.new]) {
                         //system.debug('@@@ trigger.new after' + obj);
                         //system.debug('@@@ trigger.new after' + obj.contact.Email);
                         //system.debug('@@@ trigger.new after' + strlablesupportemail);
                        if((obj.contactid != null && !string.isblank(obj.Contact.Email) && !string.isblank(strlablesupportemail) && obj.Contact.Email.tolowercase() == strlablesupportemail.tolowercase())){
                            //system.debug('@@@ trigger.new after@@@ ' + obj);
                            obj.ContactId = null; obj.Booking__c = null; obj.AccountId = null; obj.Status = 'Closed'; obj.Auto_Solve__c=true;
                            lstCase.add(obj);
                            continue;
                        }

                        if(obj.Do_you_want_to_stop_auto_assign_Case__c == true) continue;
                        caseIds.add(obj.Id);
                    }
                    //system.debug('@@@ lstCase-' + lstCase);
                    system.debug('@@@ lstCase-' + caseIds);
                    CaseRoundRobin.isRecursion = true;
                    if(caseIds.size()>0) CaseRoundRobin.fnRoundRobinOwnerAssignmentfuture(caseIds);

                    if(lstCase.size()>0){
                        CaseTriggerHandler.isRecursion = true; CaseRoundRobin.isRecursionEscalate = true;CaseRoundRobin.isRecursion = true;
                        //system.debug('@@@ lstCase-' + lstCase);
                        Update lstCase;
                        
                        //Database.update(lstCase,false);
                        //system.debug('@@@ lstCase-' + lstCase);
                    }
                }
                
            } 

            if(trigger.isInsert || trigger.isUpdate){
                if(!CaseTriggerHandler.isRecursion){
                    CaseTriggerHandler.populateBookingOnCase(trigger.new, trigger.isAfter);
                }
            }               
        }

        //system.debug('@@@@@@   ' + CaseRoundRobin.isRecursionEscalate + ' @ ' + objBarsalaSetting.Enable_Round_Robin_Trigger__c + ' @ ' + objBarsalaSetting.Enable_Escalation_Level__c );
        if(trigger.isAfter && trigger.isUpdate && !CaseRoundRobin.isRecursionEscalate && objBarsalaSetting.Enable_Round_Robin_Trigger__c && objBarsalaSetting.Enable_Escalation_Level__c){ // Case Escalation 
            CaseRoundRobin.fnRoundRobinOwnerAssignmentEscalation(trigger.new, trigger.oldMap);
        }
    }

    
}