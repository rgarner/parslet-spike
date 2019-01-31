require 'parslet'

class Framework
  module Definition
    class Parser < Parslet::Parser
      ##
      # Explicit field types used when a field is not a +known_field+
      module Type
        INTEGER = 'Integer'.freeze
        STRING  = 'String'.freeze
        DECIMAL = 'Decimal'.freeze
        DATE    = 'Date'.freeze
        BOOLEAN = 'Boolean'.freeze
      end

      ##
      # General structure
      root(:framework)
      rule(:framework) do
        str('Framework') >>
          spaced(framework_identifier.as(:framework_short_name)) >>
          spaced(framework_block)
      end

      rule(:framework_block) do
        braced(
          spaced(metadata) >>
            spaced(fields_blocks.maybe.as(:entry_data))
        )
      end

      ##
      # Identifiers
      rule(:framework_identifier)   { match(%r{[A-Z0-9/]}).repeat(1) }
      rule(:pascal_case_identifier) { (match(/[A-Z]/) >> match(/[a-z]/).repeat).repeat(1) }

      ##
      # Things we require and that without will raise a parser error.
      # Not certain whether these should be here or in the +Transpiler+, where
      # better error messages can be given if things are missing
      rule(:metadata)               { name >> management_charge }
      rule(:name)                   { str('Name') >> spaced(string.as(:name)) }
      rule(:management_charge)      { (str('ManagementChargeRate') >> spaced(percentage)).as(:management_charge_rate) }
      rule(:percentage)             { float.as(:percentage) >> str('%') }

      ##
      # Rules for field definition collections
      rule(:fields_blocks)          { (invoice_fields >> contract_fields.maybe) | (contract_fields >> invoice_fields.maybe) }
      rule(:invoice_fields)         { (str('InvoiceFields') >> spaced(field_block)).as(:invoice_fields) }
      rule(:contract_fields)        { (str('ContractFields') >> spaced(field_block)).as(:contract_fields) }
      rule(:field_block)            { braced(field_defs) }
      rule(:field_defs)             { field_def.repeat(1) }

      ##
      # Rules for an individual field
      rule(:field_def)              { known_field | additional_field | unknown_field }
      rule(:known_field)            { pascal_case_identifier.as(:field) >> field_source }
      rule(:additional_field)       { spaced(typedef).as(:type) >> (str('Additional') >> match(/[1-8]/)).as(:field) >> field_source }
      rule(:unknown_field)          { spaced(typedef).as(:type) >> field_source }
      rule(:field_source)           { spaced(str('from')).maybe >> string.as(:from) >> spaced(optional.as(:optional).maybe) }
      rule(:typedef)                { str(Type::INTEGER) | str(Type::STRING) | str(Type::DECIMAL) | str(Type::DATE) | str(Type::BOOLEAN) }
      rule(:optional)               { str('optional') }

      ##
      # Primitive types
      rule(:string) {
        str("'") >> (
          str("'").absent? >> any
        ).repeat.as(:string) >> str("'")
      }

      rule(:integer) { match(/[0-9]/).repeat }
      rule(:float)   { integer >> (str('.') >> match('[0-9]').repeat(1)).as(:float) >> space? }

      ##
      # Spacing and bracing, including helper methods.
      rule(:space)  { match('\s').repeat(1) }
      rule(:space?) { space.maybe }

      rule(:lbrace) { str('{') >> space? }
      rule(:rbrace) { str('}') >> space? }

      ##
      # It is often the case that we need spaces before and after
      # an atom.
      def spaced(atom)
        space? >> atom >> space?
      end

      ##
      # braced(atom1 >> atom 2) reads better than
      # lbrace >> atom 1 >> atom2 >> brace in most situations.
      def braced(atom)
        lbrace >> atom >> rbrace
      end
    end
  end
end