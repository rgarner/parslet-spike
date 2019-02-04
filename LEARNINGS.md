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
  
## What we've learned

### The good

- Parslet is about as easy as you could make a parser for Ruby devs
- The resulting language does restrict concepts to bare domain language

### The neutral

- Framework definition is still to some extent a quasi-development activity that
  requires testing and iteration. We would need a sandbox.
- Parslet's parser and transforms only help with making an abstract syntax tree (AST).
  We are responsible for working on that tree and creating our anonymous `ActiveModel`-based
  object based on its output. 

### The bad

- The language needs to evolve in lockstep with the business. 
  If business concepts will change continuously this is not a good fit.
- Parser practices (via parslet) are unfamiliar to most devs
- parslet does not help you with good error messages (or at least, we haven't found out 
  how we should do this yet). This is the result of failing to
  spell 'Lookups' correctly:
  ```
  Failed to match sequence ('Framework' SPACE? framework_short_name:FRAMEWORK_IDENTIFIER SPACE? SPACE? FRAMEWORK_BLOCK SPACE?) at line 1 char 26.
  `- Failed to match sequence (SPACE? FRAMEWORK_BLOCK SPACE?) at line 1 char 26.
     `- Failed to match sequence (LBRACE SPACE? METADATA SPACE? SPACE? entry_data:(FIELDS_BLOCKS?) SPACE? lookups:(SPACE? LOOKUPS_BLOCK? SPACE?) RBRACE) at line 26 char 3.
        `- Failed to match sequence ('}' SPACE?) at line 26 char 3.
           `- Expected "}", but got "L" at line 26 char 3.
  ```
 