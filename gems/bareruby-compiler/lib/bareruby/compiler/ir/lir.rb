# frozen_string_literal: true

module BareRuby
  module Compiler
    class LIR
      attr_reader :headers, :structs, :functions, :native_sources

      def initialize
        @headers = []
        @structs = []
        @functions = []
        @native_sources = []
      end

      def add_header(name, namespaces, class_name, declarations)
        @headers << { name:, namespaces:, class_name:, declarations: }
        self
      end

      def add_struct(namespaces, name)
        @structs << { namespaces:, name: }
        self
      end

      def add_function(name, return_type, parameters, body)
        @functions << { name:, return_type:, parameters:, body: }
        self
      end

      def add_native_source(path)
        @native_sources << path
        self
      end

      def create_declaration(name, parameters, return_type) = { name:, parameters:, return_type: }

      def create_call(function, arguments) = { kind: :call, function:, arguments: }

      def create_literal(text) = { kind: :literal, text: }

      def create_address(name) = { kind: :address, name: }

      def create_variable_definition(type, name) = { kind: :variable_definition, type:, name: }

      def create_expression_statement(value) = { kind: :expression_statement, value: }

      def create_return(value) = { kind: :return, value: }
    end
  end
end
