# frozen_string_literal: true
require 'active_model'

module Framework
  module Definition
    ##
    # Base class for a framework definition with metadata methods
    class Base
      class << self
        ##
        # E.g. "Rail Legal Services"
        def framework_name(framework_name = nil)
          @framework_name ||= framework_name
        end

        ##
        # E.g. "RM3786"
        def framework_short_name(framework_short_name = nil)
          @framework_short_name ||= framework_short_name
        end

        ##
        # E.g. BigDecimal.new('1.5')
        def management_charge_rate(charge_rate = nil)
          @management_charge_rate ||= charge_rate
        end

        def management_charge(value)
          (value * (management_charge_rate / 100)).truncate(4)
        end

        def for_entry_type(entry_type)
          entry_type == 'invoice' ? self::Invoice : self::Order
        end
      end
    end

    class EntryData
      include ActiveModel::Attributes
      include ActiveModel::Validations

      attr_reader :entry

      def initialize(entry)
        super()
        @entry = entry
        entry.data.each_pair do |param, value|
          next unless attributes.key?(param)

          send("#{param}=", value)
        end
      end

      class << self
        def export_mappings
          @export_mappings ||= {}
        end

        ##
        # E.g. 'Total Cost (ex VAT)'
        def total_value_field(value = nil)
          @total_value_field ||= value
        end

        ##
        # Define a field using an ActiveModel-compatible syntax.
        # This is intended to pass through to ActiveModel::Attributes.attribute,
        # but adds options that we need. Right now that's exports_to.
        def field(*args)
          options = args.extract_options!
          field_name = args.first
          exports_to = options.delete(:exports_to)

          export_mappings[exports_to] = field_name if exports_to

          attribute(*args)
          validates(field_name, options) if options.present?
        end
      end
    end

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
            field ast_field[:name] || ast_field[:from], compiler.type(ast_field[:type])
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
