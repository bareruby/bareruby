# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class LirGenerator
        class NilableLowering
          def initialize(typed_ast, lir, names, body, storages)
            @tast = typed_ast
            @result = lir
            @names = names
            @body = body
            @storages = storages
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
