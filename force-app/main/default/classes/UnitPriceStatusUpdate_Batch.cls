global class UnitPriceStatusUpdate_Batch implements Database.Batchable<sObject> {
	
	public String query;
	
	global UnitPriceStatusUpdate_Batch() {
		query = 'SELECT Start_date__c,End_date__c,Status__c,Product__c,Id FROM Xotelia_Booking__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Xotelia_Booking__c> scope) {
		BookingTriggerHelper.UnitBookingUpdate(scope,null,true,false,false);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}