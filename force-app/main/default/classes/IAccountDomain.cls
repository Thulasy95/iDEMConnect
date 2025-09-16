public interface IAccountDomain extends fflib_ISObjectDomain {

    List<Account> getAccounts();
    void updateActive();

}