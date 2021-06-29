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
<<<<<<< HEAD
    static void testDoInsertMethodsNegative() {
        User ma = makeMinimumAccessUser();
        System.runAs(ma){

            Account account = (Account) new Account(name = 'TestAccount');
            Test.startTest();
            List<Database.SaveResult> results = new Safely().doInsert(account);
            Test.stopTest();
            System.assertEquals(
                0,
                results.size(),
                'Expected zero save results in the list'
            );
        }
    }

    @isTest
    static void testDoUpdateMethodsPositive() {

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Account');
        op.PermissionsRead = true;
        op.PermissionsCreate = true;
        op.PermissionsEdit = true;
        insert op;

        User ma = makeMinimumAccessUser();
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = ma.Id);
        System.runAs(ma){

            Account account = (Account) new Account(name = 'TestAccount');
            System.assert(CanTheUser.create(account));
            insert account;


            Test.startTest();
            account.Name = 'UpdatedAccount';
            System.assert(CanTheUser.edit(account));
            List<Database.SaveResult> results = new Safely().doUpdate(account);
            Test.stopTest();

            System.assertEquals(
                1,
                results.size(),
                'Expected one update result in the list'
            );
            System.assert(results.get(0).success, 'This dml should succeed');
        }
    }

    @isTest
    static void testDoUpdateMethodsNegative() {

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Account');
        op.PermissionsRead = true;
        op.PermissionsCreate = true;
        op.PermissionsEdit = false;
        insert op;

        User ma = makeMinimumAccessUser();
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = ma.Id);
        System.runAs(ma){

            Account account = (Account) new Account(name = 'TestAccount');
            System.assert(CanTheUser.create(account));
            insert account;


            Test.startTest();
            account.Name = 'UpdatedAccount';
            System.assert(!(CanTheUser.edit(account)));
            List<Database.SaveResult> results = new Safely().doUpdate(account);
            Test.stopTest();

            System.assertEquals(
                0,
                results.size(),
                'Expected zero update results in the list'
            );
        }
    }

    @isTest
    static void testDoUpsertMethodsPositive() {

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Account');
        op.PermissionsRead = true;
        op.PermissionsEdit = true;
        op.PermissionsCreate = true;
        insert op;

        User ma = makeMinimumAccessUser();
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = ma.Id);
        System.runAs(ma){

            Account account = (Account) new Account(name = 'TestAccount');
            System.assert(CanTheUser.ups(account));

            Test.startTest();

            List<Database.UpsertResult> results = new Safely().doUpsert(account);

            System.assertEquals(
                1,
                results.size(),
                'Expected one upsert (insert) result in the list'
            );

            account.Name = 'UpdatedAccount';
            results = new Safely().doUpsert(account);
            Test.stopTest();

            System.assertEquals(
                1,
                results.size(),
                'Expected one upsert (update) result in the list'
            );
            System.assert(results.get(0).success, 'This dml should succeed');
        }
    }

    @isTest
    static void testDoUpsertMethodsNegative() {

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Account');
        op.PermissionsRead = true;
        op.PermissionsEdit = false;
        op.PermissionsCreate = true;
        insert op;

        User ma = makeMinimumAccessUser();
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = ma.Id);
        System.runAs(ma){

            Account account = (Account) new Account(name = 'TestAccount');
            System.assert(CanTheUser.create(account));
            System.assertEquals(false, CanTheUser.edit(account));

            Test.startTest();

            List<Database.UpsertResult> results = new Safely().doUpsert(account);

            System.assertEquals(
                0,
                results.size(),
                'Expected zero upsert (insert) results in the list'
            );
        }
    }

    @isTest
    static void testDoDeleteMethodsPositive() {

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Account');
        op.PermissionsRead = true;
        op.PermissionsCreate = true;
        op.PermissionsEdit = true;
        op.PermissionsDelete = true;
        insert op;

        User ma = makeMinimumAccessUser();
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = ma.Id);
        System.runAs(ma){

            Account account = (Account) new Account(name = 'TestAccount');

            System.assert(CanTheUser.create(account));
            insert account;

            Test.startTest();
            System.assert(CanTheUser.destroy(account));
            List<Database.DeleteResult> results = new Safely().doDelete(account);
            Test.stopTest();

            System.assertEquals(
                1,
                results.size(),
                'Expected one delete result in the list'
            );
            System.assert(results.get(0).success, 'This dml should succeed');
        }
    }

    @isTest
    static void testDoDeleteMethodsNegative() {

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Account');
        op.PermissionsRead = true;
        op.PermissionsCreate = true;
        op.PermissionsEdit = true;
        op.PermissionsDelete = false;
        insert op;

        User ma = makeMinimumAccessUser();
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = ma.Id);
        System.runAs(ma){

            Account account = (Account) new Account(name = 'TestAccount');

            System.assert(CanTheUser.create(account));
            insert account;

            Test.startTest();
            System.assertEquals(false, CanTheUser.destroy(account));
            List<Database.DeleteResult> results = new Safely().doDelete(account);
            Test.stopTest();

            System.assertEquals(
                0,
                results.size(),
                'Expected zero delete result in the list'
            );
        }
    }

    @isTest
    static void testDoQueryMethodsPositive() {

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Account');
        op.PermissionsRead = true;
        op.PermissionsViewAllRecords = true;
        insert op;

        System.runAs(new User(Id = UserInfo.getUserId())){

            Account account = (Account) new Account(name = 'TestAccount');
            System.assert(CanTheUser.create(account));
            insert account;
        }

        User ma = makeMinimumAccessUser();
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = ma.Id);

        System.runAs(ma){
            Test.startTest();
            System.assert(CanTheUser.read(new Account()));
            List<Account> acctList = (List<Account>) new Safely().doQuery('SELECT Id FROM Account');
            Test.stopTest();

            System.assertEquals(
                1,
                acctList.size(),
                'Expected one query result in the list'
            );
        }
    }

    @isTest
    static void testDoQueryMethodsInaccessibleFields() {

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Account');
        op.PermissionsRead = true;
        op.PermissionsViewAllRecords = true;
        insert op;

        System.runAs(new User(Id = UserInfo.getUserId())){

            Account account = (Account) new Account(name = 'TestAccount');
            System.assert(CanTheUser.create(account));
            insert account;
        }

        User ma = makeMinimumAccessUser();
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = ma.Id);

        System.runAs(ma){
            Test.startTest();
            System.assert(CanTheUser.read(new Account()));
            List<Account> acctList = (List<Account>) new Safely().doQuery('SELECT Id, Type, NumberOfEmployees FROM Account');
            Test.stopTest();

            System.assertEquals(
                1,
                acctList.size(),
                'Expected one query result in the list'
            );
        }
    }

    @isTest
    static void testDoQueryMethodsInaccessibleFieldsThrowException() {

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Account');
        op.PermissionsRead = true;
        op.PermissionsViewAllRecords = true;
        insert op;

        System.runAs(new User(Id = UserInfo.getUserId())){

            Account account = (Account) new Account(name = 'TestAccount');
            System.assert(CanTheUser.create(account));
            insert account;
        }

        User ma = makeMinimumAccessUser();
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = ma.Id);

        System.runAs(ma){
            Test.startTest();
            System.assert(CanTheUser.read(new Account()));
            Safely saf = new Safely();
            saf.throwIfRemovedFields();
            try{
            List<Account> acctList = (List<Account>) saf.doQuery('SELECT Id, Type, NumberOfEmployees FROM Account');
            } catch (Safely.RemovedFieldsException r){
                System.assert(r.getMessage().containsIgnoreCase('numberofemployees'));
            }
            Test.stopTest();
        }
    }

    /**
     * Start methods for creating user for System.RunAs
     */
    public static User makeMinimumAccessUser(){
        List<Profile> p = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND Name = 'Minimum Access - Salesforce' LIMIT 1];
        if(!p.isEmpty()){
            User u = createTestUser(p[0]);
            if(u != null){ return u; }
        }
        return new User(Id = UserInfo.getUserId());
    }

    /**
    * Creates a new User
    * @parameter Profile assign the user a Profile (required field)
    * @return Testuser
    */
    private static User createTestUser( Profile p ) {

        String namePrefix = 'safelyTest' + math.rint(math.random() * 100000);

        User testUser = new User();
        testUser.Email 				= 'test@test.com';
        testUser.Username 			= namePrefix + '@Testuser.com';
        testUser.LastName 			= 'test';
        testUser.Alias 				= 'test';
        testUser.ProfileId 			= p.Id;
        testUser.LanguageLocaleKey 	= 'en_US';
        testUser.LocaleSidKey 		= 'en_US';
        testUser.TimeZoneSidKey 	= 'America/Chicago';
        testUser.EmailEncodingKey 	= 'UTF-8';

        if(CanTheUser.create(testUser)){
            insert testUser;
            return testUser;
        }
        return null;

    }

=======
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
>>>>>>> f5a41edc6eed16fe39f4e54fc515bf74813cddab
}
