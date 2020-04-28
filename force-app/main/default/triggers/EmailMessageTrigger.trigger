//added by Kandisa Tech on 03/01/2019
//It is used to create person account record if newly created case does not haveing Account/Contact
trigger EmailMessageTrigger on EmailMessage (after insert, before Insert) {
    System.debug('@@@@lstEmailMsg@@@ ' + trigger.isAfter);
    if(trigger.isAfter && !EmailMessageTriggerHandler.isRecursion){
        EmailMessageTriggerHandler.fnCreatePersonAccount(trigger.new);
    }

    // if(trigger.isBefore){
    //     EmailMessageTriggerHandler.fnChangeFromAddress(trigger.new);
    // }
}