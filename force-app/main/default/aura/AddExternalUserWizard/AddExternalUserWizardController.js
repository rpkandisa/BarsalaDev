({
	initialize : function(component, event, helper) {
		helper.init(component, event, helper);
        
	},
    
    getUser : function(component, event, helper){
        var userType = component.get("v.UserType");
        console.log('User: ' + component.get("v.UserType"));
        if(userType == "Housekeeping"){
            component.set("v.UserWrap.isHousekeeper", true);
        }else{
            component.set("v.UserWrap.isHousekeeper", false);
        }
    },
    
    doValidation : function(component, event, helper){
        debugger;
       
        let isHousekeeper = component.get("v.UserWrap.isHousekeeper");
        let isValid = true;
        
        let name = component.get("v.UserWrap.name");
        let email = component.get("v.UserWrap.email");
        let city = component.get("v.UserWrap.cityName");
        let building = component.get("v.UserWrap.buildingName");
        
        if(isHousekeeper){
            //For housekeeper Email, Name, City are mandatory.
            if(name == null){
                helper.showToast(component, 'Alert', 'Name is mandatory', 'error');
            }else if(email == null){
                helper.showToast(component, 'Alert', 'Email is mandatory', 'error');
            }else if(city == null){
                helper.showToast(component, 'Alert', 'City is mandatory', 'error');
            }else{
                helper.checkForDuplicateEmail(component, event, helper);
            }
            
        }else{
             //For housekeeper Email, Building are mandatory.
             if(building == null){
                helper.showToast(component, 'Alert', 'building is mandatory', 'error');
            }else if(email == null){
                helper.showToast(component, 'Alert', 'Email is mandatory', 'error');
            }else{
                helper.checkForDuplicateEmail(component, event, helper);
            }
        }
       
        
        
    },
    
     //this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    //this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
})