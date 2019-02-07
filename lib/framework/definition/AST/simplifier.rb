require 'bigdecimal'

class Framework
  module Definition
    module AST
      ##
      # Takes the 'hash of slices' output of +Framework::Definition::Transpiler+
      # and simplifies it by rewriting portions.
      #
      # Mostly just reduces over-complicated type nodes and
      # casts the strings to their associated types, but also assumes that fields
      # without a type are Strings to simplify transpilation.
      class Simplifier < Parslet::Transform
        TYPES = {
          'Integer' => :integer,
          'String' => :string,
          'Decimal' => :decimal,
          'Date' => :date,
          'Boolean' => :boolean
        }.freeze

        # Fields without a type are always treated as a String
        rule(field: simple(:field), from: simple(:from)) do |dict|
          dict[:type] = :string
          dict
        end

        # Type casts from strings
        rule(string: simple(:s))                 { String(s) }
        rule(percentage: { float: simple(:i) })  { BigDecimal(i) }
        rule(type: simple(:t))                   { TYPES.fetch(t.to_s) }

        # We shouldn't be using +subtree+. It makes things like lists of lists
        # impossible for example, by preventing rule recursion, but it works for this use case
        rule(lookups_list: subtree(:list)) do
          list.each_with_object({}) do |lookup, result|
            result[lookup[:lookup_name]] = lookup[:values]
          end
        end

        rule(key: simple(:key), value: simple(:value)) { { key => value } }
        # We shouldn't be using +subtree+ here. If we ever wanted to implement
        # a dict with more than one level, this is a career-limiting move.
        # It's also quick and gets us over the spike line.
        rule(dict: subtree(:dict)) do
          dict.each_with_object({}) do |kv, result|
            # Always a hash with one key/value pair
            result[kv.keys.first] = kv.values.first
          end
        end
      end
    end
  end
end
