@IsTest
private class Safely_Tests {
    @IsTest
    private static void testConstructorChains() {
        Test.startTest();
        Safely instanceOne = new Safely().allOrNothing();
        Safely instanceTwo = new Safely().throwIfRemovedFields();
        Test.stopTest();

        System.assertEquals(true, instanceOne.allOrNothing, 'Expected Fluent constructor to have set this to true');
        System.assertEquals(false, instanceOne.throwIfRemovedFields, 'Expected this to remain false');
        System.assertEquals(true, instanceTwo.throwIfRemovedFields, 'Expected Fluent constructor to have set this to true');
        System.assertEquals(false, instanceTwo.allOrNothing, 'Expected this to remain false');
    }

    @IsTest
    private static void testDoInsertMethodsNoThrowPositive() {
        Contact con = (Contact) new Contact(LastName = 'TestContact');
        Test.startTest();
        List<Database.SaveResult> results = new Safely().doInsert(con);
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Expected one save result in the list');
        System.assert(results.get(0).success, 'This dml should succeed');
    }

    @IsTest
    private static void testDoInsertNegative() {
        User minAccessUser = ApexRecipes_TestUtils.createMinAccessUser(true);

        System.runAs(minAccessUser) {
            System.assert(!CanTheUser.create(new Contact()), 'Contact should not be available to MinAccessUser');
            Test.startTest();
            Contact con = (Contact) new Contact(LastName = 'TestContact');
            List<Database.SaveResult> results = new Safely().doInsert(con);
            Test.stopTest();
            System.assertEquals(0, results.size(), 'Expected zero delete result in the list');
        }
    }

    @IsTest
    private static void testMarketingProfileGeneratesInsertExceptionPositive() {
        User marketingUser = ApexRecipes_TestUtils.createStandardUser(true);
        Boolean didCatchTheRightException = false;
        Contact con = (Contact) new Contact(LastName = 'TestContact', DoNotCall = true);
        Test.startTest();
        System.runAs(marketingUser) {
            try {
                new Safely().throwIfRemovedFields().doInsert(con);
            } catch (Safely.RemovedFieldsException rfe) {
                if (rfe.getMessage().containsIgnoreCase('and the following fields')) {
                    didCatchTheRightException = true;
                }
            }
        }
        Test.stopTest();
        System.assert(didCatchTheRightException, 'Expected to have caught a removedFieldsException');
    }

    @IsTest
    private static void testDoUpdateMethodsNoThrowPositive() {
        Contact con = (Contact) new Contact(LastName = 'TestContact');
        insert con;
        con.LastName = 'TestContact2';
        Test.startTest();
        List<Database.SaveResult> results = new Safely().doUpdate(con);
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Expected one save result in the list');
        System.assert(results.get(0).success, 'This dml should succeed');
    }

    @IsTest
    private static void testDoUpdateNegative() {
        User minAccessUser = ApexRecipes_TestUtils.createMinAccessUser(true);

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Contact');
        op.PermissionsRead = true;
        op.PermissionsCreate = true;
        op.PermissionsEdit = false;
        insert op;

        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = minAccessUser.Id);
        System.runAs(minAccessUser) {
            Contact con = (Contact) new Contact(LastName = 'TestContact');
            System.assert(CanTheUser.create(con), 'Contact should be available to MinAccessUser with permission set');
            insert con;

            Test.startTest();
            con.LastName = 'UpdatedContact';
            System.assert(!(CanTheUser.edit(con)), 'Contact should not be available to MinAccessUser to edit with permission set');
            List<Database.SaveResult> results = new Safely().doUpdate(con);
            Test.stopTest();

            System.assertEquals(0, results.size(), 'Expected zero update results in the list');
        }
    }

    @IsTest
    private static void testMarketingProfileDeleteNegative() {
        User marketingUser = ApexRecipes_TestUtils.createStandardUser(true);
        Case c = (Case) new Case(Subject = 'TestCase');
        insert c;

        System.runAs(marketingUser) {
            Test.startTest();

            List<Database.DeleteResult> results = new Safely().doDelete(c);
            Test.stopTest();
            System.assertEquals(0, results.size(), 'Expected zero delete result in the list');
        }
    }

    @IsTest
    private static void testMarketingProfileGeneratesUpdateExceptionPositive() {
        User marketingUser = ApexRecipes_TestUtils.createStandardUser(true);
        Boolean didCatchTheRightException = false;
        Contact con = (Contact) new Contact(LastName = 'TestContact');
        insert con;
        con.DoNotCall = true;
        Test.startTest();
        System.runAs(marketingUser) {
            try {
                new Safely().throwIfRemovedFields().doUpdate(con);
            } catch (Safely.RemovedFieldsException rfe) {
                if (rfe.getMessage().containsIgnoreCase('and the following fields')) {
                    didCatchTheRightException = true;
                }
            }
        }
        Test.stopTest();
        System.assert(didCatchTheRightException, 'Expected to have caught a removedFieldsException');
    }

    @IsTest
    private static void testDoUpsertMethodsNoThrowPositive() {
        Contact con = (Contact) new Contact(LastName = 'TestContact');
        insert con;
        con.LastName = 'TestContact2';
        Contact account2 = (Contact) new Contact(LastName = 'TestContact');
        List<Contact> contacts = new List<Contact>{ con, account2 };
        Test.startTest();
        List<Database.upsertResult> insertResults = new Safely().doUpsert(con);
        List<Database.UpsertResult> mixedResults = new Safely().doUpsert(contacts);
        Test.stopTest();
        System.assertEquals(1, insertResults.size(), 'Expected one save result in the list');
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

    @IsTest
    private static void testDoUpsertMethodsNegative() {
        User minAccessUser = ApexRecipes_TestUtils.createMinAccessUser(true);

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Contact');
        op.PermissionsRead = true;
        op.PermissionsCreate = true;
        op.PermissionsEdit = false;
        insert op;

        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = minAccessUser.Id);

        System.runAs(minAccessUser) {
            Contact con = (Contact) new Contact(LastName = 'TestContact01');
            Contact account2 = (Contact) new Contact(LastName = 'TestContact02');

            Test.startTest();
            List<Database.SaveResult> insertResults = new Safely().doInsert(con);
            con.LastName = 'TestContact2';
            List<Contact> contacts = new List<Contact>{ con, account2 };
            List<Database.UpsertResult> mixedResults = new Safely().doUpsert(contacts);
            Test.stopTest();
            System.assertEquals(1, insertResults.size(), 'Expected one save result in the list');
            System.assert(insertResults.get(0).success, 'This dml should succeed');
            System.assert(mixedResults.isEmpty(), 'expected no updates');
        }
    }

    @IsTest
    private static void testMarketingProfileGeneratesUpsertExceptionPositive() {
        User marketingUser = ApexRecipes_TestUtils.createStandardUser(true);
        Boolean didCatchTheRightException = false;
        Contact con = (Contact) new Contact(LastName = 'TestContact');
        insert con;
        con.DoNotCall = true;
        Test.startTest();
        System.runAs(marketingUser) {
            try {
                new Safely().throwIfRemovedFields().doUpsert(con);
            } catch (Safely.RemovedFieldsException rfe) {
                if (rfe.getMessage().containsIgnoreCase('and the following fields')) {
                    didCatchTheRightException = true;
                }
            }
        }
        Test.stopTest();
        System.assert(didCatchTheRightException, 'Expected to have caught a removedFieldsException');
    }

    @IsTest
    private static void testDeleteWithRegularProfilePositive() {
        Contact con = (Contact) new Contact(LastName = 'TestContact');
        insert con;
        Test.startTest();
        List<Database.deleteResult> results = new Safely().throwIfRemovedFields().doDelete(con);
        Test.stopTest();
        System.assert(results.get(0).success, 'expected this dml to succeed');
    }

    @IsTest
    private static void testDeleteWithRegularProfileNegative() {
        User minAccessUser = ApexRecipes_TestUtils.createMinAccessUser(true);
        Contact con = (Contact) new Contact(LastName = 'TestContact');
        insert con;
        Test.startTest();
        List<Database.deleteResult> results;
        System.runAs(minAccessUser) {
            results = new Safely().throwIfRemovedFields().doDelete(con);
        }

        Test.stopTest();
        System.assert(results.isEmpty(), 'expected this dml to fail');
    }

    @IsTest
    private static void testDoQueryPositive() {
        Contact con = (Contact) new Contact(LastName = 'TestContact');
        insert con;
        Test.startTest();
        List<Contact> contacts = (List<Contact>) new Safely().throwIfRemovedFields().doQuery('SELECT Id, Name FROM Contact');
        Test.stopTest();
        System.assertEquals(1, Contacts.size(), 'expected to find one record');
    }

    @IsTest
    private static void testDoQueryThrowsRemovedFieldsException() {
        User minAccessUser = ApexRecipes_TestUtils.createMinAccessUser(true);

        PermissionSet ps = new PermissionSet(Label = 'testPermSet', Name = 'testPermSet');
        insert ps;
        ObjectPermissions op = new ObjectPermissions(ParentId = ps.Id, SobjectType = 'Contact');
        op.PermissionsRead = true;
        op.PermissionsViewAllRecords = true;
        insert op;
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = minAccessUser.Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Contact con = (Contact) new Contact(LastName = 'TestContact');
            insert con;
        }
        System.runAs(minAccessUser) {
            Boolean didCatchTheRightException = false;
            Test.startTest();
            Safely saf = new Safely();
            List<Contact> contacts;
            try {
                contacts = (List<Contact>) saf.throwIfRemovedFields().doQuery('SELECT Id, Name, DoNotCall FROM Contact');
            } catch (Safely.RemovedFieldsException rfe) {
                if (rfe.getMessage().containsIgnoreCase('DoNotCall')) {
                    didCatchTheRightException = true;
                }
            }
            Test.stopTest();
            System.assert(saf.throwIfRemovedFields, 'Contact.DoNotCall should not be available to MinAccessUser');
            System.assert(didCatchTheRightException, 'Expected to have caught a removedFieldsException');
        }
    }

    @IsTest
    private static void emptyCollections() {
        Test.startTest();
        List<Database.SaveResult> insertResults = new Safely().doInsert(new List<Contact>());
        List<Database.SaveResult> updateResults = new Safely().doUpdate(new List<Contact>());
        List<Database.UpsertResult> upsertResults = new Safely().doUpsert(new List<Contact>());
        List<Database.DeleteResult> deleteResults = new Safely().doDelete(new List<Contact>());
        Test.stopTest();

        System.assert(insertResults.isEmpty());
        System.assert(updateResults.isEmpty());
        System.assert(upsertResults.isEmpty());
        System.assert(deleteResults.isEmpty());
    }
}
