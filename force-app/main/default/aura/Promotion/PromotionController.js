({
  doInit: function(component, event, helper) {
    helper.resetdefaultvalid(component);
    helper.findmarketingpromotion(component, event, helper);

    let pagetype = component.get("v.pagetype");
    if (pagetype == "wizard") {
      let obj = {};
      obj.recordid = null;
      obj.personname = null;
      obj.basis = "";
      obj.discountamountoverride = 0;
      obj.usagetype = "";
      obj.timesofredeem = 0;
      obj.addon = "";
      obj.appliesto = "";
      obj.timecontrained = "";
      obj.prefertype = "";
      obj.daystouse = undefined;
      obj.startdate = new Date();
      obj.enddate = null;
      obj.promotionapply = "";
      obj.promotionfor = "";
      obj.nameofcampaign = "";
      component.set("v.prevwrpcls", JSON.parse(JSON.stringify(obj)));
      component.set("v.wrpcls", obj);
    } else {
      helper.doInit(component, event, helper);
    }

    helper.findAppliesTo(component, event, helper); // it is used to applies to multipicklist
  },

  promocodechange: function(component, event, helper) {
    let obj = component.get("v.wrpcls");
    let name = obj.promocode.replace(/^\s+|\s+$/gm, "");
    if (name != undefined && name != null && name != "") {
      name = name.toUpperCase();
      obj.promocode = name;
      component.set("v.wrpcls", obj);
    }
  },

  keyCheck: function(component, event, helper) {
    if (event.keyCode == 32 || event.which == 32) {
      event.preventDefault();
    }
  },

  fnsave: function(component, event, helper) {
    //debugger;
    //here need to check guest name
    let obj = component.get("v.wrpcls");
    let pagetype = component.get("v.pagetype");
    if (
      (obj.recordid == undefined ||
        obj.recordid == null ||
        obj.recordid == "") &&
      pagetype == "wizard" &&
      obj.promotionfor !== "Marketing Campaign"
    ) {
      helper.showMessage(
        component,
        event,
        "Guest name is required!",
        "Promotion",
        "error"
      );
    } else if (
      (obj.promocode == undefined ||
        obj.promocode == null ||
        obj.promocode == "") &&
      obj.promotionfor != "Specific Guest" &&
      pagetype == "wizard"
    ) {
      helper.showMessage(
        component,
        event,
        "Please specify a promo code to allow guests to redeem!",
        "Promotion",
        "error"
      );
    } else {
      helper.clearMsg(component);
      helper.save(component, event, helper);
    }
  },
  goBack: function(component, event, helper) {
    helper.goBack(component, event, helper);
  },
  onwrpclschange: function(component, event, helper) {
    //debugger;
    //to reset wrp on action
    let isRecursion = false;
    let obj = component.get("v.wrpcls");
    let objold = component.get("v.prevwrpcls");
    let objvalid = component.get("v.wrpvalidate");

    let iswrporgchange = true;

    if (objold.promocode != obj.promocode) {
      helper.resetdefaultvalid(component);
      if (obj.promocode.length > 0) {
        objvalid.istypeofdiscount = true;
      }
    }
    if (objold.basis != obj.basis) {
      objvalid.isbasis = false;
      if (obj.basis.length > 0) {
        objvalid.isbasis = true;
        objvalid.iscredit = false;
        if (obj.basis == "credit") {
          objvalid.iscredit = true;
        }
      }
    }

    if (
      objold.addon != obj.addon ||
      objold.discountamountoverride != obj.discountamountoverride
    ) {
      objvalid.isfixedorrecurring = false;
      if (
        ((obj.basis == "add-on" && obj.addon.length > 0) ||
          (obj.basis != "add-on" && obj.discountamountoverride > 0)) &&
        !objvalid.iscredit
      ) {
        objvalid.isfixedorrecurring = true;
      } else if (objvalid.iscredit && obj.discountamountoverride > 0) {
        objvalid.isittimecontraint = true;
      }
    }

    if (
      objold.promotionfor != obj.promotionfor &&
      objvalid.ispromotionfor == false
    ) {
      objvalid.ispromotionfor = true;
    }

    if (
      obj.promocode != undefined &&
      obj.promocode != null &&
      obj.promocode != "" &&
      objvalid.ispromotionapply == false
    ) {
      setTimeout(function() {
        //debugger;
        objvalid.ispromotionapply = true;
        obj.promotionapply = "custom";
        component.set("v.wrpcls", obj);
      }, 300);
    }

    if (objold.appliesto != obj.appliesto) {
      //if we need to write any change here
    }

    if (objold.usagetype != obj.usagetype) {
      objvalid.ishowmanytimeguestredeem = false;
      objvalid.isittimecontraint = false;
      if (obj.usagetype == "fixed_use") {
        objvalid.ishowmanytimeguestredeem = true;
        obj.timesofredeem = 1;
        isRecursion = true;
      } else {
        objvalid.isittimecontraint = true;
      }
    }

    if (objold.timesofredeem != obj.timesofredeem && obj.timesofredeem > 0) {
      objvalid.isittimecontraint = true;
    }

    if (objold.timecontrained != obj.timecontrained) {
      objvalid.isprefertype = false;
      objvalid.issave = false;
      if (obj.timecontrained == "Yes") {
        objvalid.isprefertype = true;
      } else if (obj.timecontrained == "No") {
        objvalid.issave = true;
      }
    }

    if (objold.prefertype != obj.prefertype) {
      objvalid.isdayofnow = false;
      objvalid.iscustdate = false;
      if (obj.prefertype == "dayfromnow") {
        objvalid.isdayofnow = true;
      } else if (obj.prefertype == "customdaterange") {
        objvalid.iscustdate = true;
      }
    }

    if (objold.daystouse != obj.daystouse) {
      objvalid.iscustdate = false;
      if (obj.daystouse.length > 0 && obj.daystouse > 0) {
        //objvalid.iscustdate = true;

        let sdt = new Date();
        let edt = new Date();
        obj.startdate = $A.localizationService.formatDate(
          sdt,
          "yyyy-MM-ddTHH:mm:ss.SSSZ"
        );

        edt = edt.setDate(edt.getDate() + parseInt(obj.daystouse));
        obj.enddate = $A.localizationService.formatDate(
          edt,
          "yyyy-MM-ddTHH:mm:ss.SSSZ"
        );
        isRecursion = true;
      }
    }

    if (objold.startdate != obj.startdate || objold.enddate != obj.enddate) {
      objvalid.issave = false;
      if (
        obj.startdate != undefined &&
        obj.startdate.length > 0 &&
        obj.enddate != undefined &&
        obj.enddate.length > 0
      ) {
        objvalid.issave = true;
      }
    }

    if (obj.timecontrained == "No") {
      objvalid.issave = true;
    }

    // if (obj.basis !== "percentage" || obj.basis !== "flat") {
    //   objvalid.issave = true;
    // }

    if (
      obj.promotionapply != undefined &&
      obj.promotionapply !== "" &&
      obj.promotionapply !== "custom"
    ) {
      objvalid.issave = true;
      obj.basis = "";
    }

    if (
      objold.promotionapply != obj.promotionapply &&
      obj.promotionapply == "custom"
    ) {
      objvalid.issave = false;
    }

    component.set("v.prevwrpcls", JSON.parse(JSON.stringify(obj)));
    if (isRecursion) {
      isRecursion = false;
      component.set("v.wrpcls", obj);
    }

    component.set("v.wrpvalidate", objvalid);
  },

  resetpage: function(component, event, helper) {
    var context = component.get("v.context");
    if (context == "classic") {
      window.location.reload();
    } else {
      $A.get("e.force:refreshView").fire();
    }
  },

  onfocusbasisamt: function(component, event, helper) {
    var whichOne = event.getSource().getLocalId();
    var mycmp = component.find(whichOne);
    if (parseInt(mycmp.get("v.value")) <= 0) {
      var mytest = "";
      mycmp.set("v.value", mytest);
    }
  },

  onchangeappliesto: function(component, event, helper) {
    var selectedOptionsList = event.getParam("value");
    console.log(selectedOptionsList);
    component.set("v.selectedArray", selectedOptionsList);
    let obj = component.get("v.wrpcls");
    obj.appliesto = undefined;
    selectedOptionsList.forEach(o => {
      if (obj.appliesto) {
        obj.appliesto += ";" + o;
      } else {
        obj.appliesto = o;
      }
    });
    component.set("v.wrpcls", obj);
  }
});