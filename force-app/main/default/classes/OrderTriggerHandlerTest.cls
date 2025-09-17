@isTest
private class OrderTriggerHandlerTest {

    @TestSetup
    static void setupData() {

        // 1. Préparer les données de test
        List<Account> accounts = TestDataFactory.createAccounts(3, true);
        List<Contract> contracts = TestDataFactory.createContracts(accounts, 1, true);
        List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
            1,          // nombre de commandes
            accounts,   // Liste de comptes
            'Draft',    // status de départ
            2           // nombre de produits commandé
        );

    }


    @IsTest
    static void testOnApplyDefaults() {

        // 1. Préparer les données de test
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Order ord = new Order(AccountId = acc.Id, EffectiveDate = Date.today(), Status = null, Pricebook2Id = Test.getStandardPricebookId());
        List<Order> orders = new List<Order>{ord};

        // 2. Exécuter la méthode
        OrderTriggerHandler handler = new OrderTriggerHandler(orders);
        Test.startTest();
            handler.onApplyDefaults();
        Test.stopTest();
        
        // 3. Vérifier les résultats
        List<Order> updatedOrders = [SELECT Id, Status FROM Order];
        for (Order order : updatedOrders) {
            System.assertEquals('Draft', order.Status, 'Le statut par défaut doit être Draft');
        }
    }


    @IsTest
    static void testOnValidateWithoutAccount() {

        // 1. Préparer les données de test
        Order ord = new Order(Status = 'Draft', EffectiveDate = Date.today(), Pricebook2Id = Test.getStandardPricebookId());
        List<Order> orders = new List<Order>{ord};

        // 2. Exécuter la méthode
        OrderTriggerHandler handler = new OrderTriggerHandler(orders);
        Test.startTest();
            try {
                handler.onValidate();
            } catch (DmlException e) {
                // 3. Vérifier les résultats
                System.assert(e.getMessage().contains('Un compte est requis pour une commande.'), 'Le message d’erreur attendu n’a pas été trouvé.');
            }
        Test.stopTest();

    }


    @IsTest
    static void testOnValidateStatusActivated() {

        // 1. Préparer les données de test
        List<Account> accounts = [SELECT Id FROM Account];
        List<Contract> contracts = [SELECT Id, Status FROM Contract];
        for (Contract c : contracts) {
            c.Status = 'Activated';
        }
        update contracts;

        // Crée une commande Activated
        List<Order> existingOrders = TestDataFactory.createOrdersWithOrderItems(
            1,              // nombre de commandes
            accounts,       // Liste de comptes
            'Activated',    // status de départ
            2               // nombre de produits commandé
        );

        Order existingOrder = existingOrders[0];

        // Tentative de modification du statut
        existingOrder.Status = 'Draft';

        // 2. Exécuter la méthode
        Test.startTest();
            try {
                update existingOrder;
            } catch (DmlException e) {
                // 3. Vérifier les résultats
                System.assert(e.getMessage().contains('Vous ne pouvez pas modifier une commande activée.'), 'Le message d’erreur attendu n’a pas été trouvé.');
            }
        Test.stopTest();

    }


    @isTest
    static void testAfterInsert() {

        // 1. Préparer les données de test
        List<Account> accounts = [SELECT Id FROM Account];

        // 2. Insert Orders pour exécuter la méthode onAfterInsert
        Test.startTest();
            List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
                1,          // nombre de commandes
                accounts,   // Liste de comptes
                'Draft',    // status de départ
                2           // nombre de produits commandé
            );
        Test.stopTest();
        
        // 3. Vérifier le résultat
        List<Account> updatedAccounts = [SELECT Id, isActive__c FROM Account];
        for (Account acc : updatedAccounts) {
            System.assertEquals(true, acc.isActive__c, 'Le compte doit être actif car il y a une commande.');
        }

    }


    @isTest
    static void testBeforeUpdate() {

        // 1. Préparer les données de test
        List<Account> accounts = [SELECT Id FROM Account];
        List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
            1,          // nombre de commandes
            accounts,   // Liste de comptes
            'Draft',    // status de départ
            0           // nombre de produits commandé
        );

        // 2. Update Orders pour exécuter la méthode onBeforeUpdate
        for (Order ord : orders) {
            ord.Status = 'Activated';
        }
        Test.startTest();
            try {
                update orders;
            } catch (DmlException e) {
                // 3. Vérifier les résultats
                System.assert(e.getMessage().contains('Merci de saisir au moins un produit pour activer la commande.'), 'Le message d’erreur attendu n’a pas été trouvé.');
            }
        Test.stopTest();

    }


    @isTest
    static void testAfterDelete() {

        // 1. Préparer les données de test
        List<Account> accounts = [SELECT Id FROM Account];
        List<Order> orders = [SELECT Id FROM Order];
    
        // 2. Insert Orders pour exécuter la méthode onAfterInsert
        Test.startTest();
            delete orders;
        Test.stopTest();

        // 3. Vérifier le résultat
        List<Account> updatedAccounts = [SELECT Id, isActive__c FROM Account];
        for (Account acc : updatedAccounts) {
            System.assertEquals(false, acc.isActive__c, 'Le compte doit être inactif car pas de commande.');
        }

    }


    @isTest
    static void testBulkOrders() {

        // 1. Préparer les données de test
        List<Account> accounts = [SELECT Id FROM Account];

        // 2. Insert Orders pour exécuter la méthode onAfterInsert
        Test.startTest();
            List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
                100,          // nombre de commandes
                accounts,   // Liste de comptes
                'Draft',    // status de départ
                2           // nombre de produits commandé
            );
        Test.stopTest();
        
        // 3. Vérifier le résultat
        List<Account> updatedAccounts = [SELECT Id, isActive__c FROM Account];
        for (Account acc : updatedAccounts) {
            System.assertEquals(true, acc.isActive__c, 'Le compte doit être actif car il y a 100 commande.');
        }

    }
    
}