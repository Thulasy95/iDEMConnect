@isTest
private class AccountServiceTest {

    @IsTest
    static void testUpdateActive() {

        // 1. Préparer les données de test
        List<Account> accounts = TestDataFactory.createAccounts(3, true);
        Set<Id> accountIds = new Map<Id, SObject>(accounts).keySet();

        // 2. Créer des mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountDomain domainMock = (IAccountDomain) mocks.mock(AccountDomain.class);
        fflib_ISObjectUnitOfWork unitOfWorkMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IAccountSelector selectorMock = (IAccountSelector) mocks.mock(IAccountSelector.class);

        // 3. Définir le comportement des mocks
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.Account.SObjectType);
        mocks.when(selectorMock.selectSObjectsById(accountIds)).thenReturn(accounts);
        mocks.when(domainMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.when(domainMock.getRecords()).thenReturn(accounts);
        mocks.stopStubbing();

        // 4. Enregistrer les mocks dans l’application
        Application.UnitOfWork.setMock(unitOfWorkMock);
        Application.Domain.setMock((fflib_ISObjectDomain) domainMock);
        Application.Selector.setMock(selectorMock);

        // 5. Exécuter la méthode
        IAccountService service = AccountService.newInstance();
        Test.startTest();
            service.updateActive(accountIds);
        Test.stopTest();

        // 6. Vérifier les résultats
        //On vérifie l'appel du selector pour récupérer les comptes, 
        ((IAccountSelector) mocks.verify(selectorMock)).selectSObjectsById(accountIds);
        //et l'unit of work doit enregistrer et valider les changements
        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock)).registerDirty(accounts);
        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock)).commitWork();

        System.assertEquals(3, domainMock.getRecords().size(), 'Le domain doit retourner les 3 comptes');

    }

    @IsTest
    static void testCountOrders() {

        // 1. Préparer les données de test
        List<Account> accounts = TestDataFactory.createAccounts(3, true);
        List<Contract> contracts = TestDataFactory.createContracts(accounts, 1, true);
        List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
            2,          // nombre de commandes
            accounts,   // Liste de comptes
            'Draft',    // status de départ
            0           // nombre de produits commandé
        );

        // 2. Exécuter la méthode
        IAccountService service = AccountService.newInstance();
        Test.startTest();
        Map<Id, Integer> result = service.countOrders(accounts);            
        Test.stopTest();

        // 3. Vérifier les résultats
        System.assertNotEquals(null, result, 'Le résultat ne doit pas être null');
        System.assertEquals(3, result.size(), 'La taille de result doit être 3');
        for (Account acc : accounts) {
            System.assertEquals(2, result.get(acc.Id), 'Le compte doit avoir 2 commandes');
        }
    }

}