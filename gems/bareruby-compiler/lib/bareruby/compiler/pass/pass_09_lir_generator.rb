# frozen_string_literal: true

require_relative "../ir/lir"

module BareRuby
  module Compiler
    module Pass
      class LirGenerator
        attr_reader :result

        def initialize(typed_ast, int_width)
          @tast = typed_ast
          @int_width = int_width
        end

        def run
          @result = LIR.new
          @tast.native_methods.group_by { [it[:source], it[:namespace]] }.each do |(source, namespace), methods|
            add_native_class(source, namespace, methods.flat_map { it[:rows] })
          end
          object_classes.each { @result.add_struct(["BareRuby"], it) }
          @tast.functions.each { add_function(it) }
          add_main
          self
        end

        private

        def add_native_class(source, namespace, rows)
          *namespaces, class_name = namespace.split("::")
          declarations = rows.map { declaration(it) }
          @result.add_header("#{File.basename(source, ".rb")}.native.hpp", namespaces, class_name, declarations)
          @result.add_native_source("#{source.delete_suffix(".rb")}.cpp")
        end

        def declaration(row)
          parameters = row[:parameters].reject { |_name, type| type == :nil }
          @result.create_declaration(row[:function], parameters.map { |name, type| [name, cpp_type(type)] },
                                     cpp_type(row[:returns]))
        end

        def object_classes = @tast.functions.filter_map { it[:self_type].last if instance_method?(it) }.uniq

        def cpp_type(type)
          case type
          in :Bool then "bool"
          in :Int then "int#{@int_width}_t"
          in :nil then "void"
          in [:instance, class_name] then "BareRuby::#{class_name}*"
          end
        end

        def add_function(function)
          @result.add_function(function_name(function), cpp_type(function[:return_type]),
                               hidden_parameters(function) + parameters(function),
                               function_body(function[:body], function[:return_type]))
        end

        def hidden_parameters(function)
          parameters = []
          parameters << ["self", cpp_type(function[:self_type])] if instance_method?(function)
          parameters << ["storage", cpp_type([:instance, function[:allocates]])] if function[:allocates]
          parameters
        end

        def parameters(function) = function[:parameters].map { |name, type| [variable_name(name), cpp_type(type)] }

        def add_main
          body = function_body(@tast.statements, :nil) + [@result.create_return(@result.create_literal("0"))]
          @result.add_function("main", "int", [], body)
        end

        def function_body(nodes, return_type)
          @prelude = []
          @temporaries = 0
          statements(nodes, return_type)
        end

        def statements(nodes, return_type)
          nodes.each_with_index.flat_map do |node, index|
            value = lower(node)
            last = index == nodes.size - 1 && return_type != :nil
            statement = last ? @result.create_return(value) : @result.create_expression_statement(value)
            @prelude.slice!(0..) + [statement]
          end
        end

        def lower(node)
          children = @tast.children_of(node)
          case @tast.node_type(node)
          when :native_call then lower_native_call(*children)
          when :method_call then lower_method_call(*children)
          when :new_instance then lower_new_instance(*children)
          when :local then @result.create_literal(variable_name(children.first))
          when :boolean, :integer then @result.create_literal(children.first.to_s)
          end
        end

        def lower_native_call(namespace, row, arguments)
          @result.create_call("#{namespace}::#{row[:function]}", arguments.map { lower(it) })
        end

        def lower_method_call(function, receiver, arguments)
          hidden = []
          hidden << (receiver ? lower(receiver) : @result.create_literal("self")) if instance_method?(function)
          hidden << temporary(function[:allocates]) if function[:allocates]
          @result.create_call(function_name(function), hidden + arguments.map { lower(it) })
        end

        def lower_new_instance(initializer, arguments)
          storage = @result.create_literal("storage")
          call = @result.create_call(function_name(initializer), [storage] + arguments.map { lower(it) })
          @prelude << @result.create_expression_statement(call)
          storage
        end

        def temporary(class_name)
          name = "temporary#{@temporaries += 1}"
          @prelude << @result.create_variable_definition("BareRuby::#{class_name}", name)
          @result.create_address(name)
        end

        def instance_method?(function) = function[:self_type].first == :instance

        def function_name(function) = "bareruby_#{function[:name]}"

        def variable_name(name) = "variable_#{name}"
      end
    end
  end
end
