# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        class Conditions
          BUILTIN_NIL_CHECKS = %i[Kernel NilClass].freeze

          def initialize(bareruby_ast, typed_ast, definitions, inferrer)
            @brast = bareruby_ast
            @result = typed_ast
            @definitions = definitions
            @inferrer = inferrer
          end

          def infer(node, scope)
            condition = @inferrer.infer(node, scope)
            [condition, *narrow(node, scope[:env])]
          end

          private

          def narrow(node, env)
            name, truthy = target(node, env)
            type = name && env.fetch(name, :nil)
            return [env.dup, env.dup] unless @result.nilable?(type)

            narrowed = [env.merge(name => type.last), env.merge(name => :nil)]
            truthy ? narrowed : narrowed.reverse
          end

          def target(node, env)
            case @brast.node_type(node)
            when :local then [@brast.children_of(node).first, true]
            when :call then nil_check(node, env)
            end
          end

          def nil_check(node, env)
            receiver, name, arguments = @brast.children_of(node)
            return unless name == :nil? && arguments.empty? && receiver && @brast.node_type(receiver) == :local

            local = @brast.children_of(receiver).first
            [local, false] if builtin_nil_check?(env.fetch(local, :nil))
          end

          def builtin_nil_check?(type)
            return false unless @result.nilable?(type)

            owners = [@result.class_of(type.last), :NilClass].map { @definitions.lookup(it, :nil?)&.first }
            owners == BUILTIN_NIL_CHECKS
          end
        end
      end
    end
  end
end
