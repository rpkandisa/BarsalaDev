({
    init : function(component, event, helper) {
        var action = component.get("c.initializeWrapper");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            console.log(JSON.stringify(rtnValue));
            component.set("v.UserWrap", rtnValue);
        });
        $A.enqueueAction(action);
    },
    
    checkForDuplicateEmail : function(component, event, helper) {
        debugger;
        var emailAddress = component.get("v.UserWrap.email");
        var action = component.get("c.IsDuplicateEmail");
        action.setParams({
            email:emailAddress
        });
        action.setCallback(this, function(a){
            var result = a.getReturnValue();
            console.log('checkForDuplicateEmail: ' + result);
            component.set("v.isDuplicateEmailId", result);
            if(result){
                 helper.showToast(component, 'Alert', 'Found duplicate email address.', 'error');
            }else{
                helper.createContactRecord(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    createContactRecord : function(component, event, helper) {
        var userWrap = component.get("v.UserWrap");
        console.log('Final userWrap' + JSON.stringify(userWrap));
        var action = component.get("c.CreateExternalUser");
        
        action.setParams({
            exUerWrap:userWrap
        });
        
        action.setCallback(this, function(result){
       	
            console.log('ResponseMessage: ' + JSON.stringify(result.getReturnValue()));
            if(result.getReturnValue() != null){
                component.set("v.ResponseMessage", result.getReturnValue());
                
                var isSucceed = component.get("v.ResponseMessage.isSucceed");
                var msg = component.get("v.ResponseMessage.message");
                console.log(isSucceed);
                console.log(msg);
                
                if(isSucceed){
                    helper.showToast(component, 'Success!', msg, 'success');
                }else{
                    helper.showToast(component, 'Error', msg, 'error');
                }
            }
            
        });
        $A.enqueueAction(action);
	},
    
    showToast : function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 100',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
   
})