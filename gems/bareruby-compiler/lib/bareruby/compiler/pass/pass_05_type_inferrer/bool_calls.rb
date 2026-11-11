# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        class BoolCalls
          CLASSES = %i[TrueClass FalseClass].freeze

          def initialize(typed_ast, inferrer)
            @result = typed_ast
            @inferrer = inferrer
          end

          def infer(node, receiver, (name, argument_nodes), scope)
            found = CLASSES.map { @inferrer.find_method_in(node, it, name) }
            arguments = @inferrer.infer_arguments(node, found.first.last, argument_nodes, scope)
            return @inferrer.call_method(node, found.first, receiver, :Bool, arguments) if found.uniq.size == 1

            @result.create_if(receiver || @result.create_self(:Bool), *branches(node, found, arguments))
          end

          private

          def branches(node, found, arguments)
            found.zip([true, false]).map do |owner_method, value|
              @inferrer.call_method(node, owner_method, @result.create_boolean(value), :Bool, arguments)
            end
          end
        end
      end
    end
  end
end
