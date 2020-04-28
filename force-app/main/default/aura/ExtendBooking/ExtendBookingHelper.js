({
    toggle: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },

    showMessage : function(component, event, message, title) {
        $A.createComponent(
            "ui:message",
            {
                "aura:id": "errMsg",
                "title": title,
                "severity": "error",
                "closable" : true,
                "body": message
            },
            function(newMsg, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var cmp = component.find("errormsg");
                    var body = cmp.get("v.body");
                    body.push(newMsg);
                    cmp.set("v.body", body);
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
        
    },

    clearMsg : function(component){
        component.find("errormsg").set("v.body",'');
    },

    Btn : function(component,btnState){
        if(btnState == 'enable')
            component.find("searchbtn").set("v.disabled",false);
        else
            component.find("searchbtn").set("v.disabled",true);
    },

    initilizeExpDateOptions : function(cmp, event){
        var expMonthOptions = [{'label': 'MM', 'value': ''}];
        const MONTH_NAMES = ["January", "February", "March", "April", "May", "June",
          "July", "August", "September", "October", "November", "December"
        ];

        for(var i=1; i<=12;i++){
            var str = (i<10) ? '0'+i : i
            var option = {};
            option.label = str+'-'+MONTH_NAMES[i-1];
            option.value = str; 
            expMonthOptions.push(option);
        }
        cmp.set("v.expMonthOptions", expMonthOptions);

        var expYearOptions = [{'label': 'YYYY', 'value': ''}];
        var today = new Date();
        for(var i=0; i<=14;i++){
            var str = today.getFullYear()+i;
            var option = {};
            option.label = str
            option.value = str; 
            expYearOptions.push(option);
        }
        cmp.set("v.expYearOptions", expYearOptions);
    },

    showElementValidationError : function(cmp, event, elementName){
        var element = cmp.find(elementName);
        element.set('v.validity', {valid:false,badInput :true});
        element.focus();
    },

    validateCreditCardData : function(cmp, event){
        var ccModel = cmp.get("v.ccModel");
        var isError = false;
        var expDateError = false;

        if(ccModel.zipCode == undefined || ccModel.zipCode.length==0){
            this.showElementValidationError(cmp,event,'zipCode');
            isError = true;
        }
        /*if(ccModel.cardType == undefined || ccModel.cardType.length==0){
            this.showElementValidationError(cmp,event,'cardType');
            isError = true;
        }*/
        if(ccModel.cardName == undefined || ccModel.cardName.length==0){
            this.showElementValidationError(cmp,event,'cardName');
            isError = true;
        }
        if(ccModel.cvv == undefined || ccModel.cvv.length<3 || isNaN(ccModel.cvv)){
            this.showElementValidationError(cmp,event,'cvv');
            isError = true;
        }

        if(ccModel.expYear == undefined || ccModel.expYear.length==0){
            this.showElementValidationError(cmp,event,'expYear');
            isError = true;
            expDateError = true;
        }
        if(ccModel.expMonth == undefined || ccModel.expMonth.length==0){
            this.showElementValidationError(cmp,event,'expMonth');
            isError = true;
            expDateError = true;
        }
        
        if(!expDateError){
            var todayDate = new Date();
            var expDate = new Date(ccModel.expYear,ccModel.expMonth,0);
            console.log(expDate);
            console.log(todayDate);
            console.log(expDate<todayDate);
            if(expDate<todayDate){
                this.showElementValidationError(cmp,event,'expYear');
                isError = true;
            }
        }
        if(ccModel.cardNumber == undefined || ccModel.cardNumber.length<12 || isNaN(ccModel.cardNumber)){
            this.showElementValidationError(cmp,event,'cardNumber');
            isError = true;
        }
        return isError;
    },
    
    findUserDetails : function(component, event, helper) {
		var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
    }

})