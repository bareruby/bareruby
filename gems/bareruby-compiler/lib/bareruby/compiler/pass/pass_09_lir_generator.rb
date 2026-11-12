# frozen_string_literal: true

require_relative "../ir/lir"

module BareRuby
  module Compiler
    module Pass
      class LirGenerator
        attr_reader :result

        def initialize(typed_ast, int_width)
          @tast = typed_ast
          @names = CppNames.new(int_width)
        end

        def run
          @result = LIR.new
          add_native_classes
          @result.array_length_type = @names.cpp_type(:Int)
          add_structs
          @tast.functions.each { add_function(it) }
          add_main
          self
        end

        private

        def add_native_classes
          @tast.native_methods.group_by { [it[:source], it[:namespace]] }.each do |(source, namespace), methods|
            add_native_class(source, namespace, methods.flat_map { it[:rows] })
          end
        end

        def add_native_class(source, namespace, rows)
          *namespaces, class_name = namespace.split("::")
          declarations = rows.map { declaration(it) }
          @result.add_header("#{File.basename(source, ".rb")}.native.hpp", namespaces, class_name, declarations,
                             struct_names(rows))
          @result.add_native_source("#{source.delete_suffix(".rb")}.cpp")
        end

        def declaration(row)
          parameters = row[:parameters].reject { |_name, type| type == :nil }
          @result.create_declaration(row[:function], parameters.map { |name, type| [name, @names.cpp_type(type)] },
                                     @names.cpp_type(row[:returns]))
        end

        def struct_names(rows)
          types = rows.flat_map { it[:parameters].values + [it[:returns]] }
          types.filter_map { it in [:instance, name] and name }.uniq
        end

        def add_structs
          classes = @tast.classes.to_h
          classes.keys.sort_by { depth(classes, it) }.each do |name|
            @result.add_struct(CppNames::STRUCT_NAMESPACES, name, classes[name])
          end
        end

        def depth(classes, name) = classes[name] ? depth(classes, classes[name]) + 1 : 0

        def add_function(function)
          @result.add_function(@names.function_name(function), @names.cpp_type(function[:return_type]),
                               hidden_parameters(function) + parameters(function),
                               body(function[:locals], function[:locals].merge(function[:parameters].to_h),
                                    function[:body], function[:return_type]))
        end

        def hidden_parameters(function)
          parameters = []
          parameters << ["self", @names.cpp_type(function[:self_type])] if @names.instance_method?(function)
          parameters << ["storage", @names.cpp_type([:instance, function[:allocates]])] if function[:allocates]
          parameters << ["result", @names.cpp_type(function[:return_type])] if function[:return_type] in [:array, _]
          parameters
        end

        def parameters(function)
          function[:parameters].filter_map do |name, type|
            [@names.variable_name(name), @names.cpp_type(type)] unless type == :nil
          end
        end

        def add_main
          body = body(@tast.top_level_locals, @tast.top_level_locals, @tast.statements, :nil)
          @result.add_function("main", "int", [], body + [@result.create_return(@result.create_literal("0"))])
        end

        def body(locals, storages, nodes, return_type)
          definitions = locals.filter_map do |name, type|
            @result.create_variable_definition(@names.cpp_type(type), @names.variable_name(name)) unless type == :nil
          end
          definitions + FunctionBody.new(@tast, @result, @names, storages).lower_statements(nodes, return_type)
        end
      end
    end
  end
end

require_relative "pass_09_lir_generator/cpp_names"
require_relative "pass_09_lir_generator/function_body"
require_relative "pass_09_lir_generator/array_lowering"
require_relative "pass_09_lir_generator/call_lowering"
require_relative "pass_09_lir_generator/nilable_lowering"
require_relative "pass_09_lir_generator/logical_lowering"
