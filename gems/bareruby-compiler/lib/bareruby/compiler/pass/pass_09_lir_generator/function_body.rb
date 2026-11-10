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
          end

          def lower_statements(nodes, return_type)
            nodes.each_with_index.flat_map do |node, index|
              value = lower(node)
              last = index == nodes.size - 1 && return_type != :nil
              statement = last ? @result.create_return(value) : @result.create_expression_statement(value)
              @prelude.slice!(0..) + [statement]
            end
          end

          private

          def lower(node)
            children = @tast.children_of(node)
            case @tast.node_type(node)
            when :native_call then lower_native_call(*children)
            when :method_call then lower_method_call(*children)
            when :new_instance then lower_new_instance(*children)
            when :local then @result.create_literal(@names.variable_name(children.first))
            when :boolean, :integer then @result.create_literal(children.first.to_s)
            end
          end

          def lower_native_call(namespace, row, receiver, arguments)
            hidden = []
            hidden << (receiver ? lower(receiver) : self_literal) if row[:parameters].key?(:self)
            @result.create_call("#{namespace}::#{row[:function]}", hidden + arguments.map { lower(it) })
          end

          def lower_method_call(function, receiver, arguments)
            hidden = []
            hidden << (receiver ? lower(receiver) : self_literal) if @names.instance_method?(function)
            hidden << temporary(function[:allocates]) if function[:allocates]
            @result.create_call(@names.function_name(function), hidden + arguments.map { lower(it) })
          end

          def lower_new_instance(initializer, arguments)
            storage = @result.create_literal("storage")
            call = @result.create_call(@names.function_name(initializer), [storage] + arguments.map { lower(it) })
            @prelude << @result.create_expression_statement(call)
            storage
          end

          def temporary(class_name)
            name = "temporary#{@temporaries += 1}"
            @prelude << @result.create_variable_definition("BareRuby::#{class_name}", name)
            @result.create_address(name)
          end

          def self_literal = @result.create_literal("self")
        end
      end
    end
  end
end
