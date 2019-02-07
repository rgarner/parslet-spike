require 'framework/definition/parser'
require 'framework/definition/ast/simplifier'
require 'framework/definition/transpiler'

require 'pp'

class Framework
  module Definition
    ##
    # The API for generating classes from framework definition language
    module Language
      class << self
        ##
        # Generate an anonymous outer class with framework metadata
        # and either one or two nested +EntryData+ classes with field definitions
        # and validations for Invoices and Contracts.
        #
        # params
        # +definition_language+ Framework definition language content to parse
        def generate_framework_class(definition_language, logger = Logger.new(STDERR))
          slice = parse(definition_language, logger)

          logger.debug(slice.pretty_inspect)
          simplified_tree = Framework::Definition::AST::Simplifier.new.apply(slice)
          Transpiler.new(simplified_tree).transpile
        end

        private

        def parse(definition_language, logger)
          Framework::Definition::Parser.new.parse(
            definition_language,
            reporter: Parslet::ErrorReporter::Deepest.new
          )
        rescue Parslet::ParseFailed => e
          logger.error(e.parse_failure_cause.ascii_tree)
          raise
        end
      end
    end
  end
end