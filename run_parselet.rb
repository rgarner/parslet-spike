require 'parslet'

class FrameworkDefinitionParser < Parslet::Parser
  root(:framework)
  rule(:framework) do
    str('Framework') >> space? >> framework_identifier.as(:framework_short_name)
  end

  rule(:framework_identifier)   { match(/[A-Z0-9\/]/).repeat(1) >> space? }

  rule(:space)  { match('\s').repeat(1) }
  rule(:space?) { space.maybe }
end

doc = <<EOF
Framework CM/OSG/05/3565
EOF

begin
  slice = FrameworkDefinitionParser.new.parse(doc)
  puts slice
rescue Parslet::ParseFailed => e
  puts e.parse_failure_cause.ascii_tree
end