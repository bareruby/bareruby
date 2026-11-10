# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class LirGenerator
        class ArrayLowering
          NODE_TYPES = %i[array array_length array_element array_store array_new].freeze

          def initialize(typed_ast, lir, names, body)
            @tast = typed_ast
            @result = lir
            @names = names
            @body = body
          end

          def lower(node)
            children = @tast.children_of(node)
            case @tast.node_type(node)
            when :array then literal(children.first, @tast.type_of(node).last)
            when :array_length then @result.create_member(@body.self_literal, "length")
            when :array_element then element(children.first)
            when :array_store then store(*children)
            when :array_new then array_new(*children, @tast.type_of(node).last)
            end
          end

          private

          def literal(elements, element_type)
            length = @result.create_literal(elements.size.to_s)
            values = @result.create_list(elements.map { @body.lower(it) })
            @body.temporary(@names.array_type(element_type), [length, length, values])
          end

          def element(index)
            @result.create_element(@result.create_member(@body.self_literal, "elements"), @body.lower(index))
          end

          def store(index, value) = @result.create_assignment(element(index), @body.lower(value))

          def array_new(length, value, element_type)
            storage = @body.temporary(@names.array_type(element_type))
            @result.create_call("BareRuby::array_new", [storage, @body.lower(length), @body.lower(value)])
          end
        end
      end
    end
  end
end
