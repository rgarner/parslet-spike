# parslet-spike

Figure out what we can do with [parslet](http://kschiess.github.io/parslet/) and establish some framework definition principles.
Just run `./run_parslet.rb`, which has everything in it.

## Nascent language documentation

Framework definitions let you define your framework, its metadata, and all the product table
lookups you need to validate within lists.

A framework definition looks a bit like this:

```
 Framework CM/OSG/05/3565 {
   Name                 'Laundry Services - Wave 2'
   ManagementChargeRate 1.5%

   InvoiceFields {
     TotalValue  from 'Total Spend'

     CustomerURN from 'Customer URN'
     LotNumber   from 'Tier Number'
     ServiceType from 'Service Type'
     SubType     from 'Sub Type'

     UnitPrice from 'Price per Unit' optional
   }
 } 
```

The framework is defined in a `Framework` block along with its identifier or short name. 

## Metadata

- `Name` is required as a string. Strings are always single-quoted.
- `ManagementChargeRate` is required as a percentage.

## Fields

Fields are declared inside an `InvoiceFields` or `ContractFields` block. There should be
at least one of these, and at most one of each.

Fields are declared by their data warehouse name, which is in `PascalCase`. 

They should be defined in the order they will appear in the customer template, so even fields
that are always required must be mentioned as this will dictate order should we generate
templates from these definitions.

To declare a field, use the form

```
    <WarehouseFieldName> [Type] [from '<Template Field>'] [optional] 
```

There are Known and Unknown fields. 

### Known Fields

Known fields have a known type and meaning. It isn't necessary to declare a type when 
referencing a Known Field, because its type is already known and its meaning understood.
Using a Known Field often means that it will be validated in a specific way.

- `TotalValue` is required and is always validated as a decimal value.
- `CustomerURN` is a required integer URN and will always be validated against the list of
  customer URNs.
- `InvoiceDate` is always a validated date
- `LotNumber` is always a number

### Unknown fields

Unknown fields are fields with a name that are framework-specific. If you don't specify a type,
the field will be assumed to be a String.

### Field Types

Fields are assumed to be of `String` type by default. Here are all the types:

- `String` – passed through with no validation
- `Date` – coerced into Date form and output later as ISO8601
- `Integer` – validated as an integer, but treated as zero for some special values `TODO`
- `Decimal` – validated as a decimal number
- `Boolean` – validated as true or false

### The `from` specifier

The `from` specifier tells RMI which column to get the value from in the template's worksheet.
For example:

`LotNumber from 'Tier Number'`

### The `optional` specifier

Fields are assumed to be mandatory unless they are marked `optional`. Mandatory fields
trigger a validation error when they are absent.

Fields with the `optional` specifier have values that are only sometimes present. 
When they are absent, it does not cause a validation failure. The export CSV receives an 
empty value.

For example:

`UnitPrice from 'Price per Unit' optional`