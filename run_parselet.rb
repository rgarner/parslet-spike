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

  rule(:framework_identifier)   { match(/[A-Z0-9\/]/).repeat(1) }
  rule(:snake_case_identifier)  { match(/[a-z0-9_]/).repeat(1) }
  rule(:pascal_case_identifier) { (match(/[A-Z]/) >> match(/[a-z]/).repeat).repeat }

  rule(:metadata)               { name >> management_charge }
  rule(:name)                   { str('name') >> space? >> string.as(:name) >> space? }
  rule(:management_charge) do
    str('management_charge_rate') >> space? >> (percentage | str('custom')).as(:management_charge_rate) >> space?
  end
  rule(:percentage)             { integer.as(:percentage) >> str('%') >> space? }

  rule(:invoice_fields)         { str('Invoice') >> space? >> field_block }
  rule(:field_block)            { lbrace >> total_value_field >> field_defs.maybe >> rbrace >> space? }
  rule(:total_value_field)      { str('total_value_field') >> space? >> string.as(:total_value_field) >> space? }
  rule(:field_defs)             { field_def.repeat }
  rule(:field_def)              { str('field') >> space? >> pascal_case_identifier.as(:field) >> field_options.maybe >> space? }
  rule(:field_options)          { str(',') >> space? >> str('from:') >> space? >> string.as(:from) }

  rule(:string) {
    str("'") >> (
      str("'").absent? >> any
    ).repeat.as(:string) >> str("'")
  }

  rule(:integer) { match(/[0-9]/).repeat }

  rule(:space)  { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  rule(:lbrace) { str('{') >> space? }
  rule(:rbrace) { str('}') >> space? }
end

doc = <<~EOF
  Framework CM/OSG/05/3565 {
    name 'My framework name'
    management_charge_rate 1%

    Invoice {
      total_value_field 'Total Cost or Something'

      field FrankZappa
      field SarahConnor, from: 'The Terminator'
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

class SomeTransform < Parslet::Transform
  rule(:string => simple(:s))      { String(s) }
  rule(:percentage => simple(:i) ) { BigDecimal(i) }
end

t = SomeTransform.new
pp t.apply(slice)