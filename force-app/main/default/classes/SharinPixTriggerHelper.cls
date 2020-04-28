public class SharinPixTriggerHelper
{
    //a. Method for Insert,Update,Delete and Undelete
    //b. Check for Events 
    //c. If it is for new records then Will add the new value of sharinPix
    //d. If It is for old records then will check whether It is an existing or new 
    //e. Check the size of CleaningIds
    //f. If size is greater than 0 then It will count the records of SharinPix 

    //This method is used to calculate count of total images for Cleaning Assignments and update on Cleaning Assignment record
    public static void updateTotalImages(List <sharinpix__SharinPixImage__c> newImages, Map<ID,sharinpix__SharinPixImage__c> oldMap, boolean isInsert, boolean isUpdate, boolean isDelete, boolean isUndelete) 
    {
        Set<Id> setUnitIds = new Set<Id>();
        Set<Id> setBuildings = new Set<Id>();
        Set < Id > setCleaningAssIds = new Set < Id > ();
        
        if (isUpdate || isInsert || isUndelete){
            for(sharinpix__SharinPixImage__c sp: newImages){
                if(isUndelete){
                    //Adding error when user tries to undelete an SharinPix Image record realated to Cleaning Assignment
                    //As the actual image is deleted from SharinPix server and is not on control to recover that
                    if(sp.Cleaning_Assignment__c != null)
                        sp.addError('Restoring SharingPix Image Records for Cleaning Assignments is not allwoed. Please Contact your Administrator');
                }else{
                    setCleaningAssIds.add(sp.Cleaning_Assignment__c);
                    if(isUpdate && sp.Cleaning_Assignment__c != oldMap.get(sp.Id).Cleaning_Assignment__c)
                        setCleaningAssIds.add(oldMap.get(sp.Id).Cleaning_Assignment__c);

                    if(sp.Unit__c != null){
                        if(isInsert)  {
                            setUnitIds.add(sp.Unit__c);
                        }
                        
                        if(isUpdate && fnCheckfieldChanges(sp,oldMap.get(sp.Id))){
                            setUnitIds.add(oldMap.get(sp.Id).Unit__c);
                        }
                    }

                    if(sp.Building__c != null){
                        if(isInsert){
                            setBuildings.add(sp.Building__c);
                        }
                        if(isUpdate && fnCheckfieldChanges(sp,oldMap.get(sp.Id))){
                            setBuildings.add(oldMap.get(sp.Id).Building__c);
                        }
                    }
                }

                
            }
        }else if(isDelete){
            for(sharinpix__SharinPixImage__c sp: oldMap.values()){
                setCleaningAssIds.add(sp.Cleaning_Assignment__c);
                setUnitIds.add(sp.Unit__c);
                setBuildings.add(sp.Building__c);
            }
                
        } 
        
        setCleaningAssIds.remove(null);
        
        if (setCleaningAssIds.size() > 0) 
        {
            List <Cleaning_Assignment__c> listpix = new List <Cleaning_Assignment__c>();

            List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            Boolean isHousekeepingUser = PROFILE[0].Name == 'Partner Community - Housekeeping' ? true : false;
            Housekeeping_Setting__c hkSetting = Housekeeping_Setting__c.getOrgDefaults();
            
            //updating total images count for Cleaning Assignments on which images are added/deleted
            AggregateResult[] groupedResults = [SELECT COUNT(Id) totalImages, Cleaning_Assignment__c FROM sharinpix__SharinPixImage__c WHERE Cleaning_Assignment__c IN: setCleaningAssIds group by Cleaning_Assignment__c];
            for (AggregateResult ar: groupedResults){
                Id caId = (ID) ar.get('Cleaning_Assignment__c');
                Integer count = (INTEGER) ar.get('totalImages');

                Cleaning_Assignment__c ca = new Cleaning_Assignment__c(
                    Id = caId, 
                    Total_Images__c=count 
                );

                //Setting the Deep Cleaning to false if it does not meet minimum image criteiria for HouseKeeping Users
                if(isHousekeepingUser 
                    && hkSetting.Deep_Cleaning_Validation__c 
                    && hkSetting.Deep_Cleaning_Minimum_Images__c != null
                    && count < hkSetting.Deep_Cleaning_Minimum_Images__c
                )
                    ca.Deep_Cleaning__c = false;
                listpix.add(ca);
                
                setCleaningAssIds.remove(caId);
            }

            //Setting Total Image count to 0 for Cleaning Assignments which doesn't have any images
            if (setCleaningAssIds.size() > 0) {
                for (Id caID: setCleaningAssIds) {
                    Cleaning_Assignment__c ca = new Cleaning_Assignment__c(
                        Id = caId, 
                        Total_Images__c=0 
                    );

                    //Setting the Deep Cleaning to false if it does not meet minimum image criteiria for HouseKeeping Users
                    if(isHousekeepingUser 
                        && hkSetting.Deep_Cleaning_Validation__c
                        && hkSetting.Deep_Cleaning_Minimum_Images__c != null
                    )
                        ca.Deep_Cleaning__c = false;

                    listpix.add(ca);
                }
            }
            update listpix;
        }

        //Here we are trying to upate Shrinpix Unit field as null if image gets insert/delete
        Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
        if((setUnitIds.size()>0 || setBuildings.size()>0) && objBarsalaSetting.Enable_to_Clear_Unit_SyncImg_Fields__c == true){
            Map<Id,Unit__c> mapUnits = new Map<Id,Unit__c>();
            for (Unit__c u : [SELECT Id,(SELECT Id FROM Real_Unit__r)  FROM Unit__c Where Id in:setUnitIds Or Building__c in: setBuildings ]) {
                Unit__c obj = new Unit__c(Id = u.Id);
                obj.Airbnb_Image_Sync_Time__c = null;
                obj.MyVR_Image_Sync_Time__c = null;
                obj.RU_Image_Sync_Time__c = null;
                obj.MyVR_30_Day_Image_Sync_Time__c = null;
                mapUnits.put(u.Id, obj);

                for (Unit__c o : u.Real_Unit__r) {
                    Unit__c obj1 = new Unit__c(Id = o.Id);
                    obj1.Airbnb_Image_Sync_Time__c = null;
                    obj1.MyVR_Image_Sync_Time__c = null;
                    obj1.RU_Image_Sync_Time__c = null;
                    obj1.MyVR_30_Day_Image_Sync_Time__c = null;
                    mapUnits.put(o.Id, obj1);
                }
            }

            if(mapUnits.size()>0){
                update mapUnits.values();
            }
        }      
    }


    public static Boolean fnCheckfieldChanges(sharinpix__SharinPixImage__c spnew, sharinpix__SharinPixImage__c spold){
        Set<String> setfields = new Set<String>();
        setfields.add('sharinpix__AlbumID__c');
        setfields.add('sharinpix__ImagePublicId__c');
        setfields.add('sharinpix__Title__c');
        setfields.add('sharinpix__Description__c');
        setfields.add('Checkin_Instruction_Step_Number__c');
        setfields.add('Checkin_Supply_Unit_Number__c');
        setfields.add('Checkin_Supply_Floor_Number__c');
        setfields.add('Checkin_Supply_Parking_Spot__c');
        setfields.add('Checkin_Instruction_Description__c');
        setfields.add('Checkin_Supply_Keycafe_Code__c');
        setfields.add('Checkin_Supply_VirtualKey_Code__c');
        setfields.add('Checkin_Supply_City_Manager_Phone__c');
        setfields.add('Unit__c');
        setfields.add('sharinpix__FileName__c');
        setfields.add('sharinpix__Format__c');
        setfields.add('sharinpix__Tags__c');
        setfields.add('sharinpix__ImageURLOriginal__c');
        setfields.add('sharinpix__ImageURLFull__c');
        setfields.add('sharinpix__ImageURLThumbnail__c');
        setfields.add('sharinpix__ImageURLMini__c');
        setfields.add('Fill_to_Size__c');
        setfields.add('Fit_to_Size__c');
        setfields.add('Barsala_Standard_Image__c');
        setfields.add('sharinpix__Exifs__c');
        
        Boolean blnReturnval = false;
        for (String f : setfields) {
            if(spnew.get(f) != spold.get(f)){
                blnReturnval = true;
                break;
            }
        }

        return blnReturnval;
    }
}