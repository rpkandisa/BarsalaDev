({
	doInit : function(component, event, helper) {
		var action = component.get("c.findRedirectUrl");
        action.setCallback(this, function(response) { 
          if(response.getState() === "SUCCESS") { 
			  var hostname = window.location.origin;              
              var strurl = response.getReturnValue();              
              window.location.href = hostname + strurl;
        }}); 
    
        $A.enqueueAction(action); 
	}
})