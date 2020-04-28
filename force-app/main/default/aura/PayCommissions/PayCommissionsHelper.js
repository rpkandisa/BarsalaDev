({
  doInitHelperMethod: function(component, event, helper) {
    debugger;
    var action = component.get("c.getPastBookings");
    action.setParams({
      AccountId: component.get("v.recordId")
    });

    action.setCallback(this, function(response) {
      var State = response.getState();
      if (State === "SUCCESS") {
        var res = response.getReturnValue();
        component.set("v.bookingList", res);

        if (res.length == 0) {
          component.set("v.isRecordExists", true);
        }
      } else if (State === "ERROR") {
        let errmsg = JSON.stringify(response.getError());
        helper.showMessage(component, event, errmsg, "Error");
      }
    });
    $A.enqueueAction(action);
  },

  fnSaveRejectPay: function(component, event, helper) {
    helper.clearMsg(component);
    let lst = [];
    let lstbooking = component.get("v.bookingList");

    lstbooking.forEach(o => {
      if ($A.util.isEmpty(o.reason) == false && o.isrecordchange == true) {
        lst.push(Object.assign({}, o));
      }
    });

    var action = component.get("c.SaveRejectPay");
    action.setParams({
      lstwrp: lst
    });

    action.setCallback(this, function(response) {
      var State = response.getState();
      if (State === "SUCCESS") {
        var res = response.getReturnValue();

        var totalAmount = 0.0;
        lstbooking.forEach(obj => {
          if (
            $A.util.isEmpty(obj.approverejectstatus) == false &&
            obj.approverejectstatus == "approved" &&
            $A.util.isEmpty(obj.commissionamount) == false
          ) {
            totalAmount += obj.commissionamount;
          }
        });
        component.set("v.showAmount", true);
        component.set("v.CommisionAmount", totalAmount);
      } else if (State === "ERROR") {
        let errmsg = JSON.stringify(response.getError());
        helper.showMessage(component, event, errmsg, "Error");
      }
    });
    $A.enqueueAction(action);
  },
  fnSaveData: function(component, event, helper) {
    helper.clearMsg(component);
    let lst = [];
    let lstbooking = component.get("v.bookingList");

    lstbooking.forEach(o => {
      if (
        $A.util.isEmpty(o.approverejectstatus) == false &&
        o.approverejectstatus == "approved" &&
        o.isrecordchange == true
      ) {
        lst.push(Object.assign({}, o));
      }
    });

    var action = component.get("c.SaveApprovedData");
    action.setParams({
      lstwrp: lst
    });

    action.setCallback(this, function(response) {
      var State = response.getState();
      if (State === "SUCCESS") {
        var res = response.getReturnValue();
        helper.sendemail(component, event, helper);
      } else if (State === "ERROR") {
        let errmsg = JSON.stringify(response.getError());
        helper.showMessage(component, event, errmsg, "Error");
      }
    });
    $A.enqueueAction(action);
  },
  sendemail: function(component, event, helper) {
    var action = component.get("c.sendEmailToAccount");
    action.setParams({
      AccountId: component.get("v.recordId")
    });

    action.setCallback(this, function(response) {
      var State = response.getState();
      if (State === "SUCCESS") {
        window.location.href = "/" + component.get("v.recordId");
      } else if (State === "ERROR") {
        let errmsg = JSON.stringify(response.getError());
        helper.showMessage(component, event, errmsg, "Error");
      }
    });
    $A.enqueueAction(action);
  },

  showMessage: function(component, event, message, title) {
    $A.createComponent(
      "ui:message",
      {
        "aura:id": "errMsg",
        title: title,
        severity: "error",
        closable: true,
        body: message
      },
      function(newMsg, status, errorMessage) {
        //Add the new button to the body array
        if (status === "SUCCESS") {
          var cmp = component.find("errormsg");
          var body = cmp.get("v.body");
          body.push(newMsg);
          cmp.set("v.body", body);
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
          // Show offline error
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
          // Show error message
        }
      }
    );
  },

  clearMsg: function(component) {
    component.find("errormsg").set("v.body", "");
  }
});