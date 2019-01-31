require 'framework/definition/parser'
require 'framework/definition/ast_simplifier'
require 'framework/definition/transpiler'

class Framework
  module Definition
    module Language
      class << self
        ##
        # Generate an anonymous outer class with framework metadata
        # and either one or two nested +EntryData+ classes with field definitions
        # and validations for Invoices and Contracts.
        #
        # params
        # +definition_language+ Framework definition language content to parse
        def generate_framework_class(definition_language)
          slice = parse(definition_language)

          simplified_tree = Framework::Definition::ASTSimplifier.new.apply(slice)
          Transpiler.new(simplified_tree).transpile
        end

        private

        def parse(definition_language)
          Framework::Definition::Parser.new.parse(
            definition_language,
            reporter: Parslet::ErrorReporter::Deepest.new
          )
        rescue Parslet::ParseFailed => e
          puts e.parse_failure_cause.ascii_tree
          raise
        end
      end
    end
  end
end