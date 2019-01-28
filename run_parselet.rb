require 'parslet'

class FrameworkDefinitionParser < Parslet::Parser
  root(:framework)
  rule(:framework) do
    str('Framework') >> space? >> framework_identifier.as(:framework_short_name) >> framework_block >> space?
  end

  rule(:framework_block) { lbrace >> name >> rbrace }

  rule(:framework_identifier)   { match(/[A-Z0-9\/]/).repeat(1) >> space? }
  rule(:snake_case_identifier)  { match(/[a-z0-9_]/).repeat(1) }
  rule(:name)                   { str('name') >> space? >> string.as(:name) >> space? }

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

doc = <<EOF
Framework CM/OSG/05/3565 {
  name 'Thing'
}
EOF

begin
  slice = FrameworkDefinitionParser.new.parse(doc)
  puts slice
rescue Parslet::ParseFailed => e
  puts e.parse_failure_cause.ascii_tree
end