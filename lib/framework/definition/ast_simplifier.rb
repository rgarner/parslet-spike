require 'bigdecimal'

class Framework
  module Definition
    ##
    # Takes the 'hash of slices' output of +Framework::Definition::Transpiler+
    # and simplifies it by rewriting portions.
    #
    # Mostly just reduces over-complicated type nodes and
    # casts the strings to their associated types, but also assumes that fields
    # without a type are Strings to simplify transpilation.
    class ASTSimplifier < Parslet::Transform
      # Fields without a type are always treated as a String
      rule(field: simple(:field), from: simple(:from)) do |dict|
        dict[:type] = 'String'
        dict
      end

      # Type casts from strings
      rule(string: simple(:s))                 { String(s) }
      rule(percentage: { float: simple(:i) })  { BigDecimal(i) }
    end
  end
end
