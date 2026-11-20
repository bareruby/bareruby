# frozen_string_literal: true

require_relative "pass/ast_ir/create_bareruby_ast"

module BareRuby
  module Compiler
    class Pipeline
      PASSES = [
        Pass::ASTIR::CreateBareRubyAST
      ].freeze

      attr_reader :result

      def initialize(entry_point)
        @entry_point = entry_point
      end

      def run
        @result = PASSES.reduce(@entry_point) { |input, pass| pass.new(input).run.result }

        self
      end
    end
  end
end
