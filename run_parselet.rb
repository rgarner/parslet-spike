require 'parslet'
require 'bigdecimal'

class FrameworkDefinitionParser < Parslet::Parser
  root(:framework)
  rule(:framework) do
    str('Framework') >> space? >> framework_identifier.as(:framework_short_name) >> space? >>
      framework_block >>
    space?
  end

  rule(:framework_block) do
    lbrace >> metadata >> space? >> invoice_fields.maybe.as(:invoice_fields) >> rbrace
  end

  rule(:framework_identifier)   { match(%r{[A-Z0-9/]}).repeat(1) }
  rule(:pascal_case_identifier) { (match(/[A-Z]/) >> match(/[a-z]/).repeat).repeat(1) }

  rule(:metadata)               { name >> management_charge }
  rule(:name)                   { str('Name') >> space? >> string.as(:name) >> space? }
  rule(:management_charge)      { str('ManagementChargeRate') >> space? >> percentage).as(:management_charge_rate) >> space? }
  rule(:percentage)             { float.as(:percentage) >> str('%') >> space? }

  rule(:invoice_fields)         { str('InvoiceFields') >> space? >> field_block >> space? }
  rule(:field_block)            { lbrace >> field_defs >> rbrace }
  rule(:field_defs)             { field_def.repeat(1) }
  rule(:field_def)              { pascal_case_identifier.as(:field) >> field_source >> space? }
  rule(:field_source)           { space? >> str('from') >> space? >> string.as(:from) >> space? >> optional.as(:optional).maybe }
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

    InvoiceFields {
      TotalValue  from 'Total Spend'

      CustomerURN from 'Customer URN'
      LotNumber   from 'Tier Number'
      ServiceType from 'Service Type'
      SubType     from 'Sub Type'

      UnitPrice from 'Price per Unit' optional
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