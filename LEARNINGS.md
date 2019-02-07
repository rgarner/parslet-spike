# Learnings

## Why are we experimenting with making a language?

We already had an internal DSL in Ruby with `Framework::Definition::Base` derivatives,
but that language easily leaks implementation details (at least unless we have strong guidelines)
and leads to the use (or potentially misuse) of Plain Old Ruby.

The current internal DSL must be deployed to define new frameworks. This means 
familiarity with, and security access to,
  - the API repo 
  - the deploy pipeline.
  This should not be an end-user job, although the framework definitions could go in
  their own repo.
  
## Design

### Purpose

The language should:

- Define metadata
- Define validations
- Define the data warehouse destination
- Define the spreadsheet source for fields

### Principles

- Keep it clean. This isn't a programming language; its primary purpose
  is to define, and define clearly
- Avoid repetition. This is going to need to be as terse as we can make it
  without sacrificing readability
- Use conventions from the domain. Types, for example, are always PascalCased
  because the target warehouse fields are PascalCased and the names of these
  fields form a basis for agreement
  
## What we've learned

### The good

- The resulting language does restrict concepts to bare domain language
- We get assurance that a framework is correct – assurance that it would be hard
  to get from anywhere else. Invoice/Contract fields always have at least one field, always
  include a Total Value field, frameworks always have a name and a short name, lookups can't
  have duplicate values, and types are restricted
- We get a choice as to how a framework is made live, where we store the definition.
  and what access is required to make it so. It could be as simple as a field in `frameworks`.
- Having FDL recognises that defining a framework is an iterative process and positions such 
  definition as a quasi-development activity rather than field-filling
- Parslet is about as easy as you could make a parser for Ruby devs

### The neutral

- Framework definition is still to some extent a quasi-development activity that
  requires testing and iteration. We would need a sandbox.
- Parslet's parser and transforms only help with making an abstract syntax tree (AST).
  We are responsible for working on that tree and creating our anonymous `ActiveModel`-based
  object based on its output via the `Transpiler` and whatever secondary post-parse checks
  we need. 

### The bad

- The language needs to evolve in lockstep with the business. 
  If business concepts will change continuously this is not a good fit.
- Parser practices (via parslet) are unfamiliar to most devs
- parslet does not help you with good error messages (we can mitigate this somewhat by
  making the parser smaller and simpler and doing a semantic check later in the pipeline, 
  see "Things we still need to do" below). This is the result of failing to
  spell 'Lookups' correctly:
  ```
  Failed to match sequence ('Framework' SPACE? framework_short_name:FRAMEWORK_IDENTIFIER SPACE? SPACE? FRAMEWORK_BLOCK SPACE?) at line 1 char 26.
  `- Failed to match sequence (SPACE? FRAMEWORK_BLOCK SPACE?) at line 1 char 26.
     `- Failed to match sequence (LBRACE SPACE? METADATA SPACE? SPACE? entry_data:(FIELDS_BLOCKS?) SPACE? lookups:(SPACE? LOOKUPS_BLOCK? SPACE?) RBRACE) at line 26 char 3.
        `- Failed to match sequence ('}' SPACE?) at line 26 char 3.
           `- Expected "}", but got "L" at line 26 char 3.
  ```
 
 ## Things we still need to do
 
 ### Debugging
 
 Find a good way of outputting the class as it would look in Ruby. The anonymous class may behave well 
 but debugging would be harder.
 
 ### Unimplemented things
 
- `optional` fields should `allow_nil: true`
- While we refer to "Known Fields" a lot, we haven't defined them.
  We should define them based on existing `exports_to` targets and 
  [MISO CSV](https://drive.google.com/file/d/1xLAABbqm1JQJhyMaXrqJc4FVpaNHcpGt/view) 
  values. Field types can be any of a Known Field, a Lookup name, or a primitive
  such as `Decimal`
   
 #### Semantic checking and human-readable errors
 
 There needs to be a separate post-parse semantic checking step for errors. At present (where 'FDL' is 
   "Framework Definition Language")the pipeline is:
   ```
     FDL -> parser -> ASTSimplifier -> Transpiler -> Anonymous class
            |
            \ parse errors
   ```
   whereas it could (should) be
   ```
     FDL -> parser -> ASTSimplifier -> Semantic checker -> Transpiler -> Anonymous class
            |                          |
            \ parse errors             \ semantic errors
   ```
   
 #### Example semantic errors
 
 1. Invalid metadata
 ```
 # Presently the parser would reject this but this should not be
 # the parser's job
 Framework RM1234 {
   Blastoise 'Hello'
 }

->
 Line 4: "Blastoise" is not a valid piece of framework metadata
 ```
 
 2. Lookup checking
 ```
    Framework RM1234 {
      ...
      Lookups {
        UnitOfMeasure [
          'Day'
          'Day'            
        ]
      }
    }
 
 ->
 Line 6: Duplicate value "Day" in Lookup UnitOfMeasure
 ```
 
 3. Unknown type of field
 
 ```
   Framework RM1234 {
     ...
     InvoiceFields {
       ...
       Snivey SomeFieldName from 'Some field name'
       ...
     }
   }
  
 ->
 Line 5: Unknown field or lookup type "Snivey"
 ```