# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class LirGenerator
        class LogicalLowering
          NODE_TYPES = %i[logical].freeze

          def initialize(typed_ast, lir, names, body, nilables)
            @tast = typed_ast
            @result = lir
            @names = names
            @body = body
            @nilables = nilables
          end

          def lower(node)
            operator, left, right = @tast.children_of(node)
            type = @tast.type_of(node)
            return nil_left(operator, left, right, type) if @tast.type_of(left) == :nil

            temporary = @body.named_temporary(@names.cpp_type(@tast.type_of(left)))
            assignment = @result.create_assignment(temporary, @body.lower(left))
            branches = branches(operator, temporary, @tast.type_of(left), right, type)
            @result.create_binary(",", assignment,
                                  @result.create_conditional(@result.create_field(temporary, "present"), *branches))
          end

          private

          def nil_left(operator, left, right, type)
            return @body.lower(left) if operator == :and

            right_value = @nilables.coerce(right, type)
            return right_value if CallLowering::NIL_VALUES.include?(@tast.node_type(left))

            @result.create_binary(",", @body.lower(left), right_value)
          end

          def branches(operator, temporary, left_type, right, type)
            right_value = @nilables.coerce(right, type)
            return [right_value, @nilables.convert(:nil, type, true) { nil }] if operator == :and

            left_value = @nilables.convert(left_type.last, type, true) { @result.create_field(temporary, "value") }
            [left_value, right_value]
          end
        end
      end
    end
  end
end
