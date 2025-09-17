@isTest
private class OrderServiceTest {

    @IsTest
    static void testCountOrderItems() {

        // 1. Préparer les données de test
        List<Account> accounts = TestDataFactory.createAccounts(3, true);
        List<Contract> contracts = TestDataFactory.createContracts(accounts, 1, true);
        List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
            1,          // nombre de commandes
            accounts,   // Liste de comptes
            'Draft',    // status de départ
            2           // nombre de produits commandé
        );

        // 2. Exécuter la méthode
        IOrderService service = OrderService.newInstance();
        Test.startTest();
        Map<Id, Integer> result = service.countOrderItems(orders);            
        Test.stopTest();

        // 3. Vérifier les résultats
        System.assertNotEquals(null, result, 'Le résultat ne doit pas être null');
        System.assertEquals(3, result.size(), 'La taille de result doit être 3');
        for (Order ord : orders) {
            System.assertEquals(2, result.get(ord.Id), 'La commande doit avoir 2 produits commandés');
        }
    }

}