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
          object_classes.each { @result.add_struct(["BareRuby"], it) }
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
          @result.add_header("#{File.basename(source, ".rb")}.native.hpp", namespaces, class_name, declarations)
          @result.add_native_source("#{source.delete_suffix(".rb")}.cpp")
        end

        def declaration(row)
          parameters = row[:parameters].reject { |_name, type| type == :nil }
          @result.create_declaration(row[:function], parameters.map { |name, type| [name, @names.cpp_type(type)] },
                                     @names.cpp_type(row[:returns]))
        end

        def object_classes = @tast.functions.filter_map { it[:self_type].last if @names.instance_method?(it) }.uniq

        def add_function(function)
          @result.add_function(@names.function_name(function), @names.cpp_type(function[:return_type]),
                               hidden_parameters(function) + parameters(function),
                               body(function[:body], function[:return_type]))
        end

        def hidden_parameters(function)
          parameters = []
          parameters << ["self", @names.cpp_type(function[:self_type])] if @names.instance_method?(function)
          parameters << ["storage", @names.cpp_type([:instance, function[:allocates]])] if function[:allocates]
          parameters
        end

        def parameters(function)
          function[:parameters].map { |name, type| [@names.variable_name(name), @names.cpp_type(type)] }
        end

        def add_main
          body = body(@tast.statements, :nil)
          @result.add_function("main", "int", [], body + [@result.create_return(@result.create_literal("0"))])
        end

        def body(nodes, return_type) = FunctionBody.new(@tast, @result, @names).lower_statements(nodes, return_type)
      end
    end
  end
end

require_relative "pass_09_lir_generator/cpp_names"
require_relative "pass_09_lir_generator/function_body"
