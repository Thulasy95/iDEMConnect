public class BatchAccountCreateTask implements Database.Batchable<sObject>, Database.Stateful {

    // Permet de tracer le nombre de comptes mis à jour
    @TestVisible
    private Integer recordsProcessed = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {

        //récupère les comptes qui n'ont pas de commandes ni de tâche de type "Call"
        //On récupère d'abord toutes les comptes qui ont déjà une tache de type "Call"
        Set<Id> taskWhatIds = new Set<Id>();
        for(Task task : [SELECT Id, WhatId FROM Task WHERE Subject = 'Call' AND WhatId != null]){
            taskWhatIds.add(task.WhatId);
        }

        //Puis on récupère les comptes qui n'ont pas de commandes et qui ne sont pas dans taskWhatIds
        String query = 'SELECT Id, Name, OwnerId '+
                       'FROM Account '+
                       'WHERE Id NOT IN :taskWhatIds '+
                       'AND Id NOT IN (SELECT AccountId FROM Order)';

        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext bc, List<Account> scope){

        if (scope.isEmpty()) {
            
            System.debug('Pas de compte à mettre à jour');

        } else {

            List<Task> taskToCreate = new List<Task>();
            for(Account acc : scope){

                //Création de la tâche
                Task task = new Task();
                task.Subject = 'Call';
                task.Status = 'New';
                task.Priority = 'Normal';
                task.IsReminderSet = true;
                task.ReminderDateTime = Datetime.now().addDays(5);
                task.WhatId = acc.Id;
                task.OwnerId = acc.OwnerId;

                //Ajout de la tâche à la liste taskToCreate
                taskToCreate.add(task);

                //nombre de comptes mis à jour : +1
                recordsProcessed ++;

            }

            if(!taskToCreate.isEmpty()){
                insert taskToCreate;
            }

        }

    }

    public void finish(Database.BatchableContext bc){
        // Trace dans les logs le nombre total de comptes mis à jour par le batch
        System.debug('Nombre total de comptes mis à jour : ' + recordsProcessed );
        
        //Récupérer les infos système du job dans AsyncApexJob
        AsyncApexJob job = [SELECT Id, 
            Status,             // Statut du Job
            NumberOfErrors,     // Nombre d'erreurs
            JobItemsProcessed,  // Nombre de lots traités
            TotalJobItems,      // Nombre total de lots traités
            CreatedBy.Email     // Utilisateur qui a lancé le batch
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];

        System.debug('AsynchApexJob batch : ' + job);

    }

}

