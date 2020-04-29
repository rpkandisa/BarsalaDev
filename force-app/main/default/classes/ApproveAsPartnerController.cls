public with sharing class ApproveAsPartnerController {
    public Id AccountId{get; set;}
    public boolean bnlActivate {get;set;}
    
    public ApproveAsPartnerController(ApexPages.StandardController stdController) {
        AccountId = ApexPages.currentPage().getParameters().get('id');
        bnlActivate = false;
        
      
    }

   
    public  void updateAccountRecord(){
        bnlActivate = false;
        Id AccountId = ApexPages.currentPage().getParameters().get('id');
        
        
        Account acc = [SELECT id,Commission_Status__pc,Partner_Portal_Approved_By__pc FROM Account WHERE id = :AccountId]; 
        
        
        if(String.isBlank(acc.Commission_Status__pc) || acc.Commission_Status__pc == 'Requested'){
           
            updatePartnerPortalApprovedField(AccountId);

            // PromotionProcessForPartner.fnCreateAllMarketingPromotion(acc.Id);

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Partner request has been approved successfully!'));
            bnlActivate = true;
        }
        else if(String.isNotBlank(acc.Commission_Status__pc) && acc.Commission_Status__pc != 'Requested'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Your partner request is already approved!'));
        }
        
        
    }
    
    public static void updatePartnerPortalApprovedField(Id AccountId){
        String currentUserEmail = UserInfo.getUserEmail(); 
        Account acc = [SELECT id,Commission_Status__pc,Partner_Portal_Approved_By__pc FROM Account WHERE id = :AccountId]; 
        List<Account> accList = [SELECT id,PersonEmail FROM Account WHERE IsPersonAccount = True AND PersonEmail = :currentUserEmail limit 1];
        if(accList != null && accList.size() > 0 ){
             acc.Commission_Status__pc = 'bronze';
            acc.Partner_Portal_Approved_By__pc = accList[0].id;
        }
        update acc;
    }
}