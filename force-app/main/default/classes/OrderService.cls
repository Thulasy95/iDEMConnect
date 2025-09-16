public with sharing class OrderService implements IOrderService {

    public static IOrderService newInstance(){
        return (IOrderService) Application.Service.newInstance(IOrderService.class);
    }

    public Map<Id,Integer> countOrderItems(List<Order> ordersToCheck) {

        // Extraction des Ids des commandes depuis la liste
        Set<Id> ordersIds = new Set<Id>();
        for (Order order : ordersToCheck) {
            ordersIds.add(order.Id);
        }

        // Requête d'agrégation SOQL qui compte le nombre de produits commandés par commandes,
        List<AggregateResult> results = [SELECT OrderId, COUNT(Id) total FROM OrderItem WHERE OrderId IN: ordersIds GROUP BY OrderId];

        Map<Id,Integer> numberOfOrderItemsByOrderId = new Map<Id,Integer>();

        for (AggregateResult result : results) {
            numberOfOrderItemsByOrderId.put( (Id)result.get('OrderId') , (Integer)result.get('total') );
        }

        return numberOfOrderItemsByOrderId;
        
    }

}