# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class LirGenerator
        class NilableLowering
          NODE_TYPES = %i[nilable_dispatch dispatch_value].freeze

          def initialize(typed_ast, lir, names, body, storages)
            @tast = typed_ast
            @result = lir
            @names = names
            @body = body
            @storages = storages
            @dispatch_values = {}.compare_by_identity
          end

          def lower(node)
            return dispatch(node, *@tast.children_of(node)) if @tast.node_type(node) == :nilable_dispatch

            @result.create_field(@dispatch_values.fetch(node), "value")
          end

          def read(name, type)
            return @result.create_literal("nullptr") if type == :nil

            variable = variable(name)
            @storages[name] == [:nilable, type] ? @result.create_field(variable, "value") : variable
          end

          def write(name, value)
            storage = @storages.fetch(name)
            return @body.lower(value) if storage == :nil

            assignment = @result.create_assignment(variable(name), coerce(value, storage))
            type = @tast.type_of(value)
            return assignment if [storage, :nil].include?(type)

            @result.create_binary(",", assignment, read(name, type))
          end

          def coerce(node, target)
            type = @tast.type_of(node)
            return @body.lower(node) unless (target in [:nilable, value_type]) && type != target
            return construct(target, "true", @body.lower(node)) if type == value_type
            return @body.lower(node) unless type == :nil

            empty = construct(target, "false", @result.create_literal("0"))
            CallLowering::NIL_VALUES.include?(@tast.node_type(node)) ? empty : comma(@body.lower(node), empty)
          end

          def truth(condition) = @result.create_field(@body.lower(condition), "present")

          def discard(node)
            pure = CallLowering::NIL_VALUES.include?(@tast.node_type(node))
            @result.create_call("static_cast<void>", [pure ? @result.create_literal("0") : @body.lower(node)])
          end

          private

          def dispatch(node, receiver, value, value_call, nil_call)
            temporary = @body.named_temporary(@names.cpp_type(@tast.type_of(receiver)))
            @dispatch_values[value] = temporary
            type = @tast.type_of(node)
            branches = [value_call, nil_call].map { type == :nil ? discard(it) : coerce(it, type) }
            assignment = @result.create_assignment(temporary, @body.lower(receiver))
            comma(assignment, @result.create_conditional(@result.create_field(temporary, "present"), *branches))
          end

          def variable(name) = @result.create_literal(@names.variable_name(name))

          def construct(type, present, value)
            @result.create_construction(@names.cpp_type(type), [@result.create_literal(present), value])
          end

          def comma(left, right) = @result.create_binary(",", left, right)
        end
      end
    end
  end
end
