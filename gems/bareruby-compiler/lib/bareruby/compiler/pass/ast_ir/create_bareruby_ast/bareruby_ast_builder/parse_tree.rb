# frozen_string_literal: true

require "prism"
require_relative "../../../../ast_ir/bareruby_ast"

module BareRuby
  module Compiler
    module Pass
      module ASTIR
        class CreateBareRubyAST
          class BareRubyASTBuilder
            class ParseTree
              def initialize(bareruby_ast, path, program_node)
                @bareruby_ast = bareruby_ast
                @path = path
                @program_node = program_node
              end

              def root_node
                @root_node ||= begin
                  scope = @bareruby_ast.create_scope(kind: :top_level, variable_parent: nil, lexical_parent: nil)
                  names = @program_node.locals
                  @locals = [names.to_h { [it, @bareruby_ast.declare_local(scope:, name: it, kind: :assignment)] }]
                  statements = @program_node.statements.body.map { node(it) }
                  body = @bareruby_ast.create_body(span: span(@program_node.statements.location), statements:, scope:)
                  @bareruby_ast.create_source_unit(span: span(@program_node.location), path: @path, body:, scope:)
                end
              end

              private

              # rubocop:disable-next Metrics/AbcSize, Metrics/CyclomaticComplexity -- one case covers every Prism node kind
              # rubocop:disable-next Metrics/MethodLength -- one case covers every Prism node kind
              def node(prism_node)
                span = span(prism_node.location)
                case prism_node
                in Prism::NilNode then @bareruby_ast.create_literal(span:, kind: :nil, value: nil)
                # The kinds :true and :false name the literal nodes instead of holding the values.
                in Prism::TrueNode then @bareruby_ast.create_literal(span:, kind: :true, value: nil) # rubocop:disable Lint/BooleanSymbol
                in Prism::FalseNode then @bareruby_ast.create_literal(span:, kind: :false, value: nil) # rubocop:disable Lint/BooleanSymbol
                in Prism::IntegerNode[value:] then @bareruby_ast.create_literal(span:, kind: :integer, value:)
                in Prism::FloatNode
                  @bareruby_ast.create_literal(span:, kind: :float, value: prism_node.slice.delete("_").freeze)
                in Prism::StringNode[unescaped:]
                  @bareruby_ast.create_literal(span:, kind: :string, value: unescaped.b.freeze)
                in Prism::SymbolNode[unescaped:]
                  @bareruby_ast.create_literal(span:, kind: :symbol, value: unescaped.to_sym)
                in Prism::LocalVariableReadNode[name:, depth:]
                  @bareruby_ast.create_local_read(span:, variable: variable(name, depth))
                in Prism::LocalVariableWriteNode[value:]
                  target = local_target(prism_node)
                  @bareruby_ast.create_assignment(span:, target:, value: node(value))
                end
              end

              def variable(name, depth) = @locals[-1 - depth].fetch(name)

              def local_target(prism_node)
                span = span(prism_node.name_loc)
                @bareruby_ast.create_local_target(span:, variable: variable(prism_node.name, prism_node.depth))
              end

              def span(location)
                Compiler::ASTIR::BareRubyAST::Span.new(
                  path: @path,
                  start_offset: location.start_offset, end_offset: location.end_offset,
                  start_line: location.start_line, start_column: location.start_column,
                  end_line: location.end_line, end_column: location.end_column
                )
              end
            end
          end
        end
      end
    end
  end
end
