@isTest
private class Safely_Tests {

    @isTest
    static void testConstructorChains() {
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
    static void testDoInsertMethodsNoThrowPositive() {
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

    @isTest
    static Void testMarketingProfileGeneratesInsertExceptionPositive() {
        User testUser = TestUtils.createMarketingUser(true);
        Boolean didCatchTheRightException = false;
        Account account = (Account) new Account(
            name = 'TestAccount',
            TradeStyle = 'invalid'
        );
        Test.startTest();
        System.runAs(testUser) {
            try {
                new Safely().throwIfRemovedFields().doInsert(account);
            } catch (Safely.RemovedFieldsException rfe) {
                if (
                    rfe.getMessage()
                        .containsIgnoreCase('and the following fields')
                ) {
                    didCatchTheRightException = true;
                }
            }
        }
        Test.stopTest();
        System.assert(
            didCatchTheRightException,
            'Expected to have caught a removedFieldsException'
        );
    }

    @isTest
    static Void testDoUpdateMethodsNoThrowPositive() {
        Account account = (Account) new Account(name = 'TestAccount');
        insert account;
        account.name = 'TestAccount2';
        Test.startTest();
        List<Database.SaveResult> results = new Safely().doUpdate(account);
        Test.stopTest();
        System.assertEquals(
            1,
            results.size(),
            'Expected one save result in the list'
        );
        System.assert(results.get(0).success, 'This dml should succeed');
    }

    @isTest
    static Void testMarketingProfileGeneratesUpdateExceptionPositive() {
        User testUser = TestUtils.createMarketingUser(true);
        Boolean didCatchTheRightException = false;
        Account account = (Account) new Account(name = 'TestAccount');
        insert account;
        account.TradeStyle = 'off limits field';
        Test.startTest();
        System.runAs(testUser) {
            try {
                new Safely().throwIfRemovedFields().doUpdate(account);
            } catch (Safely.RemovedFieldsException rfe) {
                if (
                    rfe.getMessage()
                        .containsIgnoreCase('and the following fields')
                ) {
                    didCatchTheRightException = true;
                }
            }
        }
        Test.stopTest();
        System.assert(
            didCatchTheRightException,
            'Expected to have caught a removedFieldsException'
        );
    }

    @isTest
    static Void testDoUpsertMethodsNoThrowPositive() {
        Account account = (Account) new Account(name = 'TestAccount');
        insert account;
        account.name = 'TestAccount2';
        Account account2 = (Account) new Account(name = 'TestAccount');
        List<Account> accounts = new List<Account>{ account, account2 };
        Test.startTest();
        List<Database.upsertResult> insertResults = new Safely()
            .doUpsert(account);
        List<Database.UpsertResult> mixedResults = new Safely()
            .doUpsert(accounts);
        Test.stopTest();
        System.assertEquals(
            1,
            insertResults.size(),
            'Expected one save result in the list'
        );
        System.assertEquals(2, mixedResults.size(), 'expected two results');
        System.assert(insertResults.get(0).success, 'This dml should succeed');
        Integer updated = 0;
        Integer inserted = 0;
        for (Database.upsertResult result : mixedResults) {
            System.assert(result.success, 'This dml should succeed');
            if (result.created) {
                inserted++;
            } else {
                updated++;
            }
        }
        System.assertEquals(1, updated, 'Expected one to have been updated');
        System.assertEquals(1, inserted, 'Expected one to have been inserted');
    }

    @isTest
    static Void testMarketingProfileGeneratesUpsertExceptionPositive() {
        User testUser = TestUtils.createMarketingUser(true);
        Boolean didCatchTheRightException = false;
        Account account = (Account) new Account(name = 'TestAccount');
        insert account;
        account.TradeStyle = 'off limits field';
        Test.startTest();
        System.runAs(testUser) {
            try {
                new Safely().throwIfRemovedFields().doUpsert(account);
            } catch (Safely.RemovedFieldsException rfe) {
                if (
                    rfe.getMessage()
                        .containsIgnoreCase('and the following fields')
                ) {
                    didCatchTheRightException = true;
                }
            }
        }
        Test.stopTest();
        System.assert(
            didCatchTheRightException,
            'Expected to have caught a removedFieldsException'
        );
    }

    @isTest
    static Void testDeleteWithRegularProfilePositive() {
        Account account = (Account) new Account(name = 'TestAccount');
        insert account;
        Test.startTest();
        List<Database.deleteResult> results = new Safely()
            .throwIfRemovedFields()
            .doDelete(account);
        Test.stopTest();
        System.assert(results.get(0).success, 'expected this dml to succeed');
    }

    @isTest
    static Void testDeleteWithRegularProfileNegative() {
        User testUser = TestUtils.createMinAccessUser(true);
        Account account = (Account) new Account(name = 'TestAccount');
        insert account;
        Test.startTest();
        List<Database.deleteResult> results;
        System.runAs(testUser) {
            results = new Safely().throwIfRemovedFields().doDelete(account);
        }

        Test.stopTest();
        System.assert(results.isEmpty(), 'expected this dml to fail');
    }

    @isTest
    static Void testDoQueryPositive() {
        Account account = (Account) new Account(name = 'TestAccount');
        insert account;
        Test.startTest();
        List<Account> accounts = (List<Account>) new Safely()
            .throwIfRemovedFields()
            .doQuery('SELECT ID, Name FROM Account');
        Test.stopTest();
        System.assertEquals(1, Accounts.size(), 'expected to find one record');
    }

    // @isTest
    // static Void testDoQueryThrowsRemovedFieldsException() {
    //     User testUser = TestUtils.createMinAccessUser(true);
    //     Account account = (Account) new Account(name = 'TestAccount');
    //     insert account;
    //     Test.startTest();
    //     List<Account> accounts = (List<Account>) new Safely()
    //         .throwIfRemovedFields()
    //         .doQuery('SELECT ID, Name FROM Account');
    //     Test.stopTest();
    //     System.assertEquals(1, Accounts.size(), 'expected to find one record');
    // }
}
