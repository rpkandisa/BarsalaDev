global class UnitLookupOnCleaningUpdateBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global UnitLookupOnCleaningUpdateBatch() {
		this.query = 'select id,Unit_ID__c,Booking__c,Booking__r.Product__c from Cleaning_Assignment__c where Unit_ID__c = null ';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Cleaning_Assignment__c> lst) {
		for (Cleaning_Assignment__c ca : lst) {
			ca.Unit_ID__c = ca.Booking__r.Product__c;
		}

		CleaningAssignmentHandler.isCleaningRecursion = true;
		update lst;

	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}