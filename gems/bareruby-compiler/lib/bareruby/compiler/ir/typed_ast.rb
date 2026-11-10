# frozen_string_literal: true

module BareRuby
  module Compiler
    class TypedAST
      attr_accessor :top_level_locals
      attr_reader :statements, :native_methods, :functions

      def initialize
        @statements = []
        @native_methods = []
        @functions = []
      end

      def add_statement(expression)
        @statements << expression
        self
      end

      def add_native_method(source, namespace, rows)
        @native_methods << { source:, namespace:, rows: }
        self
      end

      def add_function(function)
        @functions << function
        self
      end

      def create_function(name, self_type, parameters)
        { name:, self_type:, parameters:, body: [], return_type: :nil, allocates: nil, locals: {} }
      end

      def create_native_row(function, parameters, returns) = { function:, parameters:, returns: }

      def create_native_call(namespace, row, receiver, arguments)
        build(:native_call, [namespace, row, receiver, arguments], row[:returns])
      end

      def create_method_call(function, receiver, arguments)
        build(:method_call, [function, receiver, arguments], function[:return_type])
      end

      def create_new_instance(class_name, initializer, arguments)
        build(:new_instance, [initializer, arguments], [:instance, class_name])
      end

      def create_local(name, type) = build(:local, [name], type)

      def create_local_write(name, value) = build(:local_write, [name, value], type_of(value))

      def create_self(type) = build(:self, [], type)

      def create_while(condition, body) = build(:while, [condition, body], :nil)

      def create_and(left, right) = build(:and, [left, right], :Bool)

      def create_array(elements, element_type) = build(:array, [elements], [:array, element_type])

      def create_array_length(array_type) = build(:array_length, [array_type], :Int)

      def create_array_element(array_type, index) = build(:array_element, [index], array_type.last)

      def create_class_reference(name) = build(:class_reference, [name], [:class, name])

      def create_boolean(value) = build(:boolean, [value], :Bool)

      def create_integer(value) = build(:integer, [value], :Int)

      def node_type(node) = node[:type]

      def children_of(node) = node[:children]

      def type_of(node) = node[:result_type]

      def class_of(type)
        case type
        in :Int then :Integer
        in [:class, _] then :Class
        in [:array, _] then :Array
        in [:instance, class_name] then class_name
        end
      end

      private

      def build(type, children, result_type) = { type:, children:, result_type: }.freeze
    end
  end
end
