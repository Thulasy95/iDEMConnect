public class AccountDomain extends fflib_SObjectDomain implements IAccountDomain {

    // Constructeur qui prend une liste d'objets Account
    public AccountDomain(List<Account> sObjectList) {
        super(sObjectList);
    }

    // Méthode statique pour instancier un objet IAccountDomain à partir d'une liste d'Accounts
    public static IAccountDomain newInstance(List<Account> recordList) {
		return (IAccountDomain) Application.Domain.newInstance(recordList);
	}

    // Méthode statique pour instancier un objet IAccountDomain à partir d'un set d'Ids d'Accounts
    public static IAccountDomain newInstance(Set<Id> recordIdSet) {
		return (IAccountDomain) Application.Domain.newInstance(recordIdSet);
	}

    // Retourne la liste des comptes
    public List<Account> getAccounts() {
		return (List<Account>) getRecords();
	}

    public void updateActive() {

        // Récupère la liste des comptes
        List<Account> accountsToUpdate = getAccounts();

        // Appelle le service pour compter le nombre de commandes par compte
        IAccountService accountService = (IAccountService) Application.Service.newInstance(IAccountService.class);
        Map<Id,Integer> numberOfOrdersByAccountId = accountService.countOrders(accountsToUpdate);
       
        // Parcourt chaque compte pour mettre à jour le champ Active
        for(Account account : accountsToUpdate) {
            account.isActive__c = ( numberOfOrdersByAccountId.get(account.Id) != null ) ? true : false ;
        }

	}

    // Classe interne pour la construction d'instances AccountDomain
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AccountDomain(sObjectList);
        }
    }
    
}