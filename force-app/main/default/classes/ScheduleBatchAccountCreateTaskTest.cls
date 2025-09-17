@isTest
private class ScheduleBatchAccountCreateTaskTest {

    // CRON expression factice : 1er janvier 2042 à minuit
    private static final String CRON_EXP = '0 0 0 1 1 ? 2042';
    
    @isTest
    static void testScheduledJobIsCreated() {

        // Planifie le job
        Test.startTest();
            String cronId = System.schedule('ScheduledApexTest', CRON_EXP, new ScheduleBatchAccountCreateTask());
        Test.stopTest();

        // Vérifie que le CronTrigger a bien été créé
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :cronId
        ];

        System.assertNotEquals(null, ct, 'Le CronTrigger doit exister');
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Le CronTrigger doit avoir la bonne expression CRON');

    }
    
}