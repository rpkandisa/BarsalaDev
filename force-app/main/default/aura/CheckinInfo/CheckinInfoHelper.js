({
	showMessage : function(component, event, messages, containerId) {
        var msg = '';
        for(var i=0; i<messages.length;i++){
            msg += messages[i]+'\n';
        }
		$A.createComponents([
                ["ui:message",{
                    "title" : "Info",
                    "severity" : "info",
                }],
                ["ui:outputText",{
                    "value" : msg
                }]
                ],
                function(components, status, errorMessage){
                    if (status === "SUCCESS") {
                        var message = components[0];
                        var outputText = components[1];
                        // set the body of the ui:message to be the ui:outputText
                        message.set("v.body", outputText);
                        var div1 = component.find(containerId);
                        // Replace div body with the dynamic component
                        div1.set("v.body", message);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                        // Show offline error
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
                }
            );
	}
})