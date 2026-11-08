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
          includes = @lir.headers.map { "#include \"#{it[:name]}\"\n" }.join
          @files["main.cpp"] = includes + @lir.functions.map { function(it) }.join
          self
        end

        private

        def header(header)
          declarations = header[:declarations].map do |declaration|
            parameters = declaration[:parameters].map { |name, type| "#{type} #{name}" }.join(", ")
            "  static #{declaration[:return_type]} #{declaration[:name]}(#{parameters});\n"
          end
          opening = header[:namespaces].map { "namespace #{it} {\n" }.join
          closing = header[:namespaces].map { "}\n" }.join
          "#pragma once\n#include <cstdint>\n#{opening}class #{header[:class_name]} {\npublic:\n" \
            "#{declarations.join}};\n#{closing}"
        end

        def function(function)
          body = function[:body].map { "  #{statement(it)};\n" }.join
          "#{function[:return_type]} #{function[:name]}() {\n#{body}}\n"
        end

        def statement(node) = node[:kind] == :return ? "return #{expression(node[:value])}" : expression(node)

        def expression(node)
          case node[:kind]
          when :call then "#{node[:function]}(#{node[:arguments].map { expression(it) }.join(", ")})"
          when :literal then node[:text]
          end
        end
      end
    end
  end
end
