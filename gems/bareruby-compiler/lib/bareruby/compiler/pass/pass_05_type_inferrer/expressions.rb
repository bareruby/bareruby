# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        class Expressions
          ARRAY_PRIMITIVES = %i[array_length array_element array_store pointer_size].freeze

          def initialize(bareruby_ast, typed_ast, definitions, inferrer, pointer_size)
            @brast = bareruby_ast
            @result = typed_ast
            @definitions = definitions
            @inferrer = inferrer
            @pointer_size = pointer_size
          end

          def array_primitive?(node)
            array_new?(node) || ARRAY_PRIMITIVES.any? { @definitions.primitive_call?(node, it) }
          end

          def array_new?(node)
            receiver, name, = @brast.children_of(node)
            @brast.node_type(node) == :call && name == :new && receiver && @brast.children_of(receiver) == [:Array]
          end

          def infer(node, scope)
            children = @brast.children_of(node)
            case @brast.node_type(node)
            when :self then @result.create_self(scope[:self])
            when :local_write then infer_local_write(*children, scope)
            when :while then infer_while(*children, scope)
            when :and, :or, :if then infer_operator(node, scope)
            when :array then infer_array(node, children.first, scope)
            else @definitions.error(node, "unsupported expression #{@brast.node_type(node)}")
            end
          end

          def infer_array_primitive(node, scope)
            _receiver, name, argument_nodes = @brast.children_of(node)
            arguments = argument_nodes.map { @inferrer.infer(it, scope) }
            case name
            when :new then @result.create_array_new(*arguments)
            when :array_length then @result.create_array_length(scope[:self])
            when :array_element then @result.create_array_element(scope[:self], *arguments)
            when :array_store then @result.create_array_store(*arguments)
            when :pointer_size then @result.create_integer(@pointer_size)
            end
          end

          private

          def infer_operator(node, scope)
            operands = @brast.children_of(node).map { @inferrer.infer(it, scope) }
            case @brast.node_type(node)
            when :and then @result.create_and(*operands)
            when :or then @result.create_or(*operands)
            else @result.create_if(*operands)
            end
          end

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
