# frozen_string_literal: true

require "prism"
require_relative "../ir/bareruby_ast"

module BareRuby
  module Compiler
    module Pass
      class BareRubyAstGenerator
        FORWARDING = :"..."

        attr_reader :result

        def initialize(paths)
          @paths = paths
        end

        def run
          @result = BareRubyAST.new
          @paths.each do |path|
            @path = path
            parse_result = Prism.parse_file(path)
            raise Error, "#{path}: #{parse_result.errors.first.message}" if parse_result.failure?

            @result.add_file(path, read_statements(parse_result.value.statements))
          end
          self
        end

        private

        def read_statements(node) = node ? node.body.map { read(it) } : []

        def read(node)
          span = span_of(node)
          case node
          when Prism::ModuleNode then @result.create_module_definition(node.name, read_statements(node.body), span)
          when Prism::ClassNode then @result.create_class_definition(node.name, read_statements(node.body), span)
          when Prism::DefNode then read_method_definition(node, span)
          when Prism::CallNode then read_call(node, span)
          else read_expression(node, span)
          end
        end

        def read_expression(node, span)
          case node
          when Prism::LocalVariableWriteNode then @result.create_local_write(node.name, read(node.value), span)
          when Prism::LocalVariableOperatorWriteNode then read_operator_write(node, span)
          when Prism::ArrayNode then @result.create_array(node.elements.map { read(it) }, span)
          when Prism::SelfNode then @result.create_self(span)
          else read_control(node, span)
          end
        end

        def read_control(node, span)
          case node
          when Prism::WhileNode then @result.create_while(read(node.predicate), read_statements(node.statements), span)
          when Prism::AndNode then @result.create_and(read(node.left), read(node.right), span)
          when Prism::ParenthesesNode then read(node.body.body.last)
          else read_literal(node, span)
          end
        end

        def read_operator_write(node, span)
          call = @result.create_call(@result.create_local(node.name, span), node.binary_operator, [read(node.value)],
                                     span)
          @result.create_local_write(node.name, call, span)
        end

        def read_method_definition(node, span)
          parameters = node.parameters ? node.parameters.requireds.map(&:name) : []
          parameters << FORWARDING if node.parameters&.keyword_rest.is_a?(Prism::ForwardingParameterNode)
          @result.create_method_definition(node.name, parameters, read_statements(node.body), span)
        end

        def read_call(node, span)
          receiver = node.receiver && read(node.receiver)
          arguments = node.arguments ? node.arguments.arguments.map { read(it) } : []
          @result.create_call(receiver, node.name, arguments, span)
        end

        def read_literal(node, span)
          case node
          when Prism::ConstantReadNode, Prism::LocalVariableReadNode, Prism::ForwardingArgumentsNode
            read_reference(node, span)
          when Prism::TrueNode, Prism::FalseNode then @result.create_boolean(node.is_a?(Prism::TrueNode), span)
          when Prism::IntegerNode then @result.create_integer(node.value, span)
          when Prism::NilNode then @result.create_nil(span)
          when Prism::SymbolNode then @result.create_symbol(node.unescaped.to_sym, span)
          when Prism::KeywordHashNode, Prism::HashNode then read_hash(node, span)
          else raise Error, "#{@path}:#{node.location.start_line}: unsupported syntax #{node.type}"
          end
        end

        def read_reference(node, span)
          case node
          when Prism::ConstantReadNode then @result.create_constant(node.name, span)
          when Prism::LocalVariableReadNode then @result.create_local(node.name, span)
          else @result.create_forwarding(span)
          end
        end

        def read_hash(node, span)
          @result.create_hash(node.elements.map { [read(it.key), read(it.value)] }, span)
        end

        def span_of(node)
          location = node.location
          @result.create_span(@path,
                              { offset: location.start_offset, line: location.start_line,
                                column: location.start_column },
                              { offset: location.end_offset, line: location.end_line, column: location.end_column })
        end
      end
    end
  end
end
