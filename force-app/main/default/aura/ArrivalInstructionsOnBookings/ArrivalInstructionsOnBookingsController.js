({
	init : function(component, event, helper) {
		var recordId = component.get("v.recordId");
        console.log('recordId --> ' + recordId);
        
        var action = component.get("c.getBookingArrivalInstruction");
        action.setParams({  BookingId : recordId  });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
           
            console.log('state --> ' + state);
            if (state === "SUCCESS") {
                component.set('v.arrInstuctionsDetails',response.getReturnValue() );
                component.set('v.InstructionCount',component.get("v.arrInstuctionsDetails.sharinPixImagesList.length") );
               console.log('lenght => ' + component.get("v.InstructionCount"));
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
               
        });
        $A.enqueueAction(action);
	}
})