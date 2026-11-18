# frozen_string_literal: true

module BareRuby
  module Compiler
    module ASTIR
      # BRAST stays one class instead of builder, rewriter and analysis classes, so it grows with each node kind.
      class BareRubyAST # rubocop:disable Metrics/ClassLength
        Program = Data.define(:sources)
        SourceUnit = Data.define(:path, :body, :scope)
        Body = Data.define(:statements, :scope)
        Sequence = Data.define(:body)
        ClassDefinition = Data.define(:name, :superclass, :body, :scope)
        ModuleDefinition = Data.define(:name, :body, :scope)
        SingletonClassDefinition = Data.define(:target, :body, :scope)
        MethodDefinition = Data.define(:target, :name, :parameters, :body, :scope)
        NativeDefinition = Data.define(:name, :function, :signature)
        Call = Data.define(:receiver, :name, :arguments, :block, :safe_navigation)
        SuperCall = Data.define(:arguments, :block)
        YieldCall = Data.define(:arguments)
        PrimitiveCall = Data.define(:name, :arguments)
        Arguments = Data.define(:positionals, :keywords, :forwarding)
        KeywordArgument = Data.define(:name, :value)
        BlockArgument = Data.define(:kind, :value)
        Parameters = Data.define(:positionals, :keywords, :block, :forwarding, :trailing_comma)
        Parameter = Data.define(:kind, :variable, :default)
        Block = Data.define(:parameters, :body, :scope)
        Lambda = Data.define(:parameters, :body, :scope)
        LocalRead = Data.define(:variable)
        InstanceVariableRead = Data.define(:name)
        ClassVariableRead = Data.define(:name)
        ConstantReference = Data.define(:form, :parent, :name, :lexical_scope)
        SelfReference = Data.define
        Assignment = Data.define(:target, :value)
        CompoundAssignment = Data.define(:target, :operator, :value)
        LogicalAssignment = Data.define(:target, :operator, :value)
        LocalTarget = Data.define(:variable)
        InstanceVariableTarget = Data.define(:name)
        ClassVariableTarget = Data.define(:name)
        ConstantTarget = Data.define(:constant)
        AttributeTarget = Data.define(:receiver, :name, :safe_navigation)
        IndexTarget = Data.define(:receiver, :arguments)
        Conditional = Data.define(:condition, :consequent, :alternative)
        UnlessConditional = Data.define(:condition, :body, :alternative)
        CaseBranch = Data.define(:whens, :alternative)
        WhenClause = Data.define(:conditions, :body)
        Logical = Data.define(:operator, :left, :right)
        Loop = Data.define(:kind, :condition, :body, :test)
        ForLoop = Data.define(:variable, :collection, :body)
        Transfer = Data.define(:kind, :value)
        ExceptionRegion = Data.define(:body, :rescues, :alternative, :ensure_body)
        RescueClause = Data.define(:exception_classes, :variable, :body)
        RescueModifier = Data.define(:expression, :rescue_value)
        Literal = Data.define(:kind, :value)
        Interpolation = Data.define(:parts)
        ArrayLiteral = Data.define(:elements)
        RangeLiteral = Data.define(:low, :high, :exclusive)

        Span = Data.define(:path, :start_offset, :end_offset, :start_line, :start_column, :end_line, :end_column)
        Scope = Data.define(:kind, :variable_parent, :lexical_parent)
        Variable = Data.define(:name, :kind, :scope)

        NODE_TYPES = {
          Program => { name: :program, fields: { sources: :children } },
          SourceUnit => { name: :source_unit, fields: { path: :value, body: :child, scope: :own_scope } },
          Body => { name: :body, fields: { statements: :children, scope: :scope } },
          Sequence => { name: :sequence, fields: { body: :child } },
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
          Call => { name: :call,
                    fields: { receiver: :optional_child, name: :value, arguments: :child, block: :optional_child,
                              safe_navigation: :value } },
          SuperCall => { name: :super_call, fields: { arguments: :optional_child, block: :optional_child } },
          YieldCall => { name: :yield_call, fields: { arguments: :child } },
          PrimitiveCall => { name: :primitive_call, fields: { name: :value, arguments: :child } },
          Arguments => { name: :arguments,
                         fields: { positionals: :children, keywords: :children, forwarding: :value } },
          KeywordArgument => { name: :keyword_argument, fields: { name: :value, value: :child } },
          BlockArgument => { name: :block_argument, fields: { kind: :value, value: :child } },
          Parameters => { name: :parameters,
                          fields: { positionals: :children, keywords: :children, block: :optional_child,
                                    forwarding: :value, trailing_comma: :value } },
          Parameter => { name: :parameter, fields: { kind: :value, variable: :variable, default: :optional_child } },
          Block => { name: :block, fields: { parameters: :child, body: :child, scope: :own_scope } },
          Lambda => { name: :lambda, fields: { parameters: :child, body: :child, scope: :own_scope } },
          LocalRead => { name: :local_read, fields: { variable: :variable } },
          InstanceVariableRead => { name: :instance_variable_read, fields: { name: :value } },
          ClassVariableRead => { name: :class_variable_read, fields: { name: :value } },
          ConstantReference => { name: :constant_reference,
                                 fields: { form: :value, parent: :optional_child, name: :value,
                                           lexical_scope: :scope } },
          SelfReference => { name: :self_reference, fields: {} },
          Assignment => { name: :assignment, fields: { target: :child, value: :child } },
          CompoundAssignment => { name: :compound_assignment,
                                  fields: { target: :child, operator: :value, value: :child } },
          LogicalAssignment => { name: :logical_assignment,
                                 fields: { target: :child, operator: :value, value: :child } },
          LocalTarget => { name: :local_target, fields: { variable: :variable } },
          InstanceVariableTarget => { name: :instance_variable_target, fields: { name: :value } },
          ClassVariableTarget => { name: :class_variable_target, fields: { name: :value } },
          ConstantTarget => { name: :constant_target, fields: { constant: :child } },
          AttributeTarget => { name: :attribute_target,
                               fields: { receiver: :child, name: :value, safe_navigation: :value } },
          IndexTarget => { name: :index_target, fields: { receiver: :child, arguments: :child } },
          Conditional => { name: :conditional,
                           fields: { condition: :child, consequent: :optional_child, alternative: :optional_child } },
          UnlessConditional => { name: :unless_conditional,
                                 fields: { condition: :child, body: :optional_child, alternative: :optional_child } },
          CaseBranch => { name: :case_branch, fields: { whens: :children, alternative: :optional_child } },
          WhenClause => { name: :when_clause, fields: { conditions: :children, body: :child } },
          Logical => { name: :logical, fields: { operator: :value, left: :child, right: :child } },
          Loop => { name: :loop, fields: { kind: :value, condition: :child, body: :child, test: :value } },
          ForLoop => { name: :for_loop, fields: { variable: :variable, collection: :child, body: :child } },
          Transfer => { name: :transfer, fields: { kind: :value, value: :optional_child } },
          ExceptionRegion => { name: :exception_region,
                               fields: { body: :child, rescues: :children, alternative: :optional_child,
                                         ensure_body: :optional_child } },
          RescueClause => { name: :rescue_clause,
                            fields: { exception_classes: :children, variable: :variable, body: :child } },
          RescueModifier => { name: :rescue_modifier, fields: { expression: :child, rescue_value: :child } },
          Literal => { name: :literal, fields: { kind: :value, value: :value } },
          Interpolation => { name: :interpolation, fields: { parts: :children } },
          ArrayLiteral => { name: :array_literal, fields: { elements: :children } },
          RangeLiteral => { name: :range_literal,
                            fields: { low: :optional_child, high: :optional_child, exclusive: :value } }
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
        def create_sequence(span:, body:) = add(Sequence.new(body:), span)

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
        def create_call(span:, receiver:, name:, arguments:, block:, safe_navigation:)
          add(Call.new(receiver:, name:, arguments:, block:, safe_navigation:), span)
        end

        def create_super_call(span:, arguments:, block:) = add(SuperCall.new(arguments:, block:), span)
        def create_yield_call(span:, arguments:) = add(YieldCall.new(arguments:), span)
        def create_primitive_call(span:, name:, arguments:) = add(PrimitiveCall.new(name:, arguments:), span)

        def create_arguments(span:, positionals:, keywords:, forwarding:)
          add(Arguments.new(positionals:, keywords:, forwarding:), span)
        end

        def create_keyword_argument(span:, name:, value:) = add(KeywordArgument.new(name:, value:), span)
        def create_block_argument(span:, kind:, value:) = add(BlockArgument.new(kind:, value:), span)

        # rubocop:disable-next Metrics/ParameterLists -- the keywords are the node's fields, which a pass passes by name
        def create_parameters(span:, positionals:, keywords:, block:, forwarding:, trailing_comma:)
          add(Parameters.new(positionals:, keywords:, block:, forwarding:, trailing_comma:), span)
        end

        def create_parameter(span:, kind:, variable:, default:) = add(Parameter.new(kind:, variable:, default:), span)

        def create_block(span:, parameters:, body:, scope:) = add(Block.new(parameters:, body:, scope:), span)
        def create_lambda(span:, parameters:, body:, scope:) = add(Lambda.new(parameters:, body:, scope:), span)

        def create_local_read(span:, variable:) = add(LocalRead.new(variable:), span)
        def create_instance_variable_read(span:, name:) = add(InstanceVariableRead.new(name:), span)
        def create_class_variable_read(span:, name:) = add(ClassVariableRead.new(name:), span)

        def create_constant_reference(span:, form:, parent:, name:, lexical_scope:)
          add(ConstantReference.new(form:, parent:, name:, lexical_scope:), span)
        end

        def create_self_reference(span:) = add(SelfReference.new, span)

        def create_assignment(span:, target:, value:) = add(Assignment.new(target:, value:), span)

        def create_compound_assignment(span:, target:, operator:, value:)
          add(CompoundAssignment.new(target:, operator:, value:), span)
        end

        def create_logical_assignment(span:, target:, operator:, value:)
          add(LogicalAssignment.new(target:, operator:, value:), span)
        end

        def create_local_target(span:, variable:) = add(LocalTarget.new(variable:), span)
        def create_instance_variable_target(span:, name:) = add(InstanceVariableTarget.new(name:), span)
        def create_class_variable_target(span:, name:) = add(ClassVariableTarget.new(name:), span)
        def create_constant_target(span:, constant:) = add(ConstantTarget.new(constant:), span)

        def create_attribute_target(span:, receiver:, name:, safe_navigation:)
          add(AttributeTarget.new(receiver:, name:, safe_navigation:), span)
        end

        def create_index_target(span:, receiver:, arguments:) = add(IndexTarget.new(receiver:, arguments:), span)

        def create_conditional(span:, condition:, consequent:, alternative:)
          add(Conditional.new(condition:, consequent:, alternative:), span)
        end

        def create_unless_conditional(span:, condition:, body:, alternative:)
          add(UnlessConditional.new(condition:, body:, alternative:), span)
        end

        def create_case_branch(span:, whens:, alternative:) = add(CaseBranch.new(whens:, alternative:), span)
        def create_when_clause(span:, conditions:, body:) = add(WhenClause.new(conditions:, body:), span)
        def create_logical(span:, operator:, left:, right:) = add(Logical.new(operator:, left:, right:), span)

        def create_loop(span:, kind:, condition:, body:, test:)
          add(Loop.new(kind:, condition:, body:, test:), span)
        end

        def create_for_loop(span:, variable:, collection:, body:)
          add(ForLoop.new(variable:, collection:, body:), span)
        end

        def create_transfer(span:, kind:, value:) = add(Transfer.new(kind:, value:), span)

        def create_exception_region(span:, body:, rescues:, alternative:, ensure_body:)
          add(ExceptionRegion.new(body:, rescues:, alternative:, ensure_body:), span)
        end

        def create_rescue_clause(span:, exception_classes:, variable:, body:)
          add(RescueClause.new(exception_classes:, variable:, body:), span)
        end

        def create_rescue_modifier(span:, expression:, rescue_value:)
          add(RescueModifier.new(expression:, rescue_value:), span)
        end

        def create_literal(span:, kind:, value:) = add(Literal.new(kind:, value:), span)
        def create_interpolation(span:, parts:) = add(Interpolation.new(parts:), span)
        def create_array_literal(span:, elements:) = add(ArrayLiteral.new(elements:), span)

        def create_range_literal(span:, low:, high:, exclusive:)
          add(RangeLiteral.new(low:, high:, exclusive:), span)
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
