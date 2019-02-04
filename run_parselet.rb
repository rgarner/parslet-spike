$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

# Running this script is good for tinkering with the heredoc in the middle.
# It'll print two hashes – the output of the parser in one, and the
# simplified tree for feeding to a transpiler in the second.
#
# The transpiler isn't in use here right now.

require 'parslet'
require 'bigdecimal'
require 'framework/definition/parser'
require 'framework/definition/ast_simplifier'

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
      Boolean 'Is cromulent'
    }

    InvoiceFields {
      TotalValue  from 'Total Spend'

      CustomerURN from 'Customer URN'
      LotNumber   from 'Tier Number'
      ServiceType from 'Service Type'
      SubType     from 'Sub Type'

      Decimal Additional8 from 'Somewhere'

      Decimal 'Price per Unit' optional

      Decimal 'Invoice Line Product / Service Grouping'
    }

    Lookups {
      UnitOfMeasure [
        'Day'
        'Each'
      ]

      UnitOfBlah [
        'Blah'
        'Blah'
      ]
    }
  }
EOF

Framework::Definition::Parser.new.pascal_case_identifier.parse('FrankZappa')

begin
  slice = Framework::Definition::Parser.new.parse(doc, reporter: Parslet::ErrorReporter::Deepest.new)
  pp slice
rescue Parslet::ParseFailed => e
  puts e.parse_failure_cause.ascii_tree
end

puts '*******'

t = Framework::Definition::ASTSimplifier.new
pp t.apply(slice)