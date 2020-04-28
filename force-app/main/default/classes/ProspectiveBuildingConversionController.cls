public with sharing class ProspectiveBuildingConversionController {
    //public Boolean hasError{get;set;}
    public Boolean hasInvalidRequest{get;set;}
    public Boolean selectAllToggle{get;set;}
    public Building__c building{get;set;}
    public List<ApprovedUnitModel> approvedUnitsModel{get;set;}
    public List<Prospective_Unit__c> convertedUnits{get;set;}
    public List<Prospective_Unit__c> otherUnits{get;set;}
    public Prospective_Building__c prosBuilding{get;set;}
    public List<SelectOption> unitSetOptions{get;set;}
    public String externalName{Get;set;}

    private ID recordId;
    private Map<String,Unit_set__c> unitSetMap;
    private Map<String, Unit__c> simillarUnitsMap;
    private Boolean hasBuildingAlreadyConverted;

    //constructor, set default values
    public ProspectiveBuildingConversionController() {
        recordId = ApexPages.currentPage().getParameters().get('id');
        //hasError = false;
        hasInvalidRequest = false;
        hasBuildingAlreadyConverted = false;
        //set the checkbox-selectAll toggle defaults to checked
        selectAllToggle = true;
        unitSetOptions = new List<SelectOption>();

        approvedUnitsModel = new List<ApprovedUnitModel>();
        convertedUnits = new List<Prospective_Unit__c>();
        otherUnits = new List<Prospective_Unit__c>();
        simillarUnitsMap = new Map<String, Unit__c>();

        //initialize objects/lists
        init();
    }

    //initialize objects/lists
    public void init(){
        try{
            //fetching prospective building and Prospective Units
            List<Prospective_Building__c> prosBuildings = [select id, Name, Address__c,Asst_Community_Mgr_Contact__c,
                                City__c, City__r.Name, City__r.State__c, Comments__c, Community_Manager_Contact__c, 
                                Competitors__c, Leasing_Contact__c, Main_Number__c, Neighborhood__c, 
                                Occupancy__c, Status__c, Total_Units__c, Walkscore__c, ZIP__c,
                                Converted_Building__r.Name, Converted_Building__r.Address__c, Converted_Building__r.City__c,
                                Converted_Building__r.State__c, Converted_Building__r.Zip_code__c, Converted_Building__r.Neighborhood__c,
                                Converted_Building__r.External_Name__c, Converted_Building__r.Default_Min_Stay_Override__c,
                                Converted_Building__r.Same_Day_Reservation_End_Time__c, Converted_Building__r.Amenities__c,
                                Converted_Building__r.Leasing_Contact__c, Converted_Building__r.Community_Manager_Contact__c, 
                                Converted_Building__r.Asst_Community_Mgr_Contact__c, 
                                (select id, Name, Bathrooms__c, Bedrooms__c, City__c, Commission_Calculator__c, Commission_Primary__c,
                                    Commission_Secondary__c, Concession_Amount__c, Concession_Days__c, Contract_Type__c,
                                    Date_Available__c, Lease_Expiration__c, Lease_Term__c, Move_In_Amount__c, Move_In_Date__c, 
                                    Move_In_Fund_Type__c, Private_Comments__c, Prospective_Building__c, Quoted_Rent__c,
                                    Quoted_Security_Deposit__c, Size_sq_ft__c, Split_Commission__c, Status__c, Tour_Completed__c,
                                    Tour_Pictures_Attached__c, View_Rating__c, View_Type__c
                                    from Prospective_Units__r
                                )
                                from Prospective_Building__c where id=:recordId];

            if(prosBuildings.size() > 0){
                prosBuilding = prosBuildings[0];
                
                if(prosBuilding.City__c != null){
                    for(Unit__c unit:[select id, Base_Price__c, Min_Price__c, Bedrooms__c, Bathroom__c from Unit__c where 
                                Building__r.City__c =: prosBuilding.City__r.Name AND Base_Price__c != null AND 
                                Min_Price__c != null AND Bathroom__c != null AND Bedrooms__c != null Order By Base_Price__c])
                    {
                        simillarUnitsMap.put(unit.Bedrooms__c+unit.Bathroom__c, unit);
                    }
                }
            
                //fetching unit sets for the city of prospective unit
                unitSetMap = new Map<String, Unit_set__c>();
                Map<String, Unit_set__c> tempUnitSetMap = new Map<String, Unit_set__c>();
                List<SelectOption> tempUnitSetOptions = new List<SelectOption>();
                List<Unit_set__c> unitSets = [select Id,Name from Unit_set__c];
                

                for(Unit_set__c unitSet:unitSets){
                    if(prosBuilding.City__c != null && unitSet.Name.startsWith(prosBuilding.City__r.Name)){
                        unitSetOptions.add(new SelectOption(unitSet.Id, unitSet.Name)); 
                        unitSetMap.put(unitSet.Name, unitSet);
                    }
                    tempUnitSetMap.put(unitSet.Name, unitSet);
                    tempUnitSetOptions.add(new SelectOption(unitSet.Id, unitSet.Name));                 
                }
                if(unitSetOptions.size() == 0 && tempUnitSetMap.size()>0){
                    unitSetMap = tempUnitSetMap;
                    unitSetOptions = tempUnitSetOptions;
                }
                
                //initilizing building record, 
                    //if Prospective Building is already converted that using that, 
                    //otherwise setting some default values
                setBuildingRecord();

                //Creating Model for Approved units, which will available for conversion
                //creating separate list for Converted units
                //creating list for remaining units as well which are under review, undesirable e.t.c
                setUnitsData();
                
            }else{ //if prospective building is not found, then adding error message
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Prospective Building'));
                hasInvalidRequest = true;
            }
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,(e.getTypeName()+', '+e.getMessage()+', at line '+e.getLineNumber())));
            hasInvalidRequest = true;
        }
    }

    //Creating Model for Approved units, which will available for conversion
        //creating separate list for Converted units
        //creating list for remaining units as well which are under review, undesirable e.t.c
    private void setUnitsData(){
        if(prosBuilding.Prospective_Units__r.size()>0){
            approvedUnitsModel = new List<ApprovedUnitModel>();
            convertedUnits = new List<Prospective_Unit__c>();
            otherUnits = new List<Prospective_Unit__c>();
            
            Integer i = 1;
            for(Prospective_Unit__c prosUnit:prosBuilding.Prospective_Units__r){
                if(prosUnit.Status__c == 'Approved')
                {
                    approvedUnitsModel.add(
                        new ApprovedUnitModel(
                            prosUnit, 
                            setApprovedUnitData(prosUnit, i++), 
                            true
                        )
                    );
                }
                else if(prosUnit.Status__c == 'Converted')
                    convertedUnits.add(prosUnit);
                else
                    otherUnits.add(prosUnit);
            }
        }
    }

    //setting default data for Approved Prospective Units which are ready for conversion
    private Unit__c setApprovedUnitData(Prospective_Unit__c prosUnit, Integer inventoryNo){
        //observing unit set name based on PrspectiveUnit City and number of bedrooms in the unit
        //As of not sure how to differenciate Basic & Luxury Apartments, so default setting to luxury
        //This section logic is created based on data-format in Unit Sets record, 
            //if the format is changed, this will have to be changed 
                //else the default values will be the first one in the dropdown
        String unitSetName = prosBuilding.City__r.Name+' - '+
                            (
                                prosUnit.Bedrooms__c!= null 
                                ? (
                                    prosUnit.Bedrooms__c.isNumeric() 
                                    ? (prosUnit.Bedrooms__c+'BR')+
                                        (prosUnit.Bedrooms__c=='1' || prosUnit.Bedrooms__c=='2' ? ' Basic' : '') 
                                    : 'Studio'
                                )
                                : 'Studio'
                            );

        //this block generates the apartment name based on City and number of bedrooms
        //the format is observed as per the demo video, if the format has to be changed this block needs to be updated
        
        /*String apartmentName = ' Downtown '+prosBuilding.City__r.Name+' Apartments'+
                        (
                            prosUnit.Bedrooms__c!= null 
                            ? ' '+(
                                prosUnit.Bedrooms__c.isNumeric() 
                                ? (prosUnit.Bedrooms__c+'BD 1') 
                                : prosUnit.Bedrooms__c
                            )
                            : '');
        */

        String apartmentName =  getUnitApartmentName(building.External_Name__c, prosUnit, inventoryNo);

        //As per the demo video, set the default start date for unit to 2 days after date available
        Date startDate = (
                    prosUnit.Date_Available__c != null 
                    ? prosUnit.Date_Available__c.addDays(2)
                    : null
                );
        //As per the demo video, set the default end date for unit to adding lease terms(in months) to DateAvailable
        Date endDate = (
                    prosUnit.Date_Available__c != null && prosUnit.Lease_Term__c != null 
                    ? prosUnit.Date_Available__c.addMonths(Integer.ValueOf(prosUnit.Lease_Term__c))
                    : null
                );

        //this block initlize a temporary unit record with some default values and some values copied from prospective unit
        return new Unit__c(
            Name = building.Name +' '+ prosUnit.Name +' '+ apartmentName,
            Airbnb_listing_name__c=apartmentName,
            Unit__c = building.Name +' '+prosUnit.Name,
            Bathroom__c = prosUnit.Bathrooms__c,
            Bedrooms__c = prosUnit.Bedrooms__c,
            Beds__c = (prosUnit.Bedrooms__c != null && prosUnit.Bedrooms__c.isNumeric() ? prosUnit.Bedrooms__c : '1'),
            Unit_Size_sq_ft__c= prosUnit.Size_sq_ft__c,
            Lease_Start_Date__c=prosUnit.Date_Available__c,
            Lease_End_Date__c= endDate,
            Start_Date__c = startDate,
            End_Date__c= endDate,
            Lease_Security_Deposit__c=prosUnit.Quoted_Security_Deposit__c,              
            Unit_Rent_Cost__c=prosUnit.Quoted_Rent__c,
            Private_Comments__c = prosUnit.Private_Comments__c,
            Unit_set__c= (unitSetMap.containsKey(unitSetName) ? unitSetMap.get(unitSetName).Id : null),
            Base_Price__c = simillarUnitsMap.containsKey(prosUnit.Bedrooms__c+prosUnit.Bathrooms__c) ? 
                            simillarUnitsMap.get(prosUnit.Bedrooms__c+prosUnit.Bathrooms__c).Base_Price__c*3 : null,
            Min_Price__c = simillarUnitsMap.containsKey(prosUnit.Bedrooms__c+prosUnit.Bathrooms__c) ? 
                            simillarUnitsMap.get(prosUnit.Bedrooms__c+prosUnit.Bathrooms__c).Min_Price__c*3 : null
        );
    }

    public void updateUnitExternalName(){
        Integer i = 1;
        for(ApprovedUnitModel model:approvedUnitsModel){
            String apartmentName =  getUnitApartmentName(externalName, model.prosUnit, i++);
            model.unit.Name = building.Name +' '+ model.prosUnit.Name +' '+ apartmentName;
            model.unit.Airbnb_listing_name__c = apartmentName;
        }
    }

    //initilizing building record, 
        //if Prospective Building is already converted that using that, 
        //otherwise setting some default values
    private void setBuildingRecord(){
        //String buildingName;
        if(prosBuilding.Converted_Building__c != null){
            hasBuildingAlreadyConverted = true;
            building = prosBuilding.Converted_Building__r;
            //buildingName = building.Name;
        }else{
            hasBuildingAlreadyConverted = false;
            String buildingName = formatBuildingName(prosBuilding.name);
            building = new Building__c(
                Name = buildingName,
                Address__c = prosBuilding.Address__c,
                City__c = prosBuilding.City__r.Name,
                State__c = prosBuilding.City__r.State__c,
                Zip_code__c = prosBuilding.ZIP__c,
                Neighborhood__c = prosBuilding.Neighborhood__c,
                Leasing_Contact__c = prosBuilding.Leasing_Contact__c,
                Community_Manager_Contact__c = prosBuilding.Community_Manager_Contact__c,
                Asst_Community_Mgr_Contact__c = prosBuilding.Asst_Community_Mgr_Contact__c,
                External_Name__c = buildingName
            );
        }
    }

    //this block creates/formats building name
        //as per requirement this block removes the numberics from start of building name and put at the end
    private static String formatBuildingName(String buildingName){
        if(String.isNotBlank(buildingName) && buildingName.substring(0,1).isNumeric()){
            Integer i=0;
            String startNumbers = '';
            while(true){
                if(buildingName.substring(i,i+1).isNumeric()){
                    startNumbers += buildingName.substring(i,i+1);
                }else
                    break;
                i++;
            }
            if(String.isNotBlank(startNumbers)){
                buildingName = buildingName.removeStart(startNumbers).trim()+ ' '+startNumbers;
            }
        }
        return buildingName;
    }

    //this method used to generated apartment name (which appended in unit name), basically shows the units extenral name and type
    private String getUnitApartmentName(String externalBuildingName, Prospective_Unit__c prosUnitObj, Integer inventoryNo){
        String apartmentName =  (String.isNotBlank(externalBuildingName) ? externalBuildingName+' ' : '')+
                                (
                                    prosUnitObj.Bedrooms__c!= null && prosUnitObj.Bedrooms__c.isNumeric() 
                                    ? prosUnitObj.Bedrooms__c+'BD/'+
                                        (prosUnitObj.Bathrooms__c != null ? prosUnitObj.Bathrooms__c : '')+'BA'
                                    : 'Studio'
                                )+ ' '+inventoryNo;

        return apartmentName;
    }

    //this method converts the ProspectiveBuilding record to Building and updates the status to "7. Converted" (if building is not already converted)
    //Also updates/populate ConvertedBuilding lookup on Prospective Building
    //Then it creates selected Approved unit records, and update the Prospective Unit status to "Converted"
    //If any exception occours in process, then it rollbacks the transaction in catch block and show exception message to user
    public PageReference convertSelectedUnits(){
        Savepoint sp = Database.setSavepoint();
        try{
            if(prosBuilding.Converted_Building__c == null){
                insert building;
                prosBuilding.Converted_Building__c = building.Id;
                prosBuilding.Status__c = '7. Converted';
                update prosBuilding;
            }
            List<Unit__c> units = new List<Unit__c>();
            List<Prospective_Unit__c> prosUnitsToConvert = new List<Prospective_Unit__c>();
            
            for(ApprovedUnitModel unitModel:approvedUnitsModel){
                if(unitModel.selected){
                    unitModel.unit.Building__c = building.Id;
                    units.add(unitModel.unit);

                    unitModel.prosUnit.Status__c = 'Converted';
                    prosUnitsToConvert.add(unitModel.prosUnit);
                }
            }
            
            if(units.size() >0){
                insert units;
                update prosUnitsToConvert;
            }else if(hasBuildingAlreadyConverted){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select unit(s) for conversion'));
                return null;
            }

            return new PageReference('/'+recordId);
        }catch(Exception e){
            Database.rollback(sp);
            if(!hasBuildingAlreadyConverted){
                building.Id = null;
                prosBuilding.Converted_Building__c = null;
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getTypeName()+', '+e.getMessage()+', at line '+e.getLineNumber()));
        }
        return null;
    }

    //this method redirects user back to Prospective Unit record
    public PageReference cancel(){
        return new PageReference('/'+recordId);
    }

    //Model for Approved Units block
    public class ApprovedUnitModel{
        public Prospective_Unit__c prosUnit{get;set;}
        public Unit__c unit{get;set;}
        public Boolean selected{get;set;}

        public ApprovedUnitModel(Prospective_Unit__c prosUnit, Unit__c unit, Boolean selected){
            this.prosUnit = prosUnit;
            this.unit = unit;
            this.selected = selected;
        }       
    }
}