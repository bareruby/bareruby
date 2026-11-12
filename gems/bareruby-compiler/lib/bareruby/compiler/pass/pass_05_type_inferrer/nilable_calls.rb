# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        class NilableCalls
          def initialize(typed_ast, definitions, inferrer)
            @result = typed_ast
            @definitions = definitions
            @inferrer = inferrer
          end

          def infer(node, receiver, (name, argument_nodes), scope)
            self_type = receiver ? @result.type_of(receiver) : scope[:self]
            value_found = @inferrer.find_method_in(node, @result.class_of(self_type.last), name)
            nil_found = @definitions.lookup(:NilClass, name)
            @definitions.error(node, "undefined method '#{name}' for nil") unless nil_found
            arguments = @inferrer.infer_arguments(node, value_found.last, argument_nodes, scope)
            found = [value_found, nil_found]
            return @inferrer.call_method(node, value_found, receiver, self_type, arguments) if shared?(*found)

            dispatch(node, receiver || @result.create_self(self_type), found, arguments)
          end

          def split(node, found, (receiver, self_type), (arguments, index))
            argument = arguments[index]
            value = @result.create_dispatch_value(@result.type_of(argument).last)
            calls = [value, @result.create_nil].map do |replacement|
              replaced = arguments.dup.tap { it[index] = replacement }
              @inferrer.call_method(node, found, receiver, self_type, replaced)
            end
            @result.create_nilable_dispatch(argument, value, *calls)
          end

          private

          def shared?(value_found, nil_found) = value_found == nil_found && !value_found.last[:rows]

          def dispatch(node, receiver, (value_found, nil_found), arguments)
            value = @result.create_dispatch_value(@result.type_of(receiver).last)
            value_call = @inferrer.call_method(node, value_found, value, @result.type_of(value), arguments)
            nil_call = @inferrer.call_method(node, nil_found, @result.create_nil, :nil, arguments)
            @result.create_nilable_dispatch(receiver, value, value_call, nil_call)
          end
        end
      end
    end
  end
end
