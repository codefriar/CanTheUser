/**
 * @description A reusable, intuitive library for determining wether or not the
 * current use can create, read, edit, or delete objects as well as
 * determining if the user has access or update permissions on specific fields.
 * This class name was chosen to facilitate easy-to-understand and read code.
 * Whenever you need to check FLS or CRUD access your code reads like this
 * `if(CanTheUser.read(new account())){}` making the calling and use of this
 * code easy and intuitive.
 * @group Security Recipes
 */
public with sharing class CanTheUser {
    @testVisible
    private static Map<String, Set<String>> accessibleFieldsByObject = new Map<String, Set<String>>();
    @testVisible
    private static Map<String, Set<String>> updatableFieldsByObject = new Map<String, Set<String>>();

    public enum CrudType {
        CREATE,
        READ,
        EDIT,
        DEL
    }

    public enum FLSType {
        ACCESSIBLE,
        UPDATABLE
    }

    /**
     * @description This variable stores, within the same transaction, all previously calculated
     * FLS results for an object. This prevents multiple calls to this library within the same
     * transaction from executing more than a single describe call.
     * @return   return description
     */
    Map<String, Map<FLSType, Boolean>> memoizedFLSResults = new Map<String, Map<FLSType, Boolean>>();

    /**
     * This class' name was chosen to facilitate easy-to-understand and read
     * code. Whenever you need to check FLS or CRUD access your code reads like
     * this
     * `if(new CanTheUser().read(new account())){}` making the calling and use of this
     * code easy and intuitive.
     */

    /**
     * @description
     * @param obj the object type to check
     * @param permission create, read, update or delete
     * @return Boolean
     * @example
     * System.debug(CanTheUser.crud(new Account(), CanTheUser.CrudType.READ));
     **/
    public Boolean crud(SObject obj, CrudType permission) {
        switch on permission {
            when CREATE {
                return obj.getSObjectType().getDescribe().isCreateable();
            }
            when READ {
                return obj.getSObjectType().getDescribe().isAccessible();
            }
            when EDIT {
                return obj.getSObjectType().getDescribe().isUpdateable();
            }
            when DEL {
                return obj.getSObjectType().getDescribe().isDeletable();
            }
        }
        return false;
    }

    public Boolean crud(List<SObject> objs, CrudType permission) {
        return this.crud(objs?.get(0), permission);
    }

    /**
     * @description convenience api for determining if the running user can
     * create the specified object
     * @param obj Object type to check create permissions on
     * @return Boolean
     * @example
     * System.debug(CanTheUser.create(new Account()));
     **/
    public Boolean create(SObject obj) {
        return this.crud(obj, CrudType.CREATE);
    }

    /**
     * @descriptionconvenience api for determining if the running user can
     * create the specified object
     * @param  objs list of objects. Only the first will be checked. (logically, a list is of uniform type
     * and, and if the user can create one)
     * @return      return boolean
     */
    public Boolean create(List<SObject> objs) {
        return this.crud(objs?.get(0), CrudType.CREATE);
    }

    /**
     * @description convenience api for determining if the running user can
     * read / access the specified object
     * @param obj object type to check read permissions on
     * @return Boolean
     * @example
     * System.debug(CanTheUser.read(new Account()));
     **/
    public Boolean read(SObject obj) {
        return this.crud(obj, CrudType.READ);
    }

    /**
     * @description convenience api for determining if the running user can
     * read / access the specified objects
     * @param obj object type to check read permissions on
     * @return Boolean
     * @example
     **/
    public Boolean read(List<SObject> objs) {
        return this.crud(objs?.get(0), CrudType.READ);
    }

    /**
     * @description convenience api for determining if the running user can
     * edit / update the specified object
     * @param obj object type to check edit permissions on
     * @return Boolean
     * @example
     * System.debug(CanTheUser.edit(new Account()));
     **/
    public Boolean edit(SObject obj) {
        return this.crud(obj, CrudType.EDIT);
    }

    /**
     * @description convenience api for determining if the running user can
     * edit / update the specified objects
     * @param obj object type to check edit permissions on
     * @return Boolean
     * @example
     **/
    public Boolean edit(List<SObject> objs) {
        return this.crud(objs?.get(0), CrudType.EDIT);
    }

    /**
     * @description convenience api for determining if the running user can
     * delete/destroy the specified object
     * @param obj object type to check destroy permissions on
     * @return Boolean
     * @example
     * System.debug(CanTheUser.destroy(new Account()));
     **/
    public Boolean destroy(SObject obj) {
        return this.crud(obj, CrudType.DEL);
    }

    public Boolean destroy(List<SObject> objs) {
        return this.crud(objs?.get(0), CrudType.DEL);
    }

    /**
     * @description public method to determine if a given field on a given
     * object is Accessible (readable)
     * @param obj the object in question, in string form
     * @param field the field in question in SObjectField form
     * @return Boolean
     * @example
     * System.debug(CanTheUser.flsAccessible('Account', 'Name'));
     **/
    public Boolean flsAccessible(String obj, String field) {
        return getFLSForFieldOnObject(obj, field, FLSType.ACCESSIBLE);
    }

    /**
     * @description  bulk form of flsAccessible
     * @param obj    Obj name on which to check
     * @param fields Set of Fields to check for accessibility.
     * @return      `Map<String, Boolean>`
     * @example
     * String[] fields = new String[]{'Name', 'ShippingStreet'};
     * System.debug(CanTheUser.bulkFLSAccessible('Account', fields));
     */
    public Map<String, Boolean> bulkFLSAccessible(
        String obj,
        Set<String> fields
    ) {
        Map<String, Boolean> results = new Map<String, Boolean>();
        for (String field : fields) {
            results.put(field, flsAccessible(obj, field));
        }
        return results;
    }

    /**
     * @description public method to determine if a given field on a given
     * object is Updatable.
     * @param obj the string version of an object name
     * @param field the field to check
     * @return Boolean
     * @example
     * System.debug(CanTheUser.flsUpdatable('Account', 'Name'));
     **/
    public Boolean flsUpdatable(String obj, String field) {
        return getFLSForFieldOnObject(obj, field, FLSType.UPDATABLE);
    }

    /**
     * @description  bulk form of flsUpdatable call
     * @param obj    Name of the object
     * @param fields Set of Field names to check
     * @return      `Map<String, Boolean>`
     * @example
     * String[] fields = new String[]{'Name', 'ShippingStreet'};
     * System.debug(CanTheUser.bulkFLSUpdatable('Account', fields));
     */
    public Map<String, Boolean> bulkFLSUpdatable(
        String obj,
        Set<String> fields
    ) {
        Map<String, Boolean> results = new Map<String, Boolean>();
        for (String field : fields) {
            results.put(field, flsUpdatable(obj, field));
        }
        return results;
    }

    /**
     * @description     Abstracted method for retrieving or calculating
     * (memoization) of the FLS for a given field on a given object.
     * @param obj       String version of object name to check
     * @param field     String version of the field to check
     * @param checkType Enum of Accessible or Updatable.
     * @return         `Boolean`
     */
    private Boolean getFLSForFieldOnObject(
        String obj,
        String field,
        FLSType checkType
    ) {
        if (this.memoizedFLSResults.get(field.toLowerCase()) == null) {
            this.memoizedFLSResults.putAll(calculateFLS(obj));
        }
        Boolean results = this.memoizedFLSResults.get(field.toLowerCase())
            ?.get(checkType);
        return (results != null && results) ? true : false;
    }

    /**
     * @description   Calculates the FLS for a given object type
     * @param objType String name of the object type
     * @return        `Map<String, Map<FLSType, Boolean>>`
     */
    private Map<String, Map<FLSType, Boolean>> calculateFLS(String objType) {
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(
            new List<String>{ objType }
        );

        Map<String, Map<FLSType, Boolean>> results = new Map<String, Map<FLSType, Boolean>>();
        for (SObjectField field : descResult[0].fields.getMap().values()) {
            DescribeFieldResult fieldDetails = field.getDescribe();
            String fieldKey = String.valueOf(field).toLowerCase();
            results.put(fieldKey, new Map<FLSType, Boolean>());
            results.get(fieldKey)
                .put(FLSType.ACCESSIBLE, fieldDetails.isAccessible());
            results.get(fieldKey)
                .put(FLSType.UPDATABLE, fieldDetails.isUpdateable());
        }
        return results;
    }
}
