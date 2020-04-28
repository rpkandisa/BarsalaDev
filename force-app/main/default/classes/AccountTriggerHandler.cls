public class AccountTriggerHandler {
  @future(callout=true)
  public static void GenderizeAPICallout(Set<Id> setPersonAccountIds) {
    GenderizeAPICalloutWithoutFuture(setPersonAccountIds);
  }

  public static void GenderizeAPICalloutWithoutFuture(
    Set<Id> setPersonAccountIds
  ) {
    Map<String, List<Id>> mapNameToPersonAccIds = new Map<String, List<Id>>();
    Boolean IsSinglePersonAccToUpdate;
    try {
      List<Account> lstPersonAccounts = [
        SELECT Id, FirstName
        FROM Account
        WHERE Id IN :setPersonAccountIds
      ];
      IsSinglePersonAccToUpdate = lstPersonAccounts.size() == 1 ? true : false;

      String calloutParam = '';
      if (lstPersonAccounts != null && lstPersonAccounts.size() > 0) {
        for (Account pAcc : lstPersonAccounts) {
          if (!mapNameToPersonAccIds.containsKey(pAcc.FirstName)) {
            calloutParam =
              calloutParam +
              'name=' +
              EncodingUtil.urlEncode(pAcc.FirstName, 'UTF-8') +
              '&';

            mapNameToPersonAccIds.put(pAcc.FirstName, new List<Id>());
          }

          List<Id> pAccIds = mapNameToPersonAccIds.get(pAcc.FirstName);
          pAccIds.add(pAcc.Id);

          mapNameToPersonAccIds.put(pAcc.FirstName, pAccIds);
        }
        calloutParam = calloutParam.removeEnd('&');
        System.debug('calloutParam :: ' + calloutParam);
      }

      string apikey = '';
      if (!Test.isRunningTest()) {
        apikey = 'apikey=af84a17a62f3f1c95b199691c6b5fe76&';
      }

      HTTPRequest req = new HTTPRequest();
      req.setEndpoint('https://api.genderize.io/?' + apikey + calloutParam);
      req.SetMethod('GET');

      System.debug('req: ' + req);
      HTTP http = new HTTP();

      HTTPResponse res = http.send(req);
      system.debug(res);
      system.debug(res.getBody());

      if (res.getStatusCode() == 200) {
        if (IsSinglePersonAccToUpdate) {
          GenderizeWrapper GenderizeWrap = new GenderizeWrapper();
          GenderizeWrap = (GenderizeWrapper) JSON.deserialize(
            res.getBody(),
            GenderizeWrapper.class
          );
          System.debug('GenderizeAPICalloutForSingle :: ' + GenderizeWrap);
          updatePersonAccountGenderize(
            new List<GenderizeWrapper>{ GenderizeWrap },
            mapNameToPersonAccIds
          );
        } else {
          List<GenderizeWrapper> lstGenderizeWrappers = new List<GenderizeWrapper>();
          lstGenderizeWrappers = (List<GenderizeWrapper>) JSON.deserialize(
            res.getBody(),
            List<GenderizeWrapper>.class
          );
          System.debug('GenderizeAPICalloutForList :: ' + lstGenderizeWrappers);
          updatePersonAccountGenderize(
            lstGenderizeWrappers,
            mapNameToPersonAccIds
          );
        }
      } else {
        System.debug('Failed' + res.getBody());
      }
    } catch (Exception ex) {
      System.debug('Exception: ' + ex.getLineNumber() + ' ' + ex.getMessage());
    }
  }

  public static void updatePersonAccountGenderize(
    List<GenderizeWrapper> lstGenderWrap,
    Map<String, List<Id>> mapNameToPersonAccIds
  ) {
    List<Account> lstAccountsToUpdate = new List<Account>();
    System.debug('updatePersonAccountGenderize: ' + lstGenderWrap);
    System.debug('mapNameToPersonAccIds: ' + mapNameToPersonAccIds);

    if (lstGenderWrap != null && lstGenderWrap.size() > 0) {
      for (GenderizeWrapper gWrap : lstGenderWrap) {
        if (mapNameToPersonAccIds.containsKey(gWrap.name)) {
          for (Id accId : mapNameToPersonAccIds.get(gWrap.name)) {
            Decimal dec = 0;
            if (gWrap.probability != null) {
              dec = gWrap.probability;
            }

            lstAccountsToUpdate.add(
              new Account(
                Id = accId,
                Gender__c = gWrap.gender,
                Gender_Probability__c = (dec * 100)
              )
            );
          }
        }
      }

      if (lstAccountsToUpdate != null && lstAccountsToUpdate.size() > 0) {
        System.debug('lstAccountsToUpdate: ' + lstAccountsToUpdate);
        update lstAccountsToUpdate;
      }
    }
  }

  public class GenderizeWrapper {
    public string name;
    public string gender;
    public double probability;
    public integer count;
  }
}