public interface IOrderService {

    Map<Id,Integer> countOrderItems(List<Order> ordersToCheck);

}