# frozen_string_literal: true

module BareRuby
  module Compiler
    module ASTIR
      class BareRubyAST
        Program = Data.define(:sources)

        NODE_TYPES = {
          Program => { name: :program, fields: { sources: :children } }
        }.freeze

        def initialize
          @nodes = []
          @spans = []
          @sources = []
          @root = add(Program.new(sources: []), nil)
        end

        def inspect_text
          lines = []
          inspect_node(@root, 0, lines)
          "#{lines.join("\n")}\n"
        end

        private

        def add(node, span)
          @nodes << node
          @spans << span
          @sources << []
          @nodes.size - 1
        end

        def each_child(id)
          values = @nodes[id].to_h
          NODE_TYPES.fetch(@nodes[id].class)[:fields].each do |field, kind|
            case kind
            in :child | :optional_child then yield values[field] if values[field]
            in :children then values[field].each { yield it }
            in :own_scope | :scope | :variable | :value then nil
            end
          end
        end

        def inspect_node(id, depth, lines)
          lines << "#{"  " * depth}#{NODE_TYPES.fetch(@nodes[id].class)[:name]}"
          each_child(id) { inspect_node(it, depth + 1, lines) }
        end
      end
    end
  end
end
