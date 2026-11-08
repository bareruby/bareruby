# frozen_string_literal: true

module BareRuby
  module Compiler
    class LIR
      attr_reader :headers, :functions, :native_sources

      def initialize
        @headers = []
        @functions = []
        @native_sources = []
      end

      def add_header(name, namespaces, class_name, declarations)
        @headers << { name:, namespaces:, class_name:, declarations: }
        self
      end

      def add_function(name, return_type, body)
        @functions << { name:, return_type:, body: }
        self
      end

      def add_native_source(path)
        @native_sources << path
        self
      end

      def create_declaration(name, parameters, return_type) = { name:, parameters:, return_type: }

      def create_call(function, arguments) = { kind: :call, function:, arguments: }

      def create_literal(text) = { kind: :literal, text: }

      def create_return(value) = { kind: :return, value: }
    end
  end
end
