/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public class CommunitiesSelfRegController { 
    
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityPhone {get; set { communityPhone = value == null ? value : value.trim(); } }
    
    public CommunitiesSelfRegController() {}
    
    private boolean isValidPassword() {
        return password == confirmPassword; 
    }

    public PageReference signupcancel() {
        PageReference page = System.Page.CommunitiesLogin;
        page.setRedirect(true);
        return page;
    }
    @TestVisible
    private string findAccountDomain(string email) {        
        if(email.split('@').size()>1){
            for(string s : email.split('@').get(1).split('\\.')){
                email = s;
                break;
            }
        } 
        return email;
    }

    public PageReference registerUser() {        
        
        // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    

        String profileId = null; // To be filled in by customer.
        String roleEnum = null; // To be filled in by customer.
        String accountId = ''; // To be filled in by customer.
        
        profileId = [select id from profile where name='Customer Community' limit 1].get(0).Id;
        
        //Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sales - Monthlies').getRecordTypeId();
        //if(accRecordTypeId != null){
            accountId = [select id,ownerId from account where name=: label.BarsalaCommunityAccountName order by Id Asc limit 1].get(0).ownerId;//and recordtypeid=:accRecordTypeId
        //}
        
        List<Contact> lstContact = new List<Contact>([select id,email,AccountId from contact where email =: email limit 1]);
        
        String userName = email;

        User u = new User();
        u.Username = userName;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = generateRandomNumber();
        u.Phone = communityPhone;
        u.ProfileId = profileId;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        
        if(lstContact.size()>0){
            u.ContactId = lstContact.get(0).id;
            accountId = lstContact.get(0).accountId == null ? accountId : lstContact.get(0).accountId;
        }/*else{
            string strEmailDomain  = findAccountDomain(email);
            List<Account> lstacc = new List<Account>([select id from Account where Name =: strEmailDomain ]);
            if(lstacc.size()>0){
                accountId = lstacc.get(0).id;
            }*//*else{
                List<String> contactsEmail = new List<String> ();
                contactsEmail.add('%' + arremail[1] +'%');
                List<Contact> lstCon = new List<Contact>([select id,email,AccountId from contact where email like:contactsEmail limit 1]);
                if(lstCon.size()>0){                        
                    accountId = lstCon.get(0).accountId == null ? accountId : lstCon.get(0).accountId;
                }
            }*/
        //}
        
        system.debug('@user ' + u + ' acc ' + accountId + ' pwd ' + password);
        
        String userId;

        try {

            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail= true;
            
            //userId = Site.createExternalUser(u, accountId, password);
            
            //accountId = '005M0000007LQ6k';
            userId = Site.createExternalUser(u, accountId, '');
        } catch(Site.ExternalUserCreateException ex) {
            List<String> errors = ex.getDisplayMessages();
            for (String error : errors)  {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error + ' Please reach out to support@barsala.com for further assistance.'));
            }
            
            // This message is used for debugging. Do not display this in the UI to the end user.
            // It has the information around why the user creation failed.
            System.debug(ex.getMessage());
        }
        
        if (userId != null) { 
            if (password != null && password.length() > 1) {
                return Site.login(userName, password, ApexPages.currentPage().getParameters().get('startURL'));
            }
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }

    public static String generateRandomNumber() {
        String randomNumber = generate();
        if (randomNumber.length() < 6) {
            String randomNumber2 = generate();
            randomNumber = randomNumber + randomNumber2.substring(0, 10 - randomNumber.length());
        }
        return randomNumber;
    }
    private static String generate() {
        return String.valueOf(Math.abs(Crypto.getRandomInteger()));
    }
        
}