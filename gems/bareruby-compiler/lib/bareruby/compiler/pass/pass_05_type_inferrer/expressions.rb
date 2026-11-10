# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        class Expressions
          ARRAY_PRIMITIVES = %i[array_length array_element].freeze

          def initialize(bareruby_ast, typed_ast, definitions, inferrer)
            @brast = bareruby_ast
            @result = typed_ast
            @definitions = definitions
            @inferrer = inferrer
          end

          def array_primitive?(node) = ARRAY_PRIMITIVES.any? { @definitions.primitive_call?(node, it) }

          def infer(node, scope)
            children = @brast.children_of(node)
            case @brast.node_type(node)
            when :self then @result.create_self(scope[:self])
            when :local_write then infer_local_write(*children, scope)
            when :while then infer_while(*children, scope)
            when :and then @result.create_and(*children.map { @inferrer.infer(it, scope) })
            when :array then infer_array(node, children.first, scope)
            else @definitions.error(node, "unsupported expression #{@brast.node_type(node)}")
            end
          end

          def infer_array_primitive(node, scope)
            _receiver, name, arguments = @brast.children_of(node)
            return @result.create_array_length(scope[:self]) if name == :array_length

            @result.create_array_element(scope[:self], @inferrer.infer(arguments.first, scope))
          end

          private

          def infer_local_write(name, value_node, scope)
            value = @inferrer.infer(value_node, scope)
            scope[:locals][name] ||= @result.type_of(value)
            @result.create_local_write(name, value)
          end

          def infer_while(condition, body, scope)
            @result.create_while(@inferrer.infer(condition, scope), body.map { @inferrer.infer(it, scope) })
          end

          def infer_array(node, element_nodes, scope)
            elements = element_nodes.map { @inferrer.infer(it, scope) }
            types = elements.map { @result.type_of(it) }.uniq
            @definitions.error(node, "unsupported array elements (#{types.join(", ")})") unless types.size == 1

            @result.create_array(elements, types.first)
          end
        end
      end
    end
  end
end
