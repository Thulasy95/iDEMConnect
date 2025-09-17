@isTest
private class AccountSelectorTest {
    @isTest
    static void testSelectById() {
        // Arrange : création d’un compte de test
        List<Account> account = TestDataFactory.createAccounts(1, true);
        Account acc = account[0];

        // Act
        Test.startTest();
        List<Account> results = AccountSelector.newInstance().selectById(new Set<Id>{acc.Id});
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size(), 'Un seul compte doit être trouvé');
        System.assertEquals(acc.Id, results[0].Id, 'Le compte retourné doit correspondre à celui créé');
    }
}