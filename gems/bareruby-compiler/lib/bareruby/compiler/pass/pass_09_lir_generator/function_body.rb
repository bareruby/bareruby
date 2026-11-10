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
              next lower_while(*@tast.children_of(node)) if @tast.node_type(node) == :while

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
            else lower_expression(node)
            end
          end

          def lower_expression(node)
            children = @tast.children_of(node)
            case @tast.node_type(node)
            when :self then self_literal
            when :local_write then @result.create_assignment(@names.variable_name(children.first), lower(children.last))
            when :and then @result.create_binary("&&", *children.map { lower(it) })
            when :array then lower_array(children.first, @tast.type_of(node).last)
            else lower_array_primitive(node)
            end
          end

          def lower_array_primitive(node)
            case @tast.node_type(node)
            when :array_length then @result.create_member(self_literal, "length")
            when :array_element
              elements = @result.create_member(self_literal, "elements")
              @result.create_element(elements, lower(@tast.children_of(node).first))
            end
          end

          def lower_while(condition, body)
            condition = lower(condition)
            @prelude.slice!(0..) + [@result.create_while(condition, lower_statements(body, :nil))]
          end

          def lower_array(elements, element_type)
            name = "temporary#{@temporaries += 1}"
            @prelude << @result.create_variable_definition(@names.cpp_type(element_type), "#{name}_elements[]",
                                                           elements.map { lower(it) })
            length = @result.create_literal(elements.size.to_s)
            @prelude << @result.create_variable_definition(@names.array_type(element_type), name,
                                                           [length, length, @result.create_literal("#{name}_elements")])
            @result.create_address(name)
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
