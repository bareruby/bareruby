# frozen_string_literal: true

require_relative "create_bareruby_ast/bareruby_ast_builder"

module BareRuby
  module Compiler
    module Pass
      module ASTIR
        class CreateBareRubyAST
          attr_reader :result

          def initialize(entry_point)
            @entry_point = entry_point
          end

          def run
            brast_builder = BareRubyASTBuilder.new
            brast_builder.entry_point = @entry_point
            @result = brast_builder.brast

            self
          end
        end
      end
    end
  end
end
