# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        class Conditions
          BUILTIN_NIL_CHECKS = %i[Kernel NilClass].freeze
          BOOL_CLASSES = %i[TrueClass FalseClass].freeze

          def initialize(bareruby_ast, typed_ast, definitions, inferrer)
            @brast = bareruby_ast
            @result = typed_ast
            @definitions = definitions
            @inferrer = inferrer
          end

          def infer(node, scope)
            return negate(node, scope) if negation?(node)

            condition = @inferrer.infer(node, scope)
            [condition, *narrow(node, scope[:env])]
          end

          private

          def negation?(node)
            receiver, name, arguments = @brast.children_of(node)
            @brast.node_type(node) == :call && name == :! && arguments.empty? && receiver
          end

          def negate(node, scope)
            operand, true_env, false_env = infer(@brast.children_of(node).first, scope)
            condition = @inferrer.call_on(node, operand, scope)
            builtin = classes_of(@result.type_of(operand)).all? { @definitions.lookup(it, :!)&.first == :BasicObject }
            builtin ? [condition, false_env, true_env] : [condition, scope[:env].dup, scope[:env].dup]
          end

          def classes_of(type)
            return BOOL_CLASSES if type == :Bool
            return [@result.class_of(type.last), :NilClass] if @result.nilable?(type)

            [@result.class_of(type)]
          end

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
