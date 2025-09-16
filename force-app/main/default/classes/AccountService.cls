public with sharing class AccountService implements IAccountService {
    
    // Méthode statique pour obtenir une instance de IAccountService
    public static IAccountService newInstance(){

        return (IAccountService) Application.Service.newInstance(IAccountService.class);

    }

    public void updateActive(Set<Id> accountIds){
        
        //Création du Unit of Work (uow)
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        //Récupère le domain class des comptes
	    IAccountDomain accountDomain = (IAccountDomain) Application.Domain.newInstance( accountIds );

        //Execute la logique métier dans la domain class
		accountDomain.updateActive();

        //enregistre les comptes modifiés dans l’unité de travail
		uow.registerDirty(accountDomain.getRecords());

        //update sur les comptes
		uow.commitWork();

    }

    public Map<Id,Integer> countOrders(List<Account> accountsToUpdate){
        
        // Extraction des Ids des comptes depuis la liste
        Set<Id> accountIds = new Set<Id>();
        for (Account account : accountsToUpdate) {
            accountIds.add(account.Id);
        }

        // Requête d'agrégation SOQL qui compte le nombre de commandes par compte,
        List<AggregateResult> results = [SELECT AccountId, COUNT(Id) total FROM Order WHERE AccountId IN: accountIds GROUP BY AccountId];

        Map<Id,Integer> numberOfOrdersByAccountId = new Map<Id,Integer>();

        for (AggregateResult result : results) {
            numberOfOrdersByAccountId.put( (Id)result.get('AccountId') , (Integer)result.get('total') );
        }

        return numberOfOrdersByAccountId;

    }

}