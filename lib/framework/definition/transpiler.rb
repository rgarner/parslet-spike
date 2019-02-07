# frozen_string_literal: true
require 'active_model'
require 'framework/definition'
require 'framework/definition/entry_data'
require 'framework/definition/AST/presenter'

require 'validators/case_insensitive_inclusion_validator'
require 'validators/dependent_field_inclusion_validator'

class Framework
  module Definition
    class Transpiler
      attr_reader :ast

      def initialize(ast)
        @ast = AST::Presenter.new(ast)
      end

      ##
      # Generate an +EntryData+ child class for a given entry_type
      # +entry_type+ one of :invoices, :contracts
      def entry_data_class(entry_type)
        transpiler = self # method-local binding to be available in Class.new block

        Class.new(Framework::Definition::EntryData) do
          define_singleton_method :model_name do
            entry_type.to_s.capitalize.singularize
          end

          # invoice_fields or contract_fields
          _field_defs      = transpiler.ast.field_defs(entry_type)
          _total_value_def = _field_defs.find { |f| f[:field] == 'TotalValue' }

          total_value_field _total_value_def[:from]

          _field_defs.each do |field_def|
            _name    = field_def[:field] || field_def[:from]
            _type    = field_def[:type]
            _options = { presence: true }.tap do |options|
              options[:exports_to] = field_def[:from]
              transpiler.add_lookup_validation(options, field_def, entry_type)
            end.compact

            field _name, _type, _options
          end
        end
      end

      ##
      # Transpile an anonymous class from an abstract syntax tree produced
      # by +Framework::Definition::Parser+ which corresponds to the
      # internal DSL
      def transpile
        ast = @ast # method-local binding required for Class.new blocks

        @klass ||= Class.new(Framework::Definition::Base) do
          framework_name       ast[:name]
          framework_short_name ast[:framework_short_name]
        end.tap do |klass|
          klass.const_set('Invoices', entry_data_class(:invoice)) if ast.field_defs(:invoice)
          klass.const_set('Contracts', entry_data_class(:contract)) if ast.field_defs(:contract)
        end
      end

      def add_lookup_validation(options, field_def, entry_type)
        # Always use a case_insensitive_inclusion validator if
        # there's a lookup with the same name as the field
        lookup_values = @ast.lookup_values(field_def[:field])
        options[:case_insensitive_inclusion] = { in: lookup_values } if lookup_values

        # Add a dependent_field_inclusion validator if there's a field
        # whose changing value influences the inclusion list.
        # We should review why we need both and also look at the naming
        # +dependent_field_inclusion+ - perhaps think about +varies_by+
        # since that would make more sense in the FDL
        depends_on = field_def[:depends_on] || return

        dependent_field_def = @ast.field_by_name(
          entry_type, depends_on[:dependent_field]
        )

        # Our dependencies are value => lookup_name e.g. { 'Lot 1' => 'Lot1Values' } -
        # replace the lookup_name with the real array of values here e.g.
        # -> { 'Lot 1' => ['Value 1', 'Value 2'] }
        acceptable_values_mapping = depends_on[:values].transform_values do |lookup_name|
          @ast.lookup_values(lookup_name)
        end
        options[:dependent_field_inclusion] = {
          parent: dependent_field_def[:from],
          in: {
            dependent_field_def[:from] => acceptable_values_mapping
          }
        }
      end
    end
  end
end
