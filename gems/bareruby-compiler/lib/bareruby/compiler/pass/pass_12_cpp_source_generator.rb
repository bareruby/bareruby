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
          "#pragma once\n#include <cstdint>\n#{in_namespaces(header[:namespaces], class_definition)}"
        end

        def main_source
          includes = (["<cstdint>"] + @lir.headers.map { "\"#{it[:name]}\"" }).map { "#include #{it}\n" }.join
          includes + structs + prototypes + @lir.functions.map { definition(it) }.join
        end

        def structs = @lir.structs.map { in_namespaces(it[:namespaces], "struct #{it[:name]} {};\n") }.join

        def prototypes = @lir.functions.reject { it[:name] == "main" }.map { "#{signature(it)};\n" }.join

        def in_namespaces(namespaces, body)
          namespaces.map { "namespace #{it} {\n" }.join + body + namespaces.map { "}\n" }.join
        end

        def parameter_list(function) = function[:parameters].map { |name, type| "#{type} #{name}" }.join(", ")

        def signature(function) = "#{function[:return_type]} #{function[:name]}(#{parameter_list(function)})"

        def definition(function)
          "#{signature(function)} {\n#{function[:body].map { "  #{statement(it)};\n" }.join}}\n"
        end

        def statement(node)
          case node[:kind]
          when :return then "return #{expression(node[:value])}"
          when :variable_definition then "#{node[:type]} #{node[:name]}{}"
          when :expression_statement then expression(node[:value])
          end
        end

        def expression(node)
          case node[:kind]
          when :call then "#{node[:function]}(#{node[:arguments].map { expression(it) }.join(", ")})"
          when :address then "&#{node[:name]}"
          when :literal then node[:text]
          end
        end
      end
    end
  end
end
