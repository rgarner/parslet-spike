require 'spec_helper'
require 'framework/definition/language'

##
# An integration test of the +Parser+, the +AST::Simplifier+
# and the +Transpiler+. It's not very big because the spike didn't start
# here (it started with run_parslet.rb), but this spec
# should probably drive development in a real-world scenario
# and in preference to transpiler_spec.rb - see comments there
# for why
describe Framework::Definition::Language do
  describe '.generate_framework_class' do
    let(:language) { Framework::Definition::Language }
    let(:logger)   { spy('Logger') }

    subject(:klass) { language.generate_framework_class(content, logger) }

    context 'the content is invalid' do
      let(:content) { 'Framework NotValid {}' }
      it 'logs and raises an error' do
        expect { language.generate_framework_class(content, logger) }.to raise_error(
          Parslet::ParseFailed, /Failed to match sequence/
        )
        expect(logger).to have_received(:error)
      end
    end

    # Our largest integration test
    context 'the content represents as many use cases as possible' do
      let(:content) do
        <<~FDL
          Framework RM3786 {
            Name 'Minimally valid'
            ManagementChargeRate 1.5%

            InvoiceFields {
              TotalValue    from 'Total Spend'
              UnitOfMeasure from 'Unit of Measure'
              LotNumber     from 'Lot Number'

              ProductGroup from 'Service Provided' depends_on LotNumber {
                '1' -> Lot1Services,
                '2' -> Lot2Services
              }
            }

            Lookups {
              UnitOfMeasure [
                'Day'
                'Each'
              ]

              Lot1Services [
                'You’ll like it'
                'Not a lot'
              ]

              Lot2Services [
                '2: You’ll like it'
                '2: Not a lot'
              ]
            }
          }
        FDL
      end
      it 'has the framework_short_name' do
        expect(klass.framework_short_name).to eql('RM3786')
      end
      it 'has the framework_name' do
        expect(klass.framework_name).to eql('Minimally valid')
      end

      describe 'The invoice fields' do
        subject(:invoices_class) { klass::Invoices }

        it 'validates inclusion for the UnitOfMeasure case insensitively' do
          expect(invoices_class.validators).to include(
            an_object_having_attributes(
              class: CaseInsensitiveInclusionValidator,
              attributes: ['UnitOfMeasure'],
              options: { in: %w[Day Each] }
            )
          )
        end

        it 'validates the ProductGroup according to the field "Lot Number" '\
           'from the sheet' do
          expect(invoices_class.validators).to include(
            an_object_having_attributes(
              class: DependentFieldInclusionValidator,
              attributes: ['ProductGroup'],
              options: {
                parent: 'Lot Number',
                in: {
                  'Lot Number' => {
                    '1' => ['You’ll like it', 'Not a lot'],
                    '2' => ['2: You’ll like it', '2: Not a lot']
                  }
                }
              }
            )
          )
        end
      end
    end
  end
end