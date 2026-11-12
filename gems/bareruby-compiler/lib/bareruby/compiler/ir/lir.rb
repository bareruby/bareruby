# frozen_string_literal: true

module BareRuby
  module Compiler
    class LIR
      attr_accessor :array_length_type
      attr_reader :headers, :structs, :functions, :native_sources, :symbol_ids

      def initialize
        @headers = []
        @structs = []
        @functions = []
        @native_sources = []
        @symbol_ids = {}
      end

      def add_header(name, namespaces, class_name, declarations, structs)
        @headers << { name:, namespaces:, class_name:, declarations:, structs: }
        self
      end

      def add_struct(namespaces, name, parent)
        @structs << { namespaces:, name:, parent: }
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

      def symbol_id(name) = @symbol_ids[name] ||= @symbol_ids.size + 1

      def create_declaration(name, parameters, return_type) = { name:, parameters:, return_type: }

      def create_call(function, arguments) = { kind: :call, function:, arguments: }

      def create_literal(text) = { kind: :literal, text: }

      def create_address(name) = { kind: :address, name: }

      def create_variable_definition(type, name, values = []) = { kind: :variable_definition, type:, name:, values: }

      def create_assignment(target, value) = { kind: :assignment, target:, value: }

      def create_conditional(condition, consequent, alternative)
        { kind: :conditional, condition:, consequent:, alternative: }
      end

      def create_dereference(value) = { kind: :dereference, value: }

      def create_list(values) = { kind: :list, values: }

      def create_binary(operator, left, right) = { kind: :binary, operator:, left:, right: }

      def create_member(object, member) = { kind: :member, object:, member: }

      def create_field(object, member) = { kind: :field, object:, member: }

      def create_construction(type, values) = { kind: :construction, type:, values: }

      def create_element(array, index) = { kind: :element, array:, index: }

      def create_while(condition, body) = { kind: :while, condition:, body: }

      def create_expression_statement(value) = { kind: :expression_statement, value: }

      def create_return(value) = { kind: :return, value: }
    end
  end
end
