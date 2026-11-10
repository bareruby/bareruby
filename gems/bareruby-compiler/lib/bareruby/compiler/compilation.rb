# frozen_string_literal: true

require "open3"
require_relative "pass/pass_01_bareruby_ast_generator"
require_relative "pass/pass_05_type_inferrer"
require_relative "pass/pass_09_lir_generator"
require_relative "pass/pass_12_cpp_source_generator"

module BareRuby
  module Compiler
    class Compilation
      CORE_SOURCES = File.expand_path("../../../core/**/*.rb", __dir__)

      attr_reader :cpp_files

      def initialize(program_path, output_directory, cxx: "g++")
        @program_path = program_path
        @output_directory = output_directory
        @cxx = cxx
      end

      def run
        generate_bareruby_ast
        infer_types
        generate_lir
        generate_cpp_source
        @cpp_files = [File.join(@output_directory, "main.cpp")] + @lir.native_sources
        self
      end

      private

      def generate_bareruby_ast
        @brast = Pass::BareRubyAstGenerator.new(Dir.glob(CORE_SOURCES) + [@program_path]).run.result
      end

      def infer_types
        @tast = Pass::TypeInferrer.new(@brast, size_of("POINTER")).run.result
      end

      def generate_lir
        @lir = Pass::LirGenerator.new(@tast, size_of("INT") * 8).run.result
      end

      def generate_cpp_source
        Pass::CppSourceGenerator.new(@lir).run.files.each do |name, source|
          File.write(File.join(@output_directory, name), source)
        end
      end

      def size_of(type)
        @macros ||= Open3.capture2(@cxx, "-dM", "-E", "-x", "c++", File::NULL).first
        @macros[/^#define __SIZEOF_#{type}__ (\d+)$/, 1].to_i
      end
    end
  end
end
