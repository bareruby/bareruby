# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class LirGenerator
        class FunctionBody
          def initialize(typed_ast, lir, names)
            @tast = typed_ast
            @result = lir
            @names = names
            @prelude = []
            @temporaries = 0
            @arrays = ArrayLowering.new(typed_ast, lir, names, self)
          end

          def lower_statements(nodes, return_type)
            nodes.each_with_index.flat_map do |node, index|
              next lower_while(*@tast.children_of(node)) if @tast.node_type(node) == :while

              value = lower(node)
              last = index == nodes.size - 1 && return_type != :nil
              @prelude.slice!(0..) + (last ? return_statements(value, return_type) : [statement(value)])
            end
          end

          def lower(node)
            return @arrays.lower(node) if ArrayLowering::NODE_TYPES.include?(@tast.node_type(node))

            lower_value(node)
          end

          def temporary(type, values = [])
            name = "temporary#{@temporaries += 1}"
            @prelude << @result.create_variable_definition(type, name, values)
            @result.create_address(name)
          end

          def self_literal = @result.create_literal("self")

          private

          def statement(value) = @result.create_expression_statement(value)

          def return_statements(value, return_type)
            return [@result.create_return(value)] unless return_type in [:array, _]

            result = @result.create_literal("result")
            copy = @result.create_assignment(@result.create_dereference(result), @result.create_dereference(value))
            [statement(copy), @result.create_return(result)]
          end

          def lower_value(node)
            children = @tast.children_of(node)
            case @tast.node_type(node)
            when :native_call then lower_native_call(*children)
            when :method_call then lower_method_call(*children)
            when :new_instance then lower_new_instance(*children)
            when :local then @result.create_literal(@names.variable_name(children.first))
            when :boolean, :integer then @result.create_literal(children.first.to_s)
            else lower_expression(node)
            end
          end

          def lower_expression(node)
            children = @tast.children_of(node)
            case @tast.node_type(node)
            when :self then self_literal
            when :local_write then @result.create_assignment(variable(children.first), lower(children.last))
            when :and then @result.create_binary("&&", *children.map { lower(it) })
            when :if then conditional(*children)
            else @arrays.lower(node)
            end
          end

          def conditional(condition, consequent, alternative)
            @result.create_conditional(truth(condition), lower(consequent), lower(alternative))
          end

          def truth(condition)
            case @tast.type_of(condition)
            when :Bool then lower(condition)
            when :nil then @result.create_binary(",", lower(condition), @result.create_literal("false"))
            else @result.create_binary(",", lower(condition), @result.create_literal("true"))
            end
          end

          def variable(name) = @result.create_literal(@names.variable_name(name))

          def lower_while(condition, body)
            condition = lower(condition)
            @prelude.slice!(0..) + [@result.create_while(condition, lower_statements(body, :nil))]
          end

          def lower_native_call(namespace, row, receiver, arguments)
            hidden = []
            hidden << (receiver ? lower(receiver) : self_literal) if row[:parameters].key?(:self)
            @result.create_call("#{namespace}::#{row[:function]}", hidden + arguments.map { lower(it) })
          end

          def lower_method_call(function, receiver, arguments)
            hidden = []
            hidden << (receiver ? lower(receiver) : self_literal) if @names.instance_method?(function)
            hidden += storages(function)
            @result.create_call(@names.function_name(function), hidden + arguments.map { lower(it) })
          end

          def storages(function)
            storages = []
            storages << temporary(@names.struct_name(function[:allocates])) if function[:allocates]
            return_type = function[:return_type]
            storages << temporary(@names.array_type(return_type.last)) if return_type in [:array, _]
            storages
          end

          def lower_new_instance(initializer, arguments)
            storage = @result.create_literal("storage")
            call = @result.create_call(@names.function_name(initializer), [storage] + arguments.map { lower(it) })
            @prelude << @result.create_expression_statement(call)
            storage
          end
        end
      end
    end
  end
end
