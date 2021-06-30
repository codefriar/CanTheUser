# CanTheUser / Safely

CanTheUser/Safely is a delightful and elegant way to handle CRUD and FLS Checks. It comes in two parts: CanTheUser, and Safely. CanTheUser is focused on determining if a user can do a given CRUD operation, and whether or not the user has access to specific fields via Field Level Security (FLS). Safely, on the other hand, is dedicated to wrapping DML methods that enforce user FLS and Crud Checks. Safely, in part, relies on parts of CanTheUser, so these are shipped together.

> CanTheUser/Safely is a library extraction from [Apex Recipes](https://www.github.com/trailheadapps/apex-recipes)

## Badges

[![License: CC0-1.0](https://img.shields.io/badge/License-CC0%201.0-orange.svg)](http://creativecommons.org/publicdomain/zero/1.0/)
[![CI Workflow](https://github.com/codefriar/CanTheUser/workflows/CI/badge.svg)](_https://github.com/codefriar/CanTheUser/actions?query=workflow%3ACI_)
[![Packaging Workflow](https://github.com/codefriar/CanTheUser/workflows/Packaging/badge.svg)](_https://github.com/codefriar/CanTheUser/actions?query=workflow%3APackaging_) [![codecov](https://codecov.io/gh/codefriar/CanTheUser/branch/main/graph/badge.svg)](_https://codecov.io/gh/codefriar/CanTheUser_)
[![Twitter](https://img.shields.io/twitter/follow/Codefriar.svg?style=social)](https://img.shields.io/twitter/follow/Codefriar.svg?style=social)

## Contributing

Contributions are always welcome!

See [`contributing.md`](https://github.com/codefriar/CanTheUser/blob/main/CONTRIBUTION.md) for ways to get started.

Please adhere to this project's [`code of conduct`](https://github.com/codefriar/CanTheUser/blob/main/CODE_OF_CONDUCT.md).

## Installation

To install or deploy CanTheUser/Safely you have three options:

1. SPM Install: This is the preferred method, [but it requires SPM. Find out more here.](https://spm-registry.herokuapp.com/)
   `sfdx spm:install -n 'CanTheUser'`
1. Package Link: Click [this link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5e000000tprvAAA) to install the CanTheUser/Safely unlocked package in your org.
1. Git Clone: This is an exercise left to the reader.

## Usage/Examples

### CanTheUser Examples

CanTheUser is designed to be intuitive and easy to read and use. At a high level, it consists of CRUD checking methods that largely follow the permission names whenever that permission name is not an apex reserved word. For instance: the Read permission is checked with the Read() method. Sadly, delete is a keyword, so the delete permission is checked with destroy(). Each of these methods requires either an sObject to check or a list of sObjects to check. However, be careful when using mixed sObject lists (ie: `list<Sobject>`) rather than `list<ConcreteSObjectType>` as the list accepting variants use the first item in the list for checking.

#### CRUD Checks

Check for CREATE permission on Account

`CanTheUser.create(new Account());`

or

`CanTheUser.create(accountList);`

Check for READ permission on the Account object

`CanTheUser.read(new Account());`

or

`CanTheUser.read(accountList);`

Check for EDIT permissions on the Contact object

`new CanTheUser.edit(new Contact());`

or

`new CanTheUser.edit(contactList);`

Check for DELETE permissions on Contact object

`new CanTheUser.destroy(new Contact());`

or

`new CanTheUser.destroy(contactList);`

#### FLS Checks

FLS checks are based on a given Object, Field and a calling-method-name implied FLSType enum - with values of `Accessible` and `Updatable`

For instance, to check if the current user has access to update the `TradeStyle` field on the Account object, you'd call

`CanTheUser.flsUpdatable('Account', 'TradeStyle');`

Likewise, to check for accessibility use:

`CanTheUser.flsAccessible('Account', 'TradeStyle');`

### Safely Examples

Like CanTheUser, Safely is intended to be clear, succinct and largely self-documenting through intuitive method names. It utilizes a Fluent interface, that allow you to define the behavior of Safely inline with your DML. Examples:

## Acknowledgements

-   [Apex Recipes](https://www.github.com/trailheadapps/apex-recipes)
