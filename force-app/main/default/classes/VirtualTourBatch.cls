//It is used to check the valid virtual tour URL of unit records.
global class VirtualTourBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
	
	public String query;
	
	global VirtualTourBatch() {
		this.query = 'select Id,Virtual_Tour_URL__c,Is_Virtual_Tour_URL_InCorrect__c from Unit__c ';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Unit__c> lst) {
		   List<Unit__c> lstUpdate = new List<Unit__c>();
		   Boolean isNotMatchURL = false;
		   for (Unit__c u : lst) {
			   isNotMatchURL = false;

			   if(!string.isblank(u.Virtual_Tour_URL__c)){
				  	HttpRequest req = new HttpRequest();
					req.setEndpoint(u.Virtual_Tour_URL__c);
					req.setMethod('GET');

					Http http = new Http();
					HTTPResponse res = http.send(req);
					if(res.getStatusCode() != 200){
						u.Is_Virtual_Tour_URL_InCorrect__c = true;
						isNotMatchURL = true;
					}else if (u.Is_Virtual_Tour_URL_InCorrect__c){
						u.Is_Virtual_Tour_URL_InCorrect__c = false;	
						isNotMatchURL = true;
					}
			   }

			   
			   if(isNotMatchURL){
				   lstUpdate.add(u);
			   }
		   }

		   if(lstUpdate.size()>0){
			   update lstUpdate;
		   }
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}