public class OrderTriggerHandler extends fflib_SObjectDomain {

    public OrderTriggerHandler(List<Order> sObjectList) {
        // Les classes de domaine sont initialisées avec des listes pour imposer la gestion en masse (bulkification) dans l'ensemble du code.
        super(sObjectList);
    }

    public override void onApplyDefaults() {
        //Attribue automatiquement le statut "Draft" à une commande (Order) si aucun statut n’a été défini.
        for(Order ord : (List<Order>) this.records) {
            if(ord.Status == null) {
                ord.Status = 'Draft';
            }
        }
    }

    public override void onValidate() {
        //Empêche l'enregistrement d'une commande si aucun compte (AccountId) n'y est associé
        for(Order ord : (List<Order>) this.records) {
            if(ord.AccountId == null) {
                ord.AccountId.addError('Un compte est requis pour une commande.');
            }
        }
    }

    public override void onValidate(Map<Id, SObject> oldRecords) {
        //Empêche les utilisateurs ou les processus Apex de modifier le statut d'une commande une fois qu’elle est Activated
        for(Order ord : (List<Order>) this.records) {
            Order oldRecord = (Order) oldRecords.get(ord.Id);
            if(oldRecord.Status == 'Activated' && ord.Status != oldRecord.Status) {
                ord.Status.addError('Vous ne pouvez pas modifier une commande activée.');
            }
        }
    }


    public override void onAfterInsert() {

        updateActiveOnAccount();

    }


    public override void onBeforeUpdate(Map<Id, SObject> oldOrders) {

        checkOrderItems(oldOrders);

    }


    public override void onAfterDelete() {

        updateActiveOnAccount();

    }

    private void updateActiveOnAccount() {

        Set<Id> accountIds = new Set<Id>();
        for(Order ord : (List<Order>) this.records) {
            if(ord.AccountId != null) {
                accountIds.add(ord.AccountId);
            }
        }
        
        if(!accountIds.isEmpty()){
            IAccountService accountService = (IAccountService) Application.Service.newInstance(IAccountService.class);
            accountService.updateActive(accountIds);
        }       

    }

    private void checkOrderItems(Map<Id, SObject> oldOrders){

        //Identifie les commandes qui passent du statut Draft à Activated
        List<Order> ordersToCheck = new List<Order>();
        for(Order newOrder : (List<Order>) this.records) {
            Order oldOrder = (Order) oldOrders.get(newOrder.Id);
            if(newOrder.Status == 'Activated' && oldOrder.Status == 'Draft') {
                ordersToCheck.add(newOrder);
            }
        }

        //Si aucune commande à vérifier, on sort
        if(ordersToCheck.isEmpty()) {
            return;
        }

        //Appelle le service pour compter le nombre de produits commandé par commande
        IOrderService orderService = (IOrderService) Application.Service.newInstance(IOrderService.class);
        Map<Id,Integer> numberOfOrderItemsByOrderId = orderService.countOrderItems(ordersToCheck);

        //Affiche le message d'erreur si pas de produits commandé
        for(Order ord : ordersToCheck) {
            if( numberOfOrderItemsByOrderId.get(ord.Id) == null ) {
                ord.Status.addError('Merci de saisir au moins un produit pour activer la commande.');
            }
        }

    }


    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OrderTriggerHandler(sObjectList);
        }
    }        

}
