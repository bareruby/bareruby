# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class LirGenerator
        class CallLowering
          NODE_TYPES = %i[native_call method_call new_instance].freeze
          NIL_VALUES = %i[nil local self].freeze

          def initialize(typed_ast, lir, names, body)
            @tast = typed_ast
            @result = lir
            @names = names
            @body = body
          end

          def lower(node)
            children = @tast.children_of(node)
            case @tast.node_type(node)
            when :native_call then native_call(*children)
            when :method_call then method_call(*children)
            when :new_instance then new_instance(*children)
            end
          end

          private

          def native_call(namespace, row, receiver, arguments)
            hidden = self_values(receiver, row[:parameters].key?(:self))
            @result.create_call("#{namespace}::#{row[:function]}", hidden + values(arguments))
          end

          def method_call(function, receiver, arguments)
            hidden = self_values(receiver, @names.instance_method?(function)) + storages(function)
            @result.create_call(@names.function_name(function), hidden + values(arguments))
          end

          def self_values(receiver, passes_self)
            return values([receiver]) if receiver && @tast.type_of(receiver) == :nil
            return [] unless passes_self

            [receiver ? @body.lower(receiver) : @body.self_literal]
          end

          def values(arguments)
            arguments.filter_map do |argument|
              next @body.lower(argument) unless @tast.type_of(argument) == :nil

              evaluate(argument) unless NIL_VALUES.include?(@tast.node_type(argument))
              nil
            end
          end

          def evaluate(node) = @body.hoist(@result.create_expression_statement(@body.lower(node)))

          def storages(function)
            storages = []
            storages << @body.temporary(@names.struct_name(function[:allocates])) if function[:allocates]
            return_type = function[:return_type]
            storages << @body.temporary(@names.array_type(return_type.last)) if return_type in [:array, _]
            storages
          end

          def new_instance(initializer, arguments)
            storage = @result.create_literal("storage")
            call = @result.create_call(@names.function_name(initializer), [storage] + values(arguments))
            @body.hoist(@result.create_expression_statement(call))
            storage
          end
        end
      end
    end
  end
end
