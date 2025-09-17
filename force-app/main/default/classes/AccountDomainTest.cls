@isTest
public class AccountDomainTest {

    @testSetup
    static void setupData() {
        // 1. Préparer les données de test
        List<Account> accounts = TestDataFactory.createAccounts(2, true);
    }

    @isTest
    static void testUpdateActiveWithOrders() {
        
        List<Account> accounts = [SELECT Id, isActive__c FROM Account];

        // 2. Créer un mock du service
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountService mockService = (IAccountService) mocks.mock(IAccountService.class);

        // 3. Définir le comportement du mock : retourner 1 commande pour ce compte
        Map<Id, Integer> fakeResult = new Map<Id, Integer>();
        for(Account acc : accounts) {
            fakeResult.put(acc.Id, 1);
        }
        mocks.startStubbing();
        mocks.when(mockService.countOrders(accounts)).thenReturn(fakeResult);
        mocks.stopStubbing();

        // 4. Enregistrer le mock dans l’application
        Application.Service.setMock(IAccountService.class, mockService);

        // 5. Exécuter la méthode
        AccountDomain domain = (AccountDomain) AccountDomain.newInstance(accounts);
        Test.startTest();
            domain.updateActive();
        Test.stopTest();

        // 6. Vérifier le résultat
        List<Account> updatedAccounts = domain.getAccounts();
        for (Account acc : updatedAccounts) {
            System.assertEquals(true, acc.isActive__c, 'Le compte doit être actif car le mock retourne une commande.');
        }
    }

    @isTest
    static void testUpdateActiveWithoutOrders() {

        List<Account> accounts = [SELECT Id, isActive__c FROM Account];

        // 2. Créer un mock du service
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountService mockService = (IAccountService) mocks.mock(IAccountService.class);

        // 3. Définir le comportement du mock : retourner aucune commande
        Map<Id, Integer> fakeResult = new Map<Id, Integer>();
        for(Account acc : accounts) {
            fakeResult.put(acc.Id, null);
        }
        mocks.startStubbing();
        mocks.when(mockService.countOrders(accounts)).thenReturn(fakeResult);
        mocks.stopStubbing();

        // 4. Enregistrer le mock
        Application.Service.setMock(IAccountService.class, mockService);

        // 5. Exécuter la méthode
        AccountDomain domain = (AccountDomain) AccountDomain.newInstance(accounts);
        Test.startTest();
            domain.updateActive();
        Test.stopTest();

        // 6. Vérifier le résultat
        List<Account> updatedAccounts = domain.getAccounts();
        for (Account acc : updatedAccounts) {
            System.assertEquals(false, acc.isActive__c, 'Le compte doit être inactif car le mock retourne zéro commande.');
        }
    }

    @IsTest
    static void testNewInstanceMethods() {

        List<Account> accounts = [SELECT Id FROM Account];

        // Test newInstance avec la liste
        IAccountDomain domainList = AccountDomain.newInstance(accounts);
        System.assertNotEquals(null, domainList, 'newInstance(List) doit retourner une instance');
        System.assertEquals(accounts.size(), domainList.getAccounts().size(), 'La taille des deux listes ne correspond pas');

        // Test newInstance avec Set<Id>
        Set<Id> accountIds = new Set<Id>();
        for(Account acc : accounts) {
            accountIds.add(acc.Id);
        } 
        IAccountDomain domainSet = AccountDomain.newInstance(accountIds);
        System.assertNotEquals(null, domainSet, 'newInstance(Set) doit retourner une instance');
        System.assertEquals(accountIds.size(), domainSet.getAccounts().size(), 'La taille des deux listes ne correspond pas');

    }

}
