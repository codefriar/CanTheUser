@isTest
private class Safely_Tests {
    @isTest
    static Void testConstructorChains() {
        Test.startTest();
        Safely instanceOne = new Safely().allOrNothing();
        Safely instanceTwo = new Safely().throwIfRemovedFields();
        Test.stopTest();

        System.assertEquals(
            true,
            instanceOne.allOrNothing,
            'Expected fluid constructor to have set this to true'
        );
        System.assertEquals(
            false,
            instanceOne.throwIfRemovedFields,
            'Expected this to remain false'
        );
        System.assertEquals(
            true,
            instanceTwo.throwIfRemovedFields,
            'Expected fluid constructor to have set this to true'
        );
        System.assertEquals(
            false,
            instanceTwo.allOrNothing,
            'Expected this to remain false'
        );
    }

    @isTest
    static Void testDoInsertMethodsNoThrowPositive() {
        Account account = (Account) new Account(name = 'TestAccount');
        Test.startTest();
        List<Database.SaveResult> results = new Safely().doInsert(account);
        Test.stopTest();
        System.assertEquals(
            1,
            results.size(),
            'Expected one save result in the list'
        );
        System.assert(results.get(0).success, 'This dml should succeed');
    }
}
