# frozen_string_literal: true

module BareRuby
  module Compiler
    module ASTIR
      class BareRubyAST
        Program = Data.define(:sources)
        SourceUnit = Data.define(:path, :body, :scope)
        Body = Data.define(:statements, :scope)
        LocalRead = Data.define(:variable)
        Assignment = Data.define(:target, :value)
        LocalTarget = Data.define(:variable)
        Literal = Data.define(:kind, :value)

        Span = Data.define(:path, :start_offset, :end_offset, :start_line, :start_column, :end_line, :end_column)
        Scope = Data.define(:kind, :variable_parent, :lexical_parent)
        Variable = Data.define(:name, :kind, :scope)

        NODE_TYPES = {
          Program => { name: :program, fields: { sources: :children } },
          SourceUnit => { name: :source_unit, fields: { path: :value, body: :child, scope: :own_scope } },
          Body => { name: :body, fields: { statements: :children, scope: :scope } },
          LocalRead => { name: :local_read, fields: { variable: :variable } },
          Assignment => { name: :assignment, fields: { target: :child, value: :child } },
          LocalTarget => { name: :local_target, fields: { variable: :variable } },
          Literal => { name: :literal, fields: { kind: :value, value: :value } }
        }.freeze

        def initialize
          @nodes = []
          @spans = []
          @sources = []
          @scopes = []
          @variables = []
          @root = add(Program.new(sources: []), nil)
        end

        def create_scope(kind:, variable_parent:, lexical_parent:)
          @scopes << Scope.new(kind:, variable_parent:, lexical_parent:)
          @scopes.size - 1
        end

        def declare_local(scope:, name:, kind:)
          @variables << Variable.new(name:, kind:, scope:)
          @variables.size - 1
        end

        def add_source(source_unit)
          program = @nodes[@root]
          @root = add(program.with(sources: program.sources + [source_unit]), nil)
          self
        end

        def create_source_unit(span:, path:, body:, scope:) = add(SourceUnit.new(path:, body:, scope:), span)
        def create_body(span:, statements:, scope:) = add(Body.new(statements:, scope:), span)
        def create_local_read(span:, variable:) = add(LocalRead.new(variable:), span)
        def create_assignment(span:, target:, value:) = add(Assignment.new(target:, value:), span)
        def create_local_target(span:, variable:) = add(LocalTarget.new(variable:), span)
        def create_literal(span:, kind:, value:) = add(Literal.new(kind:, value:), span)

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
          lines << "#{"  " * depth}#{inspect_line(id)}"
          each_child(id) { inspect_node(it, depth + 1, lines) }
        end

        def inspect_line(id)
          type = NODE_TYPES.fetch(@nodes[id].class)
          values = @nodes[id].to_h
          fields = type[:fields].map { |field, kind| inspect_field(field, kind, values[field]) }
          ([type[:name]] + fields + [inspect_span(@spans[id])]).compact.join(" ")
        end

        def inspect_span(span) = ("@#{span.start_line}" if span)

        def inspect_field(field, kind, value)
          case kind
          in :value then "#{field}=#{inspect_value(value)}"
          in :own_scope | :scope then "#{field}=#{value}"
          in :variable then "#{field}=#{value}(#{@variables[value].name})" if value
          in :child | :optional_child | :children then nil
          end
        end

        def inspect_value(value)
          case value
          in Symbol then value.to_s
          else value.inspect
          end
        end
      end
    end
  end
end
