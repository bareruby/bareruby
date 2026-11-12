# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        class Conditions
          def initialize(bareruby_ast, typed_ast, inferrer, flow)
            @brast = bareruby_ast
            @result = typed_ast
            @inferrer = inferrer
            @flow = flow
          end

          def infer(node, scope)
            condition = @inferrer.infer(node, scope)
            [condition, *narrow(node, condition, scope[:env])]
          end

          private

          def narrow(node, condition, env)
            return [env.dup, env.dup] unless @brast.node_type(node) == :local

            type = @result.type_of(condition)
            return [env.dup, env.dup] unless type in [:nilable, value]

            name = @brast.children_of(node).first
            [env.merge(name => value), env.merge(name => :nil)]
          end
        end
      end
    end
  end
end
