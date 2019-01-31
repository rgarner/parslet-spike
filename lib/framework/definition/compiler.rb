# frozen_string_literal: true
require 'active_model'
require 'framework/definition/base'
require 'framework/definition/entry_data'

module Framework
  module Definition
    class Compiler
      def initialize(ast)
        @ast = ast
      end

      def invoices_fields
        @ast.dig(:entry_data, :invoice_fields)
      end

      def contracts_fields
        @ast.dig(:entry_data, :contract_fields)
      end

      def type(language_type)
        {
          'Integer' => :integer,
          'String' => :string,
          'Decimal' => :decimal,
          'Date' => :date,
          'Boolean' => :boolean
        }.fetch(language_type)
      end

      ##
      # Generate an +EntryData+ child class for a given entry_type
      # +entry_type+ one of :invoices, :contracts
      def entry_data_class(entry_type)
        compiler = self # method-local binding to be available in Class.new block

        Class.new(EntryData) do
          define_singleton_method :model_name do
            entry_type.to_s.capitalize.singularize
          end

          compiler.send("#{entry_type}_fields").each do |ast_field|
            field(
              ast_field[:name] || ast_field[:from],
              compiler.type(ast_field[:type]),
              exports_to: ast_field[:from]
            )
          end
        end
      end

      ##
      # 'Compile' an anonymous class from an abstract syntax tree produced
      # by +Framework::Definition::Parser+ which corresponds to the
      # internal DSL
      def compile
        ast = @ast # method-local binding required for Class.new blocks

        @klass ||= Class.new(Base) do
          framework_name       ast[:name]
          framework_short_name ast[:framework_short_name]
        end.tap do |klass|
          klass.const_set('Invoices', entry_data_class(:invoices)) if invoices_fields
          klass.const_set('Contracts', entry_data_class(:contracts)) if contracts_fields
        end
      end
    end
  end
end
