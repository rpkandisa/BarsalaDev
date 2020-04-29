/*
    Created By: Kandisa Technologies Pvt. Ltd
    Description: Booking trigger
*/
trigger BookingTrigger on Xotelia_Booking__c(
  after insert,
  after update,
  after delete,
  before insert,
  before update
) {
  //if Unit price availablity setting is enable then trigger updates.
  Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
  if (objBarsalaSetting.Enable_Unit_Price_Availabilty_Update__c) {
    if (Trigger.isAfter && !BookingTriggerHelper.IsRecursive) {
      if (Trigger.isInsert) {
        BookingTriggerHelper.UnitBookingUpdate(
          Trigger.new,
          null,
          Trigger.isInsert,
          Trigger.isUpdate,
          Trigger.isDelete
        );
      } else if (Trigger.isUpdate) {
        BookingTriggerHelper.UnitBookingUpdate(
          Trigger.new,
          Trigger.oldMap,
          Trigger.isInsert,
          Trigger.isUpdate,
          Trigger.isDelete
        );
        if (!objBarsalaSetting.TurnOff_QA_Cleaning_Create_On_UnitChange__c) {
          BookingTriggerHelper.fnChangeBookingProduct(
            Trigger.new,
            Trigger.oldMap
          );
        }
      } else if (Trigger.isDelete) {
        BookingTriggerHelper.UnitBookingUpdate(
          null,
          Trigger.oldMap,
          Trigger.isInsert,
          Trigger.isUpdate,
          Trigger.isDelete
        );
      }
    }
  }

  if (Trigger.isBefore) {
    if (Trigger.isInsert || Trigger.isupdate) {
      if (objBarsalaSetting.Populate_Two_Factor_Screening_Approval__c) {
        BookingTriggerHelper.updatePersonAccount(Trigger.new, Trigger.oldMap);
      }
    }
  }

  if (
    objBarsalaSetting.Enable_Product_Change_Validation__c ||
    Test.isRunningTest()
  ) {
    if (Trigger.isBefore) {
      if (Trigger.isInsert || Trigger.isupdate) {
        BookingTriggerHelper.CheckingTimeForProductChange(
          Trigger.new,
          Trigger.oldMap
        );
      }
    }
  }

  if (
    objBarsalaSetting.Enable_to_Generate_Confirmation_Code__c ||
    test.isRunningTest()
  ) {
    if (
      Trigger.isBefore &&
      Trigger.isInsert &&
      !BookingConfirmationCode.isRecursionHandler
    ) {
      BookingConfirmationCode.updateBookingConfirmationCode(Trigger.new, true);
    }
  }

}