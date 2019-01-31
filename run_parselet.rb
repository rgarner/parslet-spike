$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'parslet'
require 'bigdecimal'
require 'framework/definition/parser'

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

      Decimal Additional8 from 'Somewhere'

      Decimal 'Price per Unit' optional

      Decimal 'Invoice Line Product / Service Grouping'
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

class SimplifyHashTransform < Parslet::Transform
  # Fields without a type are always treated as a String
  rule(field: simple(:field), from: simple(:from)) do |dict|
    dict[:type] = 'String'
    dict
  end

  # Type casts from strings
  rule(string: simple(:s))                 { String(s) }
  rule(percentage: { float: simple(:i) })  { BigDecimal(i) }
end

t = SimplifyHashTransform.new
pp t.apply(slice)