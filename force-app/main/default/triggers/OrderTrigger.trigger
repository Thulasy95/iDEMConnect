trigger OrderTrigger on Order (after delete, after insert, after update, before delete, before insert, before update) {

    // Instancie la classe Domain et exécute les méthodes correspondantes selon l’événement du trigger
	fflib_SObjectDomain.triggerHandler(OrderTriggerHandler.class);

}