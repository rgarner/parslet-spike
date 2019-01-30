require 'parslet'
require 'bigdecimal'

class FrameworkDefinitionParser < Parslet::Parser
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

  rule(:framework_identifier)   { match(%r{[A-Z0-9/]}).repeat(1) }
  rule(:pascal_case_identifier) { (match(/[A-Z]/) >> match(/[a-z]/).repeat).repeat(1) }

  rule(:metadata)               { name >> management_charge }
  rule(:name)                   { str('Name') >> spaced(string.as(:name)) }
  rule(:management_charge)      { (str('ManagementChargeRate') >> spaced(percentage)).as(:management_charge_rate) }
  rule(:percentage)             { float.as(:percentage) >> str('%') }

  rule(:fields_blocks)          { (invoice_fields >> contract_fields.maybe) | (contract_fields >> invoice_fields.maybe) }
  rule(:invoice_fields)         { (str('InvoiceFields') >> spaced(field_block)).as(:invoice_fields) }
  rule(:contract_fields)        { (str('ContractFields') >> spaced(field_block)).as(:contract_fields) }
  rule(:field_block)            { braced(field_defs) }
  rule(:field_defs)             { field_def.repeat(1) }
  rule(:field_def)              { pascal_case_identifier.as(:field) >> spaced(typedef.maybe.as(:type) >> field_source) }
  rule(:field_source)           { spaced(str('from')) >> string.as(:from) >> spaced(optional.as(:optional).maybe) }
  rule(:typedef)                { str('Integer') | str('String') | str('Decimal') | str('Date') | str('Boolean') }
  rule(:optional)               { str('optional') }

  rule(:string) {
    str("'") >> (
      str("'").absent? >> any
    ).repeat.as(:string) >> str("'")
  }

  rule(:integer) { match(/[0-9]/).repeat }
  rule(:float)   { integer >> (str('.') >> match('[0-9]').repeat(1)).as(:float) >> space? }

  rule(:space)  { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  rule(:lbrace) { str('{') >> space? }
  rule(:rbrace) { str('}') >> space? }

  def spaced(atom)
    space? >> atom >> space?
  end

  def braced(atom)
    lbrace >> atom >> rbrace
  end
end

# InvoiceFields specified in PascalCase.
# Each field is a known destination with a known type, so type annotations are
# not necessary.
# Custom validators and coercions to deal with data quality issues will be
# applied automatically.
# Where fields are of unknown type, String is assumed.
doc = <<~EOF
  Framework CM/OSG/05/3565 {
    Name                 'Laundry Services - Wave 2'
    ManagementChargeRate 1.5%

    ContractFields {
      TotalValue from 'Total Spend'
    }

    InvoiceFields {
      TotalValue  from 'Total Spend'

      CustomerURN from 'Customer URN'
      LotNumber   from 'Tier Number'
      ServiceType from 'Service Type'
      SubType     from 'Sub Type'

      UnitPrice Decimal from 'Price per Unit' optional
    }
  }
EOF

FrameworkDefinitionParser.new.pascal_case_identifier.parse('FrankZappa')

begin
  slice = FrameworkDefinitionParser.new.parse(doc, reporter: Parslet::ErrorReporter::Deepest.new)
  pp slice
rescue Parslet::ParseFailed => e
  puts e.parse_failure_cause.ascii_tree
end

puts '*******'

class SimplifyHashTransform < Parslet::Transform
  rule(string: simple(:s))                 { String(s) }
  rule(percentage: { float: simple(:i) })  { BigDecimal(i) }
end

t = SimplifyHashTransform.new
pp t.apply(slice)