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
          body = @tast.statements.map { lower(it) } + [@result.create_return(@result.create_literal("0"))]
          @result.add_function("main", "int", body)
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

        def cpp_type(type)
          case type
          when :Bool then "bool"
          when :Int then "int#{@int_width}_t"
          when :nil then "void"
          else raise Error, "unsupported native type #{type}"
          end
        end

        def lower(node)
          case @tast.node_type(node)
          when :native_call then lower_native_call(*@tast.children_of(node))
          when :boolean, :integer then @result.create_literal(@tast.children_of(node).first.to_s)
          end
        end

        def lower_native_call(namespace, row, arguments)
          @result.create_call("#{namespace}::#{row[:function]}", arguments.map { lower(it) })
        end
      end
    end
  end
end
