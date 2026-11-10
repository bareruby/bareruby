# frozen_string_literal: true

require_relative "../ir/typed_ast"

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        TOP_LEVEL_SELF = %i[instance Object].freeze
        FORWARDING = :"..."

        attr_reader :result

        def initialize(bareruby_ast)
          @brast = bareruby_ast
        end

        def run
          @result = TypedAST.new
          @definitions = Definitions.new(@brast, @result).run
          @specializations = {}
          @definitions.each_native_method do |owner, path, rows|
            @result.add_native_method(path, "BareRuby::#{owner}", rows)
          end
          scope = { self: TOP_LEVEL_SELF, locals: {}, forwarded: nil }
          @definitions.statements.each { @result.add_statement(infer(it, scope)) }
          self
        end

        private

        def infer(node, scope)
          value = @brast.children_of(node).first
          case @brast.node_type(node)
          when :call then infer_call(node, scope)
          when :local then @result.create_local(value, scope[:locals].fetch(value))
          when :constant then @result.create_class_reference(value)
          when :boolean then @result.create_boolean(value)
          when :integer then @result.create_integer(value)
          else @definitions.error(node, "unsupported expression #{@brast.node_type(node)}")
          end
        end

        def infer_call(node, scope)
          return infer_new_instance(node, scope) if @definitions.primitive_call?(node, :new_instance)

          receiver_node, name, argument_nodes = @brast.children_of(node)
          receiver = receiver_node && infer(receiver_node, scope)
          self_type = receiver ? @result.type_of(receiver) : scope[:self]
          owner, method = find_method(node, self_type, name)
          arguments = infer_arguments(node, method, argument_nodes, scope)
          return native_call(node, owner, method, receiver, arguments) if method[:rows]

          @result.create_method_call(specialize(owner, name, method, self_type, types_of(arguments)), receiver,
                                     arguments)
        end

        def find_method(node, self_type, name)
          class_name = @result.class_of(self_type)
          found = @definitions.lookup(class_name, name)
          @definitions.error(node, "undefined method '#{name}' for #{class_name}") unless found

          found
        end

        def infer_arguments(node, method, argument_nodes, scope)
          forwarding = argument_nodes.size == 1 && @brast.node_type(argument_nodes.first) == :forwarding
          arguments = forwarding ? scope[:forwarded] : argument_nodes.map { infer(it, scope) }
          check_arity(node, method, arguments)
          arguments
        end

        def types_of(arguments) = arguments.map { @result.type_of(it) }

        def native_call(node, owner, method, receiver, arguments)
          name = @brast.children_of(node)[1]
          types = types_of(arguments)
          row = method[:rows].map(&:last).rfind { it[:parameters].except(:self).values == types }
          @definitions.error(node, "no native_def of #{owner}##{name} accepts (#{types.join(", ")})") unless row

          @result.create_native_call("BareRuby::#{owner}", row, receiver, arguments)
        end

        def infer_new_instance(node, scope)
          kind, class_name = scope[:self]
          @definitions.error(node, "Primitive.new_instance needs a class as self") unless kind == :class

          instance = [:instance, class_name]
          owner, method = find_method(node, instance, :initialize)
          arguments = infer_arguments(node, method, @brast.children_of(node)[2], scope)
          initializer = specialize(owner, :initialize, method, instance, types_of(arguments))
          scope[:allocates] = class_name
          @result.create_new_instance(class_name, initializer, arguments)
        end

        def specialize(owner, name, method, self_type, types)
          key = [owner, name, self_type, types]
          return @specializations[key] if @specializations.key?(key)

          function = @result.create_function("#{owner}_#{name}_#{@specializations.size}", self_type,
                                             parameter_names(method, types).zip(types))
          @specializations[key] = function
          fill_function(function, method)
        end

        def parameter_names(method, types)
          forwarding?(method) ? types.each_index.map { :"argument#{it}" } : method[:parameters]
        end

        def forwarding?(method) = method[:parameters] == [FORWARDING]

        def fill_function(function, method)
          parameters = function[:parameters]
          forwarded = parameters.map { |name, type| @result.create_local(name, type) } if forwarding?(method)
          scope = { self: function[:self_type], locals: parameters.to_h, forwarded: }
          body = method[:body].map { infer(it, scope) }
          function.merge!(body:, return_type: body.empty? ? :nil : @result.type_of(body.last),
                          allocates: scope[:allocates])
          @result.add_function(function)
          function
        end

        def check_arity(node, method, arguments)
          parameters = method[:parameters]
          return if method[:rows] || forwarding?(method) || arguments.size == parameters.size

          @definitions.error(node, "wrong number of arguments (given #{arguments.size}, expected #{parameters.size})")
        end
      end
    end
  end
end

require_relative "pass_05_type_inferrer/definitions"
