# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class LirGenerator
        class FunctionBody
          def initialize(typed_ast, lir, names, storages)
            @tast = typed_ast
            @result = lir
            @names = names
            @prelude = []
            @temporaries = 0
            @arrays = ArrayLowering.new(typed_ast, lir, names, self)
            @calls = CallLowering.new(typed_ast, lir, names, self)
            @nilables = NilableLowering.new(typed_ast, lir, names, self, storages)
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
            return @calls.lower(node) if CallLowering::NODE_TYPES.include?(@tast.node_type(node))
            return @nilables.lower(node) if NilableLowering::NODE_TYPES.include?(@tast.node_type(node))

            lower_value(node)
          end

          def temporary(type, values = [])
            name = "temporary#{@temporaries += 1}"
            @prelude << @result.create_variable_definition(type, name, values)
            @result.create_address(name)
          end

          def named_temporary(type)
            name = "temporary#{@temporaries += 1}"
            @prelude << @result.create_variable_definition(type, name)
            @result.create_literal(name)
          end

          def self_literal = @result.create_literal("self")

          def hoist(statement) = @prelude << statement

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
            when :local then @nilables.read(children.first, @tast.type_of(node))
            when :boolean, :integer then @result.create_literal(children.first.to_s)
            when :float then @result.create_literal("#{children.first}f")
            when :symbol then @result.create_literal(@result.symbol_id(children.first).to_s)
            when :nil then @result.create_literal("nullptr")
            else lower_expression(node)
            end
          end

          def lower_expression(node)
            children = @tast.children_of(node)
            case @tast.node_type(node)
            when :self then self_literal
            when :local_write then @nilables.write(*children)
            when :and then @result.create_binary("&&", *children.map { truth(it) })
            when :or then @result.create_binary("||", *children.map { truth(it) })
            when :if then conditional(node, children.first, children.drop(1))
            else @arrays.lower(node)
            end
          end

          def conditional(node, condition, branches)
            type = @tast.type_of(node)
            values = branches.map { type == :nil ? @nilables.discard(it) : @nilables.coerce(it, type) }
            @result.create_conditional(truth(condition), *values)
          end

          def truth(condition)
            case @tast.type_of(condition)
            in :Bool then lower(condition)
            in [:nilable, _] then @nilables.truth(condition)
            in :nil then @result.create_binary(",", lower(condition), @result.create_literal("false"))
            else @result.create_binary(",", lower(condition), @result.create_literal("true"))
            end
          end

          def lower_while(condition, body)
            condition = lower(condition)
            @prelude.slice!(0..) + [@result.create_while(condition, lower_statements(body, :nil))]
          end
        end
      end
    end
  end
end
