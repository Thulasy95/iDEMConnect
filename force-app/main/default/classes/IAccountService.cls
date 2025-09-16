public interface IAccountService {

    void updateActive(Set<Id> accountIds);
    Map<Id,Integer> countOrders(List<Account> accountsToUpdate);

}