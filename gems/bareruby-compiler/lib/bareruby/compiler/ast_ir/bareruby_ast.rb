# frozen_string_literal: true

module BareRuby
  module Compiler
    module ASTIR
      # BRAST stays one class instead of builder, rewriter and analysis classes, so it grows with each node kind.
      class BareRubyAST # rubocop:disable Metrics/ClassLength
        Program = Data.define(:sources)
        SourceUnit = Data.define(:path, :body, :scope)
        Body = Data.define(:statements, :scope)
        ClassDefinition = Data.define(:name, :superclass, :body, :scope)
        ModuleDefinition = Data.define(:name, :body, :scope)
        SingletonClassDefinition = Data.define(:target, :body, :scope)
        MethodDefinition = Data.define(:target, :name, :parameters, :body, :scope)
        NativeDefinition = Data.define(:name, :function, :signature)
        Parameters = Data.define(:positionals, :keywords, :block, :forwarding, :trailing_comma)
        Parameter = Data.define(:kind, :variable, :default)
        LocalRead = Data.define(:variable)
        ConstantReference = Data.define(:form, :parent, :name, :lexical_scope)
        SelfReference = Data.define
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
          ClassDefinition => { name: :class_definition,
                               fields: { name: :child, superclass: :optional_child, body: :child, scope: :own_scope } },
          ModuleDefinition => { name: :module_definition, fields: { name: :child, body: :child, scope: :own_scope } },
          SingletonClassDefinition => { name: :singleton_class_definition,
                                        fields: { target: :child, body: :child, scope: :own_scope } },
          MethodDefinition => { name: :method_definition,
                                fields: { target: :optional_child, name: :value, parameters: :child, body: :child,
                                          scope: :own_scope } },
          NativeDefinition => { name: :native_definition,
                                fields: { name: :value, function: :value, signature: :value } },
          Parameters => { name: :parameters,
                          fields: { positionals: :children, keywords: :children, block: :optional_child,
                                    forwarding: :value, trailing_comma: :value } },
          Parameter => { name: :parameter, fields: { kind: :value, variable: :variable, default: :optional_child } },
          LocalRead => { name: :local_read, fields: { variable: :variable } },
          ConstantReference => { name: :constant_reference,
                                 fields: { form: :value, parent: :optional_child, name: :value,
                                           lexical_scope: :scope } },
          SelfReference => { name: :self_reference, fields: {} },
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

        def create_class_definition(span:, name:, superclass:, body:, scope:)
          add(ClassDefinition.new(name:, superclass:, body:, scope:), span)
        end

        def create_module_definition(span:, name:, body:, scope:)
          add(ModuleDefinition.new(name:, body:, scope:), span)
        end

        def create_singleton_class_definition(span:, target:, body:, scope:)
          add(SingletonClassDefinition.new(target:, body:, scope:), span)
        end

        # rubocop:disable-next Metrics/ParameterLists -- the keywords are the node's fields, which a pass passes by name
        def create_method_definition(span:, target:, name:, parameters:, body:, scope:)
          add(MethodDefinition.new(target:, name:, parameters:, body:, scope:), span)
        end

        def create_native_definition(span:, name:, function:, signature:)
          add(NativeDefinition.new(name:, function:, signature:), span)
        end

        # rubocop:disable-next Metrics/ParameterLists -- the keywords are the node's fields, which a pass passes by name
        def create_parameters(span:, positionals:, keywords:, block:, forwarding:, trailing_comma:)
          add(Parameters.new(positionals:, keywords:, block:, forwarding:, trailing_comma:), span)
        end

        def create_parameter(span:, kind:, variable:, default:) = add(Parameter.new(kind:, variable:, default:), span)

        def create_local_read(span:, variable:) = add(LocalRead.new(variable:), span)

        def create_constant_reference(span:, form:, parent:, name:, lexical_scope:)
          add(ConstantReference.new(form:, parent:, name:, lexical_scope:), span)
        end

        def create_self_reference(span:) = add(SelfReference.new, span)

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
