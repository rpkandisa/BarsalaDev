({
	init : function(component, event, helper) {
		var recordId = component.get("v.recordId");
        console.log('recordId --> ' + recordId);
        
        var action = component.get("c.getUnitArrivalInstruction");
        action.setParams({  UnitId : recordId  });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
           
            console.log('state --> ' + state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.arrInstuctionsDetails',response.getReturnValue() );
                component.set('v.InstructionCount',component.get("v.arrInstuctionsDetails.sharinPixImagesList.length") );
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
               
        });
        $A.enqueueAction(action);
	}
})