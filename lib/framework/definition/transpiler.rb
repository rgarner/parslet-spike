# frozen_string_literal: true
require 'active_model'
require 'framework/definition'
require 'framework/definition/entry_data'

class Framework
  module Definition
    class Transpiler
      def initialize(ast)
        @ast = ast
      end

      def field_defs(entry_type)
        @ast.dig(:entry_data, "#{entry_type}_fields".to_sym)
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
          _field_defs      = transpiler.field_defs(entry_type)
          _total_value_def = _field_defs.find { |f| f[:name] == 'TotalValue' }

          total_value_field _total_value_def[:from]

          _field_defs.each do |field_def|
            field(
              field_def[:name] || field_def[:from], field_def[:type],
              exports_to: field_def[:from]
            )
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
          klass.const_set('Invoices', entry_data_class(:invoice)) if field_defs(:invoice)
          klass.const_set('Contracts', entry_data_class(:contract)) if field_defs(:contract)
        end
      end
    end
  end
end
