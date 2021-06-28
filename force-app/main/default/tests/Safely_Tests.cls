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
            System.assert(new CanTheUser().create(account));
            insert account;


            Test.startTest();
            account.Name = 'UpdatedAccount';
            System.assert(new CanTheUser().edit(account));
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

            System.assert(new CanTheUser().create(account));

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

            System.assert(new CanTheUser().create(account));
            insert account;

            Test.startTest();
            System.assert(new CanTheUser().destroy(account));
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
    static void testDoQueryMethodsPositive() {

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Account');
        op.PermissionsRead = true;
        op.PermissionsViewAllRecords = true;
        insert op;

        System.runAs(new User(Id = UserInfo.getUserId())){

            Account account = (Account) new Account(name = 'TestAccount');
            System.assert(new CanTheUser().create(account));
            insert account;
        }

        User ma = makeMinimumAccessUser();
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = ma.Id);

        System.runAs(ma){
            Test.startTest();
            System.assert(new CanTheUser().read(new Account()));
            List<Account> acctList = (List<Account>) new Safely().doQuery('SELECT Id FROM Account');
            Test.stopTest();

            System.assertEquals(
                1,
                acctList.size(),
                'Expected one query result in the list'
            );
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

        if(new CanTheUser().create(testUser)){
            insert testUser;
            return testUser;
        }
        return null;

    }

}
