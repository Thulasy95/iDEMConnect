@isTest
public class TestDataFactory {

    // Crée une liste de comptes
    public static List<Account> createAccounts(Integer count, Boolean doInsert) {
        List<Account> accounts = new List<Account>();

        for(Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i
            ));
        }

        if(doInsert) {
            insert accounts;
        }

        return accounts;
    }

    // Crée une liste de comptes avec contrats
    public static List<Contract> createContracts(List<Account> accounts, Integer numContract, Boolean doInsert) {

        //Associer les contrats aux comptes
        List<Contract> contracts = new List<Contract>();
        for (Account acc : accounts) {
            for (Integer j = 0; j < numContract; j++) {
                contracts.add(new Contract(
                    AccountId = acc.Id,
                    Status = 'Draft',
                    StartDate = Date.today(),
                    ContractTerm = 12
                ));
            }
        }
        
        if(doInsert) {
        insert contracts;
        }
        
        return contracts;
    }


    //Crée une tâche de type "Call" sans rappel
    public static List<Task> createTasks (Integer count, Account account, Boolean doInsert)
    {
        List<Task> tasks = new List<Task>();
        for (Integer i = 0; i < count; i++) {
            tasks.add(new Task(
                Subject = 'Call',
                Status = 'New',
                Priority = 'Normal',
                WhatId = account.Id,
                OwnerId = UserInfo.getUserId()
            ));
        }

        if(doInsert) {
            insert tasks;
        }

        return tasks;
    }


    public static List<Order> createOrdersWithOrderItems (Integer numOrders, List<Account> accounts, String orderStatus, Integer numOrderItems){

        // Pricebook standard obligatoire
        Id standardPbId = Test.getStandardPricebookId();

        Map<Id,Id> contractIdByAccountId = new Map<Id,Id>();
        for (Contract c : [SELECT Id, AccountId FROM Contract]) {
            contractIdByAccountId.put(c.AccountId, c.Id);
        }
        
        // Création des Orders en Draft
        List<Order> newOrders = new List<Order>();
        for (Account acc : accounts) {
            for (Integer i = 0; i < numOrders; i++ ) {
                newOrders.add(new Order(
                    AccountId = acc.Id,
                    ContractId = contractIdByAccountId.get(acc.Id),
                    EffectiveDate = Date.today(),
                    Status = 'Draft', // statut valide pour l'insertion
                    Pricebook2Id = standardPbId,
                    OwnerId = UserInfo.getUserId()
                ));
            }
        }
        insert newOrders;
        
        // Création du produit et du PricebookEntry
        // Un OrderItem doit être lié à un PricebookEntry (et donc à un Pricebook & Product)
        // On crée donc 1 produit et 1 PricebookEntry de test pour tous les items
        Product2 prod = new Product2(Name = 'TestProduct', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPbId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // Création des OrderItems
        List<OrderItem> newOrderItems = new List<OrderItem>();
        for (Order newOrder : newOrders) {
            for (Integer j = 0; j < numOrderItems; j++) {
                newOrderItems.add(new OrderItem(
                    OrderId = newOrder.Id,
                    UnitPrice = pbe.UnitPrice,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1
                ));
            }
        }
        insert newOrderItems;

        // Mise à jour du statut si nécessaire (après avoir au moins 1 OrderItem)
        if(orderStatus != 'Draft') {
            for(Order o : newOrders){
                o.Status = orderStatus;
            }
            update newOrders;
        }

        return newOrders; 
    }

}