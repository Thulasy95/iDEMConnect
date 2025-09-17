public with sharing class AccountSelector extends fflib_SObjectSelector implements IAccountSelector
{
	public static IAccountSelector newInstance(){
		return (IAccountSelector) Application.Selector.newInstance(Account.SObjectType);
	}
	
     // Retourne la liste des champs à récupérer par défaut dans les requêtes SOQL
	public List<Schema.SObjectField> getSObjectFieldList(){
		return new List<Schema.SObjectField> {
			Account.Id,
			Account.Name,
			Account.OwnerId,
			Account.isActive__c
		};
	}

	public Schema.SObjectType getSObjectType(){
		return Account.SObjectType;
	}

	public List<Account> selectById(Set<Id> idSet){
		return (List<Account>) selectSObjectsById(idSet);
	}

}