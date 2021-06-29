@isTest
public with sharing class TestUtils {
    public static User createMinAccessUser(Boolean doInsert) {
        Id profileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Minimum Access - Salesforce'
        ]
        .Id;
        return createTestUser(profileId, doInsert);
    }

    public static User createMarketingUser(Boolean doInsert) {
        Id profileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Custom: Marketing Profile'
        ]
        .Id;
        return createTestUser(profileId, doInsert);
    }

    public static User createTestUser(Id profileId, boolean doInsert) {
        User u = new User(
            profileId = profileId,
            LastName = 'last',
            Email = 'Testuser@test.example.com',
            Username = 'Testuser@test.example.com' + Crypto.getRandomInteger(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        if (doInsert) {
            insert u;
        }
        return u;
    }
}
