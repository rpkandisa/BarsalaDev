global class UnitLookupOnQAUpdateBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global UnitLookupOnQAUpdateBatch() {
		this.query = 'select id,Unit_ID__c,Booking_Record__c,Booking_Record__r.Product__c from QA_Assignment__c where Unit_ID__c = null';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<QA_Assignment__c> lst) {
		for (QA_Assignment__c ca : lst) {
			ca.Unit_ID__c = ca.Booking_Record__r.Product__c;
		}

		QAAssignmentHandler.isQARecursion = true;
		update lst;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}