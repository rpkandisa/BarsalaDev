({
  doInit: function(component, event, helper) {
    helper.doInitHelperMethod(component, event, helper);
  },
  onapproverejectchange: function(component, event, helper) {
    helper.clearMsg(component);
    //var changeValue = event.getParam("value");
    let gbid = event.getSource().get("v.name");
    let gbval = event.getSource().get("v.value");

    if (gbval != "") {
      let lst = component.get("v.bookingList");
      let obj = {};
      lst.forEach(o => {
        if (o.bookingid == gbid) {
          if (gbval == "approved") {
            o.isrecordchange = true;
          } else if (gbval == "rejected") {
            obj = Object.assign({}, o);
          }
        }
      });

      if (gbval == "rejected") {
        component.set("v.showPopup", true);
        component.set("v.disapproveObj", obj);
      } else if (gbval == "approved") {
        component.get("v.bookingList", lst);
      }
    }
  },

  handleEvent: function(component, event, helper) {
    helper.clearMsg(component);
    var objnew = event.getParam("disApprovedBooking");
    let lst = component.get("v.bookingList");
    lst.forEach(obj => {
      if (obj.bookingid == objnew.bookingid && objnew.isokay) {
        obj.reason = objnew.reason;
        obj.isrecordchange = true;
      } else if (!objnew.isokay && $A.util.isEmpty(obj.reason)) {
        obj.approverejectstatus = "";
      }
    });
    component.set("v.bookingList", lst);
  },

  completereview: function(component, event, helper) {
    helper.fnSaveRejectPay(component, event, helper);
  },
  gotoBack: function(component, event, helper) {
    helper.clearMsg(component);
    component.set("v.showAmount", false);
  },
  gotoBackOnLoad: function(component, event, helper) {
    window.location.href = "/" + component.get("v.recordId");
  },
  handleClickOnFinish: function(component, event, helper) {
    helper.clearMsg(component);
    helper.fnSaveData(component, event, helper);
  },

  // this function automatic call by aura:waiting event
  showSpinner: function(component, event, helper) {
    // make Spinner attribute true for display loading spinner
    component.set("v.Spinner", true);
  },

  // this function automatic call by aura:doneWaiting event
  hideSpinner: function(component, event, helper) {
    // make Spinner attribute to false for hide loading spinner
    component.set("v.Spinner", false);
  }
});