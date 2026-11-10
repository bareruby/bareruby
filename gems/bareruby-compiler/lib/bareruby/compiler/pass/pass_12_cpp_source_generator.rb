# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class CppSourceGenerator
        attr_reader :files

        def initialize(lir)
          @lir = lir
        end

        def run
          @files = @lir.headers.to_h { [it[:name], header(it)] }
          @files["main.cpp"] = main_source
          self
        end

        private

        def header(header)
          declarations = header[:declarations].map do |declaration|
            "  static #{declaration[:return_type]} #{declaration[:name]}(#{parameter_list(declaration)});\n"
          end
          class_definition = "class #{header[:class_name]} {\npublic:\n#{declarations.join}};\n"
          forward = header[:structs].map { in_namespaces(%w[BareRuby generated], "struct #{it};\n") }.join
          "#pragma once\n#include <cstdint>\n#{forward}#{in_namespaces(header[:namespaces], class_definition)}"
        end

        def main_source
          includes = (["<cstdint>"] + @lir.headers.map { "\"#{it[:name]}\"" }).map { "#include #{it}\n" }.join
          includes + array_struct + structs + prototypes + definitions
        end

        def definitions = @lir.functions.map { definition(it) }.join

        def array_struct
          length = @lir.array_length_type
          fields = "  #{length} length;\n  #{length} capacity;\n  T elements[16];\n"
          constructor = "template <typename T>\nArray<T>* array_new(Array<T>* array, #{length} length, T value) {\n  " \
                        "array->length = length;\n  array->capacity = length;\n  " \
                        "for (#{length} index = 0; index < length; index++) array->elements[index] = value;\n  " \
                        "return array;\n}\n"
          in_namespaces(["BareRuby"], "template <typename T>\nstruct Array {\n#{fields}};\n#{constructor}")
        end

        def structs
          @lir.structs.map do |struct|
            parent = struct[:parent] ? " : #{struct[:parent]}" : ""
            in_namespaces(struct[:namespaces], "struct #{struct[:name]}#{parent} {};\n")
          end.join
        end

        def prototypes = @lir.functions.reject { it[:name] == "main" }.map { "#{signature(it)};\n" }.join

        def in_namespaces(namespaces, body)
          namespaces.map { "namespace #{it} {\n" }.join + body + namespaces.map { "}\n" }.join
        end

        def parameter_list(function) = function[:parameters].map { |name, type| "#{type} #{name}" }.join(", ")

        def signature(function) = "#{function[:return_type]} #{function[:name]}(#{parameter_list(function)})"

        def definition(function) = "#{signature(function)} {\n#{block(function[:body], "  ")}}\n"

        def block(statements, indent) = statements.map { "#{indent}#{statement(it, indent)};\n" }.join

        def statement(node, indent)
          case node[:kind]
          when :return then "return #{expression(node[:value])}"
          when :variable_definition then "#{node[:type]} #{node[:name]}{#{arguments(node[:values])}}"
          when :expression_statement then expression(node[:value])
          when :while then while_statement(node, indent)
          end
        end

        def while_statement(node, indent)
          "while (#{expression(node[:condition])}) {\n#{block(node[:body], "#{indent}  ")}#{indent}}"
        end

        def arguments(nodes) = nodes.map { expression(it) }.join(", ")

        def expression(node)
          case node[:kind]
          when :call then "#{node[:function]}(#{arguments(node[:arguments])})"
          when :address then "&#{node[:name]}"
          when :literal then node[:text]
          else compound_expression(node)
          end
        end

        def compound_expression(node)
          case node[:kind]
          when :assignment then "#{expression(node[:target])} = #{expression(node[:value])}"
          when :dereference then "*#{expression(node[:value])}"
          when :list then "{#{arguments(node[:values])}}"
          else access_expression(node)
          end
        end

        def conditional_expression(node)
          "(#{expression(node[:condition])} ? #{expression(node[:consequent])} : #{expression(node[:alternative])})"
        end

        def access_expression(node)
          case node[:kind]
          when :conditional then conditional_expression(node)
          when :binary then "(#{expression(node[:left])} #{node[:operator]} #{expression(node[:right])})"
          when :member then "#{expression(node[:object])}->#{node[:member]}"
          when :element then "#{expression(node[:array])}[#{expression(node[:index])}]"
          end
        end
      end
    end
  end
end
