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
  end
end