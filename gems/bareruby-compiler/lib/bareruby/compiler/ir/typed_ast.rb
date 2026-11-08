# frozen_string_literal: true

module BareRuby
  module Compiler
    class TypedAST
      attr_reader :statements, :native_methods

      def initialize
        @statements = []
        @native_methods = []
      end

      def add_statement(expression)
        @statements << expression
        self
      end

      def add_native_method(source, namespace, rows)
        @native_methods << { source:, namespace:, rows: }
        self
      end

      def create_native_row(function, parameters, returns) = { function:, parameters:, returns: }

      def create_native_call(namespace, row, arguments)
        build(:native_call, [namespace, row, arguments], row[:returns])
      end

      def create_boolean(value) = build(:boolean, [value], :Bool)

      def create_integer(value) = build(:integer, [value], :Int)

      def node_type(node) = node[:type]

      def children_of(node) = node[:children]

      def type_of(node) = node[:result_type]

      private

      def build(type, children, result_type) = { type:, children:, result_type: }.freeze
    end
  end
end
