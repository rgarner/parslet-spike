require 'spec_helper'
require 'framework/definition/parser'

describe Framework::Definition::Parser do
  subject(:parser) { Framework::Definition::Parser.new }

  describe 'The rules' do
    describe '#framework_identifier' do
      subject { parser.framework_identifier }

      context 'slashed framework names' do
        it { is_expected.to parse('CM/01/23/SG') }
      end

      context 'lower case' do
        it { is_expected.not_to parse('cm/01/23/SG') }
      end

      context 'regular framework names' do
        it { is_expected.to parse('RM3786') }
      end
    end

    describe '#field_def' do
      subject { parser.field_def }

      context 'A known field' do
        it { is_expected.to parse("TotalValue from 'Total Spend'") }
      end

      context 'An additional field' do
        it { is_expected.to parse("Date Additional8 from 'A lovely date'") }

        context 'that is optional' do
          it { is_expected.to parse("Date Additional8 from 'A lovely date' optional") }
        end
      end

      context 'an unknown field' do
        it { is_expected.to parse("Decimal 'Price of fish'") }
      end
    end

    describe '#lookups_block' do
      subject { parser.lookups_block }

      context 'a single lookup with multiple values' do
        it {
          is_expected.to parse(
            <<~FDL
              Lookups {
                UnitOfMeasure [
                  'Day'
                  'Each'
                ]
              }
            FDL
          )
        }
      end
    end
  end
end