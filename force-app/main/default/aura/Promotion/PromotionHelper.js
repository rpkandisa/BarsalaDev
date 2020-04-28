({
  doInit: function(component, event, helper) {
    try {
      let eventidparam = component.get("v.recordId");
      var action = component.get("c.findbyaccountid");
      action.setParams({ recordid: eventidparam });
      action.setCallback(this, function(response) {
        var State = response.getState();
        if (State === "SUCCESS") {
          var res = response.getReturnValue();
          if (res != null) {
            res.daystouse = undefined; // set blank on page load
            component.set("v.prevwrpcls", JSON.parse(JSON.stringify(res)));
            component.set("v.wrpcls", res);
          }
        } else if (State === "ERROR") {
          this.showMessage(
            component,
            event,
            JSON.stringify(response.getError()),
            "Promotion",
            "error"
          );
        }
      });
      $A.enqueueAction(action);
    } catch (e) {
      var msg = e.name + " (code " + e.code + "): " + e.message;
      //this.showToast(null, msg, "error", null, component);
      this.showMessage(component, event, msg, "Promotion", "error");
    }
  },

  clearMsg: function(component) {
    component.find("errormsg").set("v.body", "");
  },
  goBack: function(component) {
    var context = component.get("v.context");
    if (context == "classic") {
      let obj = component.get("v.wrpcls");
      if (obj.recordid != null) {
        window.open("/" + obj.recordid, "_parent");
      } else {
        window.open("/" + component.get("v.recordId"), "_parent");
      }
    } else {
      $A.get("e.force:closeQuickAction").fire();
    }
  },
  save: function(component, event, helper) {
    try {
      //obj.enddate = $A.localizationService.formatDate(
      //   dt,
      //   "yyyy-MM-ddTHH:mm:ss.SSSZ"
      // );
      let objcomponent = component;

      let objdata = component.get("v.wrpcls");
      var action = component.get("c.saveData");
      action.setParams({ obj: objdata });
      action.setCallback(this, function(response) {
        var State = response.getState();
        if (State === "SUCCESS") {
          debugger;
          var res = response.getReturnValue();
          this.showMessage(
            component,
            event,
            "Record was saved successfully!",
            "Promotion",
            "success"
          );

          let pagetype = component.get("v.pagetype");
          if (pagetype == "wizard") {
            objdata.recordid = res.Id;
          }

          window.setTimeout(function() {
            helper.goBack(objcomponent);
          }, 150);
        } else if (State === "ERROR") {
          this.showMessage(
            component,
            event,
            JSON.stringify(response.getError()),
            "Promotion",
            "error"
          );
        }
      });
      $A.enqueueAction(action);
    } catch (e) {
      var msg = e.name + " (code " + e.code + "): " + e.message;
      //this.showToast(null, msg, "error", null, component);
      this.showMessage(component, event, msg, "Promotion", "error");
    }
  },
  showMessage: function(component, event, message, title, severity) {
    $A.createComponent(
      "ui:message",
      {
        "aura:id": "errMsg",
        title: title,
        severity: severity,
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
  resetdefaultvalid: function(component) {
    let o = {};
    o.istypeofdiscount = false;
    o.isbasis = false;
    o.isdiscandaddon = false;
    o.iscredit = false;
    o.isfixedorrecurring = false;
    o.isfixed = false;
    o.ishowmanytimeguestredeem = false;
    o.isittimecontraint = false;
    o.isprefertype = false;
    o.isdayofnow = false;
    o.iscustdate = false;
    o.issave = false;
    o.ispromotionfor = false;
    o.ispromotionapply = false;
    component.set("v.wrpvalidate", o);
  },

  findAppliesTo: function(component, event, helper) {
    try {
      var options = [];
      component.set("v.listOptions", options);

      var action = component.get("c.findAppliesTo");
      action.setCallback(this, function(response) {
        var State = response.getState();
        if (State === "SUCCESS") {
          //need to write code to fill array
          var resultArray = response.getReturnValue();
          component.set("v.listOptions", resultArray);
        } else if (State === "ERROR") {
          this.showMessage(
            component,
            event,
            JSON.stringify(response.getError()),
            "Promotion",
            "error"
          );
        }
      });
      $A.enqueueAction(action);
    } catch (e) {
      var msg = e.name + " (code " + e.code + "): " + e.message;
      //this.showToast(null, msg, "error", null, component);
      this.showMessage(component, event, msg, "Promotion", "error");
    }
  },

  findmarketingpromotion: function(component, event, helper) {
    try {
      var options = [];
      component.set("v.marketingpromotion", options);

      var action = component.get("c.findAllMarketingOption");
      action.setCallback(this, function(response) {
        var State = response.getState();
        if (State === "SUCCESS") {
          //need to write code to fill array
          var resultArray = response.getReturnValue();
          component.set("v.marketingpromotion", resultArray);
        } else if (State === "ERROR") {
          this.showMessage(
            component,
            event,
            JSON.stringify(response.getError()),
            "Promotion",
            "error"
          );
        }
      });
      $A.enqueueAction(action);
    } catch (e) {
      var msg = e.name + " (code " + e.code + "): " + e.message;
      //this.showToast(null, msg, "error", null, component);
      this.showMessage(component, event, msg, "Promotion", "error");
    }
  }
});