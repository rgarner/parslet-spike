require 'spec_helper'
require 'framework/definition/language'

##
# An integration test of the +Parser+, the +Transpiler+
# and the +ASTSimplifier+
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

    context 'the content is minimally valid' do
      let(:content) do
        <<~FDL
          Framework RM3786 {
            Name 'Minimally valid'
            ManagementChargeRate 1.5%
          }
        FDL
      end
      it 'has the framework_short_name' do
        expect(klass.framework_short_name).to eql('RM3786')
      end
      it 'has the framework_name' do
        expect(klass.framework_name).to eql('Minimally valid')
      end
    end
  end
end