({
  doInit: function(component, event, helper) {
    var context = component.get("v.context");
    var action = component.get("c.bookInit");

    action.setParams({ bookingId: component.get("v.recordId") });
    action.setCallback(this, function(a) {
      var state = a.getState();
      // console.log(state +'  '+ a.getReturnValue().fromDate);
      if (state === "SUCCESS") {
        var bookInit = a.getReturnValue();
        component.set("v.bookInit", bookInit);
        component.set("v.toDate", bookInit.toDate);
        if (!context) component.set("v.context", a.getReturnValue().uiContext);
        if (bookInit.userType.toUpperCase() == "STANDARD")
          component.set("v.isPortalUser", false);
        if (bookInit.isError && bookInit.isError == true) {
          helper.clearMsg(component);
          var errmsgs = "";
          for (var i = 0; i < bookInit.messages.length; i++) {
            errmsgs += bookInit.messages[i] + "\n";
          }
          helper.showMessage(
            component,
            event,
            errmsgs,
            "Extension not supported"
          );
        }
      } else if (state === "ERROR") {
        console.log(a.getError());
        $A.log("Errors", a.getError());
      }
    });
    $A.enqueueAction(action);
    helper.initilizeExpDateOptions(component, event);
    helper.findUserDetails(component, event, helper);

    var ccModel = {};
    ccModel.zipCode = "";
    //ccModel.cardType = '';
    ccModel.cardName = "";
    ccModel.cvv = "";
    ccModel.expYear = "";
    ccModel.expMonth = "";
    ccModel.cardNumber = "";
    component.set("v.ccModel", ccModel);

    /*var getUserType = component.get("c.getUserType");
        getUserType.setCallback(this, function(a) {
            var ut = a.getReturnValue();
            if(ut.toUpperCase() == 'STANDARD')
                component.set('v.isPortalUser', false);
        });
        $A.enqueueAction(getUserType);*/
  },
  search: function(component, event, helper) {
    helper.toggle(component, event);
    helper.clearMsg(component);

    var toDT = component.find("toDT").get("v.value");
    component.set("v.bookingAvailable", false);
    component.set("v.discount", "");
    var action = component.get("c.searchUnitAvailability");
    action.setParams({ todate: toDT, bookingId: component.get("v.recordId") });
    action.setCallback(this, function(a) {
      var state = a.getState();
      // console.log(state +'  '+ a.getReturnValue().result);
      if (state === "SUCCESS") {
        if (a.getReturnValue().result == "not available") {
          helper.showMessage(
            component,
            event,
            "Unit is already booked for selected dates",
            "Booking not available"
          );
          helper.Btn(component, "enable");
        } else {
          var unitPrice = a.getReturnValue();
          component.set("v.bookingAvailable", true);
          component.set("v.unitPrice", unitPrice);
          component.set("v.updateCardDetails", unitPrice.requireCreditCard);
          //populating discounted price with subtotal initially, as on load it will be same as subtotal
          component.set("v.unitDiscountedPrice", unitPrice.SubTotal);
          if (
            unitPrice.ccModelList &&
            unitPrice.ccModelList.length > 0 &&
            (unitPrice.defaultCard || unitPrice.requireCreditCard)
          ) {
            if (unitPrice.defaultCard)
              component.set("v.selectedPymtMethod", unitPrice.defaultCard);
            else component.set("v.selectedPymtMethod", "newCard");
          }
        }
      } else if (state === "ERROR") {
        // console.log(a.getError());
        $A.log("Errors", a.getError());
      }
      helper.toggle(component, event);
    });
    $A.enqueueAction(action);
  },
  goBack: function(component, event, helper) {
    var context = component.get("v.context");
    if (context == "classic")
      window.open("/" + component.get("v.recordId"), "_parent");
    else $A.get("e.force:closeQuickAction").fire();
  },
  calDisAmt: function(component, event, helper) {
    var unitPrice = component.get("v.unitPrice");
    var dis = component.get("v.discount");
    //var proceedBookBtn = component.find("proceedBookBtn");
    if (!dis || isNaN(dis)) {
      var updatedTax = (
        (parseFloat(unitPrice.SubTotal) + parseFloat(unitPrice.CleaningFee)) *
        parseFloat(unitPrice.taxRate)
      ).toFixed(2);
      var updatedTotalPrice = (
        parseFloat(unitPrice.SubTotal) +
        parseFloat(unitPrice.CleaningFee) +
        parseFloat(updatedTax)
      ).toFixed(2);

      component.set("v.unitDiscountedPrice", unitPrice.SubTotal);
      component.set("v.unitPrice.tax", updatedTax);
      component.set("v.unitPrice.grandTotal", updatedTotalPrice);
      //proceedBookBtn.set("v.disabled", "true");
    } else {
      //proceedBookBtn.set("v.disabled", "false");
      var unitTotal = parseFloat(unitPrice.SubTotal);
      var disAmt = (unitTotal - unitTotal * (dis / 100)).toFixed(2);
      var totalTax = (
        (disAmt + parseFloat(unitPrice.CleaningFee)) *
        parseFloat(unitPrice.taxRate)
      ).toFixed(2);
      var finalPrice = (
        parseFloat(disAmt) +
        parseFloat(unitPrice.CleaningFee) +
        parseFloat(totalTax)
      ).toFixed(2);

      component.set("v.unitDiscountedPrice", disAmt);
      component.set("v.unitPrice.tax", totalTax);
      component.set("v.unitPrice.grandTotal", finalPrice);
    }
  },
  calDis: function(component, event, helper) {
    var unitPrice = component.get("v.unitPrice");
    /*var grandTotal = parseFloat(component.get("v.unitPrice.grandTotal"));
        var dis = (((unitPrice.SubTotalIncTax - grandTotal) / unitPrice.SubTotalIncTax ) * 100).toFixed(2);
        component.set("v.discount",dis);
        component.set("v.unitPrice.grandTotal",grandTotal);
        */
    if (!unitPrice.grandTotal || isNaN(unitPrice.grandTotal))
      unitPrice.grandTotal = 0;
    var discountAmount = (
      (parseFloat(unitPrice.SubTotal) +
        parseFloat(unitPrice.CleaningFee) -
        parseFloat(unitPrice.grandTotal) +
        (parseFloat(unitPrice.SubTotal) + parseFloat(unitPrice.CleaningFee)) *
          parseFloat(unitPrice.taxRate)) /
      (1 + parseFloat(unitPrice.taxRate))
    ).toFixed(2);
    console.log("@@@discountAmount==" + discountAmount);
    var discountedPrice = (
      parseFloat(unitPrice.SubTotal) - discountAmount
    ).toFixed(2);
    var discountPercentage = (
      (discountAmount * 100) /
      parseFloat(unitPrice.SubTotal)
    ).toFixed(2);
    var updatedTax = (
      (parseFloat(discountedPrice) + parseFloat(unitPrice.CleaningFee)) *
      unitPrice.taxRate
    ).toFixed(2);
    component.set("v.discount", discountPercentage);
    component.set("v.unitDiscountedPrice", discountedPrice);
    component.set("v.unitPrice.tax", updatedTax);
  },
  dateValidtion: function(component, event, helper) {
    component.set("v.bookingAvailable", false);
    helper.clearMsg(component);
    var inpCmp = component.find("toDT");
    var val = inpCmp.get("v.value");
    var endDT = component.get("v.toDate");

    //var bookInit = component.get("v.bookInit");
    //var totalDays = (Date.parse(bookInit.toDate)-Date.parse(endDT))/(1000 * 3600 * 24);

    // console.log('totalDays==='+totalDays);
    // console.log('endDT=='+endDT);
    // console.log('toDate=='+toDate);

    helper.Btn(component, "disable");
    if (endDT >= val) {
      // console.log('less');
      helper.showMessage(
        component,
        event,
        "Please select date greater than populated date",
        "Invalid Date"
      );
    } /*else if(totalDays > 30){
            helper.showMessage(component, event, 
                    'Extension for more than 30 days is not supported via this wizard. Kindly contact your administrator.',
                    'Extension not supported');
        } */ else {
      component.find("searchbtn").set("v.disabled", false);
      helper.Btn(component, "enable");
    }
  },
  bookUnit: function(component, event, helper) {
    helper.clearMsg(component);
    var isError = false;
    var updateCardDetails = component.get("v.updateCardDetails");
    var selectedPymtMethod = component.get("v.selectedPymtMethod");
    var unitPrice = component.get("v.unitPrice");
    var Dis = component.get("v.discount");
    // console.log(Dis);
    if (!Dis) {
      Dis = "0";
      // console.log(Dis);
    }
    if (!unitPrice.grandTotal || unitPrice.grandTotal <= 0) {
      updateCardDetails = false;
      selectedPymtMethod = "Not Required";
    }
    console.log("@@@updateCardDetails==" + updateCardDetails);
    if (updateCardDetails)
      isError = helper.validateCreditCardData(component, event);
    console.log("@@@updateCardDetails==" + updateCardDetails);
    if (!isError) {
      helper.toggle(component, event);

      var toDT = component.find("toDT").get("v.value");

      var action = component.get("c.bookExtension");

      var ccModel = component.get("v.ccModel");

      console.log("@@@selectedPymtMethod==" + selectedPymtMethod);
      console.log("@@@ccModel==" + ccModel);

      action.setParams({
        bookingId: component.get("v.recordId"),
        Discount: Dis,
        unitPrice: JSON.stringify(unitPrice),
        updateCardDetails: updateCardDetails,
        ccModelJson: JSON.stringify(ccModel),
        cardId: selectedPymtMethod
      });

      action.setCallback(this, function(a) {
        var state = a.getState();
        console.log(state + "  " + a.getReturnValue().result);
        if (state === "SUCCESS") {
          var context = component.get("v.context");
          console.log(a.getReturnValue());

          var result = a.getReturnValue();
          if (result.isError) {
            var errmsg = "";
            for (var i = 0; i < result.errMsgs.length; i++) {
              if (errmsg != "") errmsg += "\n";
              errmsg += result.errMsgs[i];
            }
            helper.showMessage(component, event, errmsg, "Error");
          } else {
            var recordId = result.recordId;
            if (context == "classic") window.open("/" + recordId, "_parent");
            else {
              var homeEvent = $A.get("e.force:navigateToSObject");
              homeEvent.setParams({
                recordId: recordId,
                slideDevName: "detail"
              });
              homeEvent.fire();
            }
          }
        } else if (state === "ERROR") {
          console.log(a.getError());
          //helper.toggle(component, event);
          $A.log("Errors", a.getError());
          var errors = a.getError();
          var errmsg = "";
          if (errors[0] && errors[0].message)
            // To show other type of exceptions
            errmsg += errors[0].message;
          if (errors[0] && errors[0].pageErrors)
            // To show DML exceptions
            errmsg += errors[0].pageErrors[0].message;
          helper.showMessage(component, event, errmsg, "Error");
        }
        helper.toggle(component, event);
      });
      $A.enqueueAction(action);
    }
  },

  selectPaymentMethod: function(cmp, event, helper) {
    var selectedVal = event.target.dataset.pymtMethodId; //event.getSource().get("v.text");
    console.log("selectedVal==" + selectedVal);
    cmp.set("v.selectedPymtMethod", selectedVal);
    var bookBtn = cmp.find("bookBtn");
    bookBtn.set("v.disabled", "false");

    cmp.set("v.updateCardDetails", false);
  },
  addPaymentMethod: function(cmp, event, helper) {
    var updateCardDetails = cmp.get("v.updateCardDetails");
    //console.log(document.getElementsByName('radioSavedCards')[0].checked=false);

    var allRadios = document.getElementsByName("radioSavedCards");

    for (var i = 0; i < allRadios.length; i++) {
      console.log((allRadios[i].checked = false));
    }
    var bookBtn = cmp.find("bookBtn");
    if (updateCardDetails == true) {
      bookBtn.set("v.disabled", "false");
      cmp.set("v.selectedPymtMethod", "newCard");
      console.log(event.getSource("radio"));
    } else {
      bookBtn.set("v.disabled", "true");
      cmp.set("v.selectedPymtMethod", "");
    }
  },
  proceedForPayment: function(cmp, event, helper) {
    //debugger;
    cmp.set("v.proceedForPayment", true);
    helper.clearMsg(cmp); // it's used to clear message

    var unitPrice = cmp.get("v.unitPrice");
    var selectedPymtMethod = cmp.get("v.selectedPymtMethod");
    var updateCardDetails = cmp.get("v.updateCardDetails");
    var bookBtn = cmp.find("bookBtn");
    var discount = cmp.get("v.discount");
    var dtfrmdt = cmp.get("v.toDate");

    let objuser = cmp.get("v.userInfo");
    var Email = objuser.Email;
    var ProfileName = objuser.Profile.Name;

    var GSet = function() {
      var setObj = {},
        val = {};
      this.count = 0;
      this.add = function(str) {
        setObj[str] = val;
        return ++this.count;
      };
      this.contains = function(str) {
        return setObj[str] === val;
      };
      this.remove = function(str) {
        delete setObj[str];
        return --this.count;
      };
      this.values = function() {
        var values = [];
        for (var i in setObj) {
          if (setObj[i] === val) {
            values.push(i);
          }
        }
        return values;
      };
    };

    var setofUser = new GSet();

    setofUser.add("support@barsala.com");
    setofUser.add("michael@barsala.com");
    setofUser.add("eugene@barsala.com");
    setofUser.add("brent@barsala.com");
    setofUser.add("kristen@barsala.com");
    setofUser.add("kelly@barsala.com");
    setofUser.add("maria@barsala.com");
    setofUser.add("ksenia@barsala.com");
    setofUser.add("brzowski@barsala.com");
    setofUser.add("mcopley@barsala.com");
    setofUser.add("aaron@barsala.com");
    setofUser.add("hussein@barsala.com");
    setofUser.add("manishupwrk@gmail.com");
    setofUser.add("megan@barsala.com");

    var setofProfile = new GSet();
    setofProfile.add("Engineering Team");
    setofProfile.add("City Manager");

    //let cuEmail ='';cmp.get("v.CurrentUserEmail");
    var toDT = cmp.find("toDT").get("v.value");

    //var fromDT = cmp.find("fromDT").get("v.value");
    var fromDT = dtfrmdt;

    let edt = Date.parse(toDT);
    let sdt = Date.parse(fromDT);

    let today = Date.parse(new Date());

    let blnIsError = false;
    let duration = (edt - sdt) / (1000 * 3600 * 24);

    if (
      discount != "" &&
      !isNaN(discount) &&
      !setofUser.contains(Email.toLowerCase()) &&
      !setofProfile.contains(ProfileName) &&
      edt > today
    ) {
      let discompareval = discount / 100;
      if (discompareval > 0.1 && duration < 14) {
        blnIsError = true;
      } else if (discompareval > 0.5 && duration >= 14) {
        blnIsError = true;
      }
    }

    if (blnIsError) {
      cmp.set("v.proceedForPayment", false);
      helper.showMessage(
        cmp,
        event,
        "For bookings under 14 days, the max discount is 5-10% (10% with approval). For bookings over 14 days, the max discount is 50%. Units cannot be blocked without mgmt approval.",
        "Error"
      );
    } else {
      if (bookBtn != undefined) {
        if (
          selectedPymtMethod ||
          updateCardDetails == true ||
          unitPrice.requireCreditCard == true ||
          (unitPrice.grandTotal != undefined && unitPrice.grandTotal <= 0)
        ) {
          console.log("inside if");
          bookBtn.set("v.disabled", "false");
        } else {
          console.log("inside else");
          bookBtn.set("v.disabled", "true");
        }
      }
    }
  },
  backToSearch: function(cmp, event, helper) {
    cmp.set("v.proceedForPayment", false);
  }

  /*  GSet : function (cmp, event, helper) {   
                var setObj = {}, val = {};
                this.count = 0;
                this.add = function (str) {
                    setObj[str] = val;
                    return ++this.count
                };
            
                this.contains = function (str) {
                    return setObj[str] === val;
                };
            
                this.remove = function (str) {
                    delete setObj[str];
                    return --this.count
                };
            
                this.values = function () {
                    var values = [];
                    for (var i in setObj) {
                        if (setObj[i] === val) {
                            values.push(i);
                        }
                    }
                    return values;
                };
            }*/
});