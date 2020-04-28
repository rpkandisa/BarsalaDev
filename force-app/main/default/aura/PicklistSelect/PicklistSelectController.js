({
  doInit: function(component, event, helper) {
    helper.callAction(
      component,
      "c.getFieldLabel",
      {
        objectName: component.get("v.objectName"),
        fieldName: component.get("v.fieldName")
      },
      function(data) {
        component.set("v.label", data);
      }
    );

    helper.callAction(
      component,
      helper,
      "c.getPicklistOptions",
      {
        objectName: component.get("v.objectName"),
        fieldName: component.get("v.fieldName")
      },
      function(data) {
        let fieldname = component.get("v.fieldName");
        let optionsData = [];
        optionsData.push({ label: "--None--", value: "" });

        data.forEach(o => {
          if (fieldname == "Basis__c" && o.value == "credit") {
            return;
          }
          optionsData.push(o);
        });
        component.set("v.options", optionsData);
      }
    );
  },
  onwrpEventUpdate: function(component, event, helper) {
    var controllerValueKey = component.get("v.value");
  }
});