@isTest
public class TestProspectiveBuildingConversion {
	@isTest
	static void testDemo() {
		City__c c = new City__c();
        c.Name = 'Seattle';
        c.State__c = 'SD';
        c.Rebooking_Price_Threshold_Below__c=5;
        c.Rebooking_Price_Threshold_Above__c=10;
        c.Checkin_Time_Cutoff__c = DateTime.now().time();
        insert c;
		
		Neighborhood__c nb = new Neighborhood__c(Name='Test NB 1', City__c = c.Id);
        insert nb;

        List<Unit_set__c> unitSets = new List<Unit_set__c>();
        unitSets.add(new Unit_set__c(Name = 'Seattle - Studio'));
        unitSets.add(new Unit_set__c(Name = 'Seattle - 1BR Basic'));
        unitSets.add(new Unit_set__c(Name = 'Seattle - 2BR Basic'));
        unitSets.add(new Unit_set__c(Name = 'Seattle - 3BR'));
        insert unitSets;

		Prospective_Building__c prosBuilding = new Prospective_Building__c(
			Name = '001 test',
			Address__c = 'test',
			ZIP__c = 'test',
			City__c=c.Id,
			Neighborhood__c = nb.Id
		);
		insert prosBuilding;
		
		List<Prospective_Unit__c> prosUnits = new List<Prospective_Unit__c>();

		prosUnits.add(
			new Prospective_Unit__c(
				Name = '101',
				Bathrooms__c = '1',
				Bedrooms__c = 'Studio',
				Status__c = 'Approved',
				Prospective_Building__c = prosBuilding.Id
			)
		);

		prosUnits.add(
			new Prospective_Unit__c(
				Name = '102',
				Bathrooms__c = '2',
				Bedrooms__c = '2',
				Status__c = 'Approved',
				Prospective_Building__c = prosBuilding.Id
			)
		);

		prosUnits.add(
			new Prospective_Unit__c(
				Name = '103',
				Bathrooms__c = '2.5',
				Bedrooms__c = '3',
				Status__c = 'Approved',
				Prospective_Building__c = prosBuilding.Id
			)
		);
		insert prosUnits;

		ApexPages.currentPage().getParameters().put('id',prosBuilding.Id);
		ProspectiveBuildingConversionController obj = new ProspectiveBuildingConversionController();
		obj.building.Same_Day_Reservation_End_Time__c = '06:00 AM';
		obj.approvedUnitsModel[0].selected = true;
		obj.convertSelectedUnits();
		obj.cancel();

		system.assertEquals([select id,Status__c from Prospective_Unit__c where Id=:obj.approvedUnitsModel[0].prosUnit.Id].Status__c,'Converted');
		system.assertEquals([select id,Status__c from Prospective_Building__c where Id=:prosBuilding.Id].Status__c,'7. Converted');
		system.assert([select id,Converted_Building__c from Prospective_Building__c where Id=:prosBuilding.Id]!=null,'Building not converted');
	}
}