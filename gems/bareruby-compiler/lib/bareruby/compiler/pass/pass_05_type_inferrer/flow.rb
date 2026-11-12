# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        class Flow
          def initialize(typed_ast)
            @result = typed_ast
          end

          def read(scope, name) = scope[:env].fetch(name, :nil)

          def assign(scope, name, type)
            scope[:env][name] = type
            widen(scope, name, type)
          end

          def merge(scope, first, second)
            (first.keys | second.keys).to_h do |name|
              type = @result.merge_types(first.fetch(name, :nil), second.fetch(name, :nil))
              widen(scope, name, type)
              [name, type]
            end
          end

          def branch(scope, env)
            scope[:env] = env
            [yield, scope[:env]]
          end

          private

          def widen(scope, name, type)
            return if scope[:parameters]&.include?(name)

            locals = scope[:locals]
            locals[name] = locals.key?(name) ? @result.merge_types(locals[name], type) : type
          end
        end
      end
    end
  end
end
