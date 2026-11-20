# frozen_string_literal: true

require "prism"
require_relative "../../../ast_ir/bareruby_ast"
require_relative "bareruby_ast_builder/parse_tree"

module BareRuby
  module Compiler
    module Pass
      module ASTIR
        class CreateBareRubyAST
          class BareRubyASTBuilder
            attr_reader :entry_point

            def entry_point=(entry_point)
              @entry_point = entry_point
              @brast = nil
            end

            def brast
              @brast ||= begin
                bareruby_ast = Compiler::ASTIR::BareRubyAST.new
                program_node = Prism.parse_file(@entry_point).value
                parse_tree = ParseTree.new(bareruby_ast, @entry_point, program_node)
                bareruby_ast.add_source(parse_tree.root_node)
                bareruby_ast
              end
            end
          end
        end
      end
    end
  end
end
