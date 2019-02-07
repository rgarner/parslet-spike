require 'forwardable'

class Framework
  module Definition
    module AST
      ##
      # A decorator for a plain old +Hash+ containing an AST.
      # Contains a bit of syntactic sugar to make the +Transpiler+
      # look less verbose.
      class Presenter
        extend Forwardable

        attr_accessor :ast
        def_delegators :ast, :[], :dig

        def initialize(ast)
          self.ast = ast
        end

        def field_defs(entry_type)
          ast.dig(:entry_data, "#{entry_type}_fields".to_sym)
        end

        def field_by_name(entry_type, name)
          field_defs(entry_type).find { |f| f[:field] == name }
        end

        def lookup_values(lookup_name)
          ast.dig(:lookups, lookup_name)
        end
      end
    end
  end
end