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
            when :constant_path then infer_constant_path(node, *children)
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
            return infer_if(*@brast.children_of(node), scope) if @brast.node_type(node) == :if

            condition = @inferrer.conditions.logical(node, scope).first
            left, right = @result.children_of(condition)
            left_type = @result.type_of(left)
            return condition unless left_type == :nil || @result.nilable?(left_type)

            @result.create_logical(@brast.node_type(node), left, right)
          end

          def infer_if(condition_node, consequent_node, alternative_node, scope)
            flow = @inferrer.flow
            condition, true_env, false_env = @inferrer.conditions.infer(condition_node, scope)
            consequent, consequent_env = flow.branch(scope, true_env) { @inferrer.infer(consequent_node, scope) }
            alternative, alternative_env = flow.branch(scope, false_env) { @inferrer.infer(alternative_node, scope) }
            scope[:env] = flow.merge(scope, consequent_env, alternative_env)
            @result.create_if(condition, consequent, alternative)
          end

          def infer_constant_path(node, parent, name)
            owner = @brast.children_of(parent).first
            row = @definitions.native_constant(owner, name)
            @definitions.error(node, "uninitialized constant #{owner}::#{name}") unless row

            @result.create_native_call("BareRuby::#{owner}", row, nil, [])
          end

          def infer_local_write(name, value_node, scope)
            value = @inferrer.infer(value_node, scope)
            @inferrer.flow.assign(scope, name, @result.type_of(value))
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
