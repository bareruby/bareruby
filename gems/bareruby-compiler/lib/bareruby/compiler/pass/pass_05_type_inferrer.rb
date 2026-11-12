# frozen_string_literal: true

require_relative "../ir/typed_ast"

module BareRuby
  module Compiler
    module Pass
      # The compiler is provisional and will be discarded and rebuilt,
      # so its classes are not split to meet the length limit.
      class TypeInferrer # rubocop:disable Metrics/ClassLength
        TOP_LEVEL_SELF = %i[instance Object].freeze
        FORWARDING = :"..."

        attr_reader :result, :flow, :conditions

        def initialize(bareruby_ast, pointer_size)
          @brast = bareruby_ast
          @pointer_size = pointer_size
        end

        def run
          @result = TypedAST.new
          @definitions = Definitions.new(@brast, @result).run
          create_helpers
          add_native_methods
          infer_top_level
          @result.classes = @definitions.classes
          self
        end

        def infer(node, scope)
          value = @brast.children_of(node).first
          case @brast.node_type(node)
          when :call then infer_call(node, scope)
          when :local then @result.create_local(value, @flow.read(scope, value))
          when :constant then @result.create_class_reference(value)
          else infer_literal(node, value, scope)
          end
        end

        def call_method(node, (owner, method), receiver, self_type, arguments)
          types = types_of(arguments)
          if method[:rows]
            row = @native_rows.select(node, owner, method, self_type, types)
            return @result.create_native_call("BareRuby::#{owner}", row, receiver, arguments)
          end

          function = @specializer.specialize(owner, @brast.children_of(node)[1], method, self_type, types)
          @result.create_method_call(function, receiver, arguments)
        end

        def infer_arguments(node, method, argument_nodes, scope)
          forwarding = argument_nodes.size == 1 && @brast.node_type(argument_nodes.first) == :forwarding
          arguments = forwarding ? scope[:forwarded] : argument_nodes.map { infer(it, scope) }
          check_arity(node, method, arguments)
          arguments
        end

        def find_method_in(node, class_name, name)
          found = @definitions.lookup(class_name, name)
          @definitions.error(node, "undefined method '#{name}' for #{class_name}") unless found

          found
        end

        private

        def create_helpers
          @flow = Flow.new(@result)
          @conditions = Conditions.new(@brast, @result, @definitions, self)
          @expressions = Expressions.new(@brast, @result, @definitions, self, @pointer_size)
          @native_rows = NativeRows.new(@brast, @definitions)
          @specializer = Specializer.new(@result, self)
          @bool_calls = BoolCalls.new(@result, self)
          @nilable_calls = NilableCalls.new(@result, @definitions, self)
        end

        def infer_literal(node, value, scope)
          case @brast.node_type(node)
          when :boolean then @result.create_boolean(value)
          when :integer then @result.create_integer(value)
          when :float then @result.create_float(value)
          when :symbol then @result.create_symbol(value)
          when :nil then @result.create_nil
          else @expressions.infer(node, scope)
          end
        end

        def infer_top_level
          scope = { self: TOP_LEVEL_SELF, locals: {}, env: {}, forwarded: nil }
          @definitions.statements.each { @result.add_statement(infer(it, scope)) }
          @result.top_level_locals = scope[:locals]
        end

        def add_native_methods
          @definitions.each_native_method do |owner, path, rows|
            @result.add_native_method(path, "BareRuby::#{owner}", rows)
          end
        end

        def infer_call(node, scope)
          return infer_primitive_call(node, scope) if primitive_call?(node)

          receiver_node, name, argument_nodes = @brast.children_of(node)
          receiver = receiver_node && infer(receiver_node, scope)
          self_type = receiver ? @result.type_of(receiver) : scope[:self]
          return @bool_calls.infer(node, receiver, [name, argument_nodes], scope) if self_type == :Bool
          return @nilable_calls.infer(node, receiver, [name, argument_nodes], scope) if @result.nilable?(self_type)

          owner, method = find_method(node, self_type, name)
          arguments = infer_arguments(node, method, argument_nodes, scope)
          call_method(node, [owner, method], receiver, self_type, arguments)
        end

        def primitive_call?(node)
          @definitions.primitive_call?(node, :new_instance) || @expressions.array_primitive?(node)
        end

        def infer_primitive_call(node, scope)
          return infer_new_instance(node, scope) if @definitions.primitive_call?(node, :new_instance)

          @expressions.infer_array_primitive(node, scope)
        end

        def find_method(node, self_type, name)
          class_name = @result.class_of(self_type)
          return find_method_in(node, class_name, name) unless self_type in [:class, owner]

          found = @definitions.lookup_singleton(owner, name)
          @definitions.error(node, "undefined method '#{name}' for #{class_name}") unless found

          found
        end

        def types_of(arguments) = arguments.map { @result.type_of(it) }

        def infer_new_instance(node, scope)
          kind, class_name = scope[:self]
          @definitions.error(node, "Primitive.new_instance needs a class as self") unless kind == :class

          instance = [:instance, class_name]
          owner, method = find_method(node, instance, :initialize)
          arguments = infer_arguments(node, method, @brast.children_of(node)[2], scope)
          initializer = @specializer.specialize(owner, :initialize, method, instance, types_of(arguments))
          scope[:allocates] = class_name
          @result.create_new_instance(class_name, initializer, arguments)
        end

        def check_arity(node, method, arguments)
          parameters = method[:parameters]
          return if method[:rows] || Specializer.forwarding?(method) || arguments.size == parameters.size

          @definitions.error(node, "wrong number of arguments (given #{arguments.size}, expected #{parameters.size})")
        end
      end
    end
  end
end

require_relative "pass_05_type_inferrer/definitions"
require_relative "pass_05_type_inferrer/expressions"
require_relative "pass_05_type_inferrer/specializer"
require_relative "pass_05_type_inferrer/native_rows"
require_relative "pass_05_type_inferrer/bool_calls"
require_relative "pass_05_type_inferrer/flow"
require_relative "pass_05_type_inferrer/conditions"
require_relative "pass_05_type_inferrer/nilable_calls"
