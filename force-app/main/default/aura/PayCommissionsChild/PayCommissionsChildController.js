({
  onRadioChangeFinish: function(component, event, helper) {
    component.set("v.ChildDisapproveObj.paymentSend", true);
  },

  handleClickOnFinish: function(component, event, helper) {
    console.log("handleClickOnFinish"); //OnFinishClick

    var recordId = component.get("v.ChildrecordId");
    console.log("Child recordId ::" + recordId);

    window.location.href = "/" + recordId;
  },

  closeModel: function(component, event, helper) {
    component.set("v.ChildShowPopup", false);
    component.set("v.ChildDisapproveObj.IsDisable", false);
    component.set("v.ChildDisapproveObj.IsEnable", false);
    var book = component.get("v.ChildDisapproveObj");
    book.isokay = false;
    var compEvent = component.getEvent("PayCommissionEvent");
    compEvent.setParams({ disApprovedBooking: book });
    compEvent.fire();
  },

  submitDetails: function(component, event, helper) {
    var book = component.get("v.ChildDisapproveObj");
    if (book.reason == null || book.reason == undefined) {
      console.log("Please Enter Reason");
      component.set("v.ChildshowError", true);
      component.set("v.errorMessage", "Please Enter Reason");
      component.set(
        "v.toastcss",
        "slds-notify slds-notify_toast slds-theme_error"
      );
    } else {
      book.isokay = true;
      component.set("v.ChildShowPopup", false);
      var compEvent = component.getEvent("PayCommissionEvent");
      compEvent.setParams({ disApprovedBooking: book });
      compEvent.fire();
    }
  },
  closeToast: function(component, event, helper) {
    component.set("v.ChildshowError", false);
  }
});