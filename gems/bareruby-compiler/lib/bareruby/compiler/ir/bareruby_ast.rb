# frozen_string_literal: true

module BareRuby
  module Compiler
    class BareRubyAST
      def initialize
        @files = []
      end

      def add_file(path, statements)
        @files << { path:, statements: }
        self
      end

      def create_span(filename, start, finish)
        { filename:, start:, end: finish }
      end

      def create_module_definition(name, body, span) = build(:module_definition, [name, body], span)

      def create_class_definition(name, body, superclass, span)
        build(:class_definition, [name, body, superclass], span)
      end

      def create_method_definition(name, parameters, body, span)
        build(:method_definition, [name, parameters, body], span)
      end

      def create_singleton_class(body, span) = build(:singleton_class, [body], span)

      def create_singleton_method_definition(name, parameters, body, span)
        build(:singleton_method_definition, [name, parameters, body], span)
      end

      def create_call(receiver, name, arguments, span) = build(:call, [receiver, name, arguments], span)

      def create_constant(name, span) = build(:constant, [name], span)

      def create_local(name, span) = build(:local, [name], span)

      def create_local_write(name, value, span) = build(:local_write, [name, value], span)

      def create_self(span) = build(:self, [], span)

      def create_array(elements, span) = build(:array, [elements], span)

      def create_while(condition, body, span) = build(:while, [condition, body], span)

      def create_and(left, right, span) = build(:and, [left, right], span)

      def create_or(left, right, span) = build(:or, [left, right], span)

      def create_if(condition, consequent, alternative, span) = build(:if, [condition, consequent, alternative], span)

      def create_forwarding(span) = build(:forwarding, [], span)

      def create_boolean(value, span) = build(:boolean, [value], span)

      def create_integer(value, span) = build(:integer, [value], span)

      def create_float(text, span) = build(:float, [text], span)

      def create_nil(span) = build(:nil, [], span)

      def create_symbol(name, span) = build(:symbol, [name], span)

      def create_hash(pairs, span) = build(:hash, [pairs], span)

      def each_file = @files.each { yield it[:path], it[:statements] }

      def node_type(node) = node[:type]

      def children_of(node) = node[:children]

      def span_of(node) = node[:span]

      private

      def build(type, children, span) = { type:, children:, span: }.freeze
    end
  end
end
