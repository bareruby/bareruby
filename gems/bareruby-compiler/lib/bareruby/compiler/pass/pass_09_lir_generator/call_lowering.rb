# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class LirGenerator
        class CallLowering
          NODE_TYPES = %i[native_call method_call new_instance].freeze

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
            hidden = []
            hidden << (receiver ? @body.lower(receiver) : @body.self_literal) if row[:parameters].key?(:self)
            @result.create_call("#{namespace}::#{row[:function]}", hidden + arguments.map { @body.lower(it) })
          end

          def method_call(function, receiver, arguments)
            hidden = []
            hidden << (receiver ? @body.lower(receiver) : @body.self_literal) if @names.instance_method?(function)
            hidden += storages(function)
            @result.create_call(@names.function_name(function), hidden + arguments.map { @body.lower(it) })
          end

          def storages(function)
            storages = []
            storages << @body.temporary(@names.struct_name(function[:allocates])) if function[:allocates]
            return_type = function[:return_type]
            storages << @body.temporary(@names.array_type(return_type.last)) if return_type in [:array, _]
            storages
          end

          def new_instance(initializer, arguments)
            storage = @result.create_literal("storage")
            call = @result.create_call(@names.function_name(initializer), [storage] + arguments.map { @body.lower(it) })
            @body.hoist(@result.create_expression_statement(call))
            storage
          end
        end
      end
    end
  end
end
