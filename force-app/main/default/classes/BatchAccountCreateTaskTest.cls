@isTest
private class BatchAccountCreateTaskTest {

   @isTest
    static void testBatchWithAccountsWithoutTasksOrOrders() {
        // Création de 3 comptes
        List<Account> accounts = TestDataFactory.createAccounts(3, true);
        
        //Récupération du scope
        Set<Id> taskWhatIds = new Set<Id>();
        for(Task task : [SELECT Id, WhatId FROM Task WHERE Subject = 'Call' AND WhatId != null]){
            taskWhatIds.add(task.WhatId);
        }
        List<Account> scope = [SELECT Id, Name, OwnerId FROM Account WHERE Id NOT IN :taskWhatIds AND Id NOT IN (SELECT AccountId FROM Order)];

        //Exécution du batch
        Test.startTest();
        Id jobId = Database.executeBatch(new BatchAccountCreateTask(), 200);
        Test.stopTest();

        // Vérification des résultats 
        List<Task> createdTasks = [SELECT Id, WhatId, Subject, Status, IsReminderSet FROM Task WHERE WhatId IN :scope AND Subject = 'Call' AND Status = 'New'];
        System.assertEquals(3, createdTasks.size(), '3 tâches doivent être créées');
        for (Task t : createdTasks) {
            System.assertEquals(true, t.IsReminderSet, 'la tâche devrait avoir un rappel.');
        }       

    }

    @isTest
    static void testBatchWithAccountsWithTasks() {
        // Création d’1 compte
        List<Account> accounts = TestDataFactory.createAccounts(1, true);
        // Lui ajouter une tâche "Call"
        TestDataFactory.createTasks(1, accounts[0], true);

        Test.startTest();
        Database.executeBatch(new BatchAccountCreateTask(), 200);
        Test.stopTest();

        // Vérifier qu’aucune nouvelle tâche n’a été créée
        List<Task> createdTasks = [SELECT Id FROM Task WHERE WhatId = :accounts[0].Id];
        System.assertEquals(1, createdTasks.size(), 'Le compte a déjà une tâche, aucune nouvelle tâche ne doit être créée');
    }

    @isTest
    static void testBatchWithAccountsWithOrders() {
        // Création d’1 compte + contrat obligatoire pour les Orders
        List<Account> accounts = TestDataFactory.createAccounts(1, true);
        TestDataFactory.createContracts(accounts, 1, true);
        TestDataFactory.createOrdersWithOrderItems(1, accounts, 'Draft', 1);

        Test.startTest();
        Database.executeBatch(new BatchAccountCreateTask(), 200);
        Test.stopTest();

        // Vérifier qu’aucune tâche n’a été créée
        List<Task> createdTasks = [SELECT Id FROM Task WHERE WhatId = :accounts[0].Id];
        System.assertEquals(0, createdTasks.size(), 'Le compte avec Order ne doit pas avoir de tâche créée');
    }

    @isTest
    static void testBatchFinishMethod() {
        // Au moins un compte éligible
        List<Account> accounts = TestDataFactory.createAccounts(10, true);

        Test.startTest();
        Database.executeBatch(new BatchAccountCreateTask(), 200);
        Test.stopTest();

        // Vérifier que AsyncApexJob existe et que le batch s’est exécuté
        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems
                            FROM AsyncApexJob
                            WHERE JobType = 'BatchApex'
                            ORDER BY CreatedDate DESC
                            LIMIT 1];

        System.assertEquals('Completed', job.Status, 'Le batch doit s’exécuter correctement');
        System.assertEquals(1, job.JobItemsProcessed, 'Le batch doit avoir traité 1 lot car 10 comptes créés compris dans le lot de 200');

    }

}