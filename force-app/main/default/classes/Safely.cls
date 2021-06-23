/**
 * @description Class wraps DML Calls in FLS / Crud checks.
 * Depends on CanTheUser.
 */
public with sharing class Safely {
  public class RemovedFieldsException extends Exception {
  }

  private Boolean allOrNothing = false;
  private Boolean throwIfRemovedFields = false;

  public Safely allOrNothing() {
    this.allOrNothing = true;
    return this;
  }

  public Safely throwIfRemovedFields() {
    this.throwIfRemovedFields = true;
    return this;
  }

  public Database.SaveResult doDML(
    AccessType accessType,
    List<SObject> records
  ) {
  }

  public Database.SaveResult doInsert(List<SObject> records) {
    SObjectAccessDecision securityDecision = Security.stripInaccessible(
      AccessType.CREATABLE,
      records,
      true
    );

    Map<String, Set<String>> removedFields = securityDecision.getRemovedFields();
    if (this.throwIfRemovedFields && !removedFields.isEmpty()) {
      throw new RemovedFieldsException(
        'ThrowIfRemovedFields is enabled and the following fields were removed: ' +
        removedFields
      );
    }

    return Database.insert(securityDecision.getRecords(), this.allOrNothing);
  }

  public Database.SaveResult doInsert(SObject record) {
    doInsert(new List<Sobject>{ record });
  }
}
