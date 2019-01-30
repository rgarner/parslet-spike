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

      def invoices?
        @ast.dig(:entry_data, :invoice_fields)
      end

      def contracts?
        @ast.dig(:entry_data, :contract_fields)
      end

      def invoices_class
        @invoices_class ||= Class.new(EntryData) do
        end
      end

      def contracts_class
        @contracts_class ||= Class.new(EntryData) do
        end
      end

      def compile
        ast = @ast # method-local binding required for Class.new blocks

        @klass ||= Class.new(Base) do
          framework_name       ast[:name]
          framework_short_name ast[:framework_short_name]
        end

        @klass.const_set('Invoices', invoices_class) if invoices?
        @klass.const_set('Contracts', contracts_class) if contracts?

        @klass
      end
    end
  end
end
