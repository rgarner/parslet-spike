require 'parslet'

class FrameworkDefinitionParser < Parslet::Parser
  root(:framework)
  rule(:framework) do
    str('Framework') >> space? >> framework_identifier.as(:framework_short_name) >>
      framework_block >>
    space?
  end

  rule(:framework_block) do
    lbrace >> name >> space? >> invoice_fields.maybe.as(:invoice_fields) >> rbrace
  end

  rule(:framework_identifier)   { match(/[A-Z0-9\/]/).repeat(1) >> space? }
  rule(:snake_case_identifier)  { match(/[a-z0-9_]/).repeat(1) >> space? }
  rule(:pascal_case_identifier) { (match(/[A-Z]/) >> match(/[a-z]/).repeat).repeat >> space? }

  rule(:name)                   { str('name') >> space? >> string.as(:name) >> space? }

  rule(:invoice_fields)         { str('Invoices') >> space? >> field_block }
  rule(:field_block)            { lbrace >> total_value_field >> field_defs.maybe >> rbrace >> space? }
  rule(:total_value_field)      { str('total_value_field') >> space? >> string.as(:total_value_field) >> space? }
  rule(:field_defs)             { field_def.repeat(1) >> space? }
  rule(:field_def)              { str('field') >> space? >> pascal_case_identifier.as(:field_name) >> field_options.maybe >> space? }
  rule(:field_options)          { str(',') >> space? >> str('from:') >> space? >> string.as(:source_field) }

  rule(:string) {
    str("'") >> (
      str("'").absent? >> any
    ).repeat.as(:string) >> str("'")
  }

  rule(:space)  { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  rule(:lbrace) { str('{') >> space? }
  rule(:rbrace) { str('}') >> space? }
end

doc = <<~EOF
  Framework CM/OSG/05/3565 {
    name 'My framework name'

    Invoices {
      total_value_field 'Hi'

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