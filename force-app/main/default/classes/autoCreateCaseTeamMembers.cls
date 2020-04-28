//Added By Kandisatech on 07/12/2018 
//It is used to create case team member
public  class autoCreateCaseTeamMembers {
    
    @InvocableMethod(label='Create CaseTeamMember Records')
    public static void CreateCaseTeamMemberRecords(List<CreateCaseTeamMemberInner> lstwrp){
        Set<string> teamRoleName = new Set<string>();
        Set<Id> caseIds = new Set<Id>();
        Set<string> usernames = new Set<string>();
        for(CreateCaseTeamMemberInner c : lstwrp){
            caseIds.add(c.caseId);
            teamRoleName.add(c.teamRoleName.trim());
            for(string s : c.userNames.split(',')){
                usernames.add(s.trim());
            }            
        }
        system.debug('usernames@@@@@ ' + usernames);
        Map<Id,Set<Id>> mapteamMemberExistForCase = new Map<Id,Set<Id>>();
        for(Case c : [select id,casenumber,contactId,OwnerId,(SELECT Id, ParentId, MemberId FROM TeamMembers) from Case where Id in: caseIds]){
            for(CaseTeamMember ctm : c.TeamMembers){
                if(mapteamMemberExistForCase.containsKey(c.Id)){
                    mapteamMemberExistForCase.get(c.Id).add(ctm.MemberId);
                }else{
                    mapteamMemberExistForCase.put(c.Id, new Set<Id> { ctm.MemberId });
                }
            }
        }
        
        Map<string,Id> mapTeamRole = new Map<string,Id>();
        for(CaseTeamRole u : [SELECT Name, Id FROM CaseTeamRole where name in:teamRoleName ]){
            mapTeamRole.put(u.name.tolowercase(),u.id);
        }
        system.debug('usernames@@@@@ ' + usernames);
        Map<string,Id> mapUser = new Map<string,Id>();
        for(User u : [select id,username from user where username in: usernames and isactive = true ]){
            mapUser.put(u.username.tolowercase(),u.id);
        }        

        List<CaseTeamMember> lstCaseTeamMember = new List<CaseTeamMember>();
        for(CreateCaseTeamMemberInner c : lstwrp){
            for(string s : c.userNames.split(',')){
                system.debug('username@@@@ ' + s);
                CaseTeamMember ctm = new CaseTeamMember();
                ctm.ParentId = c.caseId;
                if(mapUser.containsKey(s.trim().toLowerCase())){
                    ctm.MemberId = mapUser.get(s.trim().toLowerCase());

                    //check TeamMember already Exist
                    if(mapteamMemberExistForCase.containsKey(c.caseId)){
                        if(mapteamMemberExistForCase.get(c.caseId).contains(ctm.MemberId)){
                            continue;
                        }
                    }
                    
                    //assign teamrole
                    if(mapTeamRole.containsKey(c.teamRoleName.trim().toLowerCase())){
                        ctm.TeamRoleId = mapTeamRole.get(c.teamRoleName.trim().toLowerCase());
                    }

                    lstCaseTeamMember.add(ctm);
                }
            }            
        }
        system.debug('lstCaseTeamMember@@@@ ' + lstCaseTeamMember);
        if(lstCaseTeamMember.size()>0){
            insert lstCaseTeamMember;
        }
    }

    public class CreateCaseTeamMemberInner {
        @InvocableVariable(required=true)
        public ID caseId;

        @InvocableVariable(required=true)
        public String userNames;

        @InvocableVariable(required=true)
        public String teamRoleName;
    }

}