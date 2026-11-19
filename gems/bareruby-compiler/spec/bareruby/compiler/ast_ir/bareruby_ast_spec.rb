# frozen_string_literal: true

RSpec.describe BareRuby::Compiler::ASTIR::BareRubyAST do
  let(:brast) { described_class.new }
  let(:path) { "main.rb" }
  let(:coordinates) { { start_offset: 0, end_offset: 1, start_line: 1, end_line: 1, start_column: 0, end_column: 1 } }
  let(:span) { described_class::Span.new(path:, **coordinates) }
  let(:top) { brast.create_scope(kind: :top_level, variable_parent: nil, lexical_parent: nil) }

  describe "#add_source" do
    subject { brast.add_source(source_unit) }

    let(:body) { brast.create_body(span:, statements: [], scope: top) }
    let(:source_unit) { brast.create_source_unit(span:, path:, body:, scope: top) }

    it { is_expected.to equal(brast) }
  end

  describe "#inspect_text" do
    subject { brast.inspect_text }

    let(:source_body) { brast.create_body(span:, statements: [statement], scope: top) }
    let(:sources) { [brast.create_source_unit(span:, path:, body: source_body, scope: top)] }

    before { sources.each { |source| brast.add_source(source) } }

    let(:one) { brast.create_literal(span:, kind: :integer, value: 1) }
    let(:two) { brast.create_literal(span:, kind: :integer, value: 2) }

    let(:empty_list_fields) { { positionals: [], keywords: [], block: nil, forwarding: false, trailing_comma: false } }
    let(:empty_parameters) { brast.create_parameters(span:, **empty_list_fields) }

    let(:source_header) { <<~TEXT.chomp }
      program
        source_unit path="main.rb" scope=0 @1
          body scope=0 @1
    TEXT

    context "without sources" do
      let(:sources) { [] }

      let(:expected_text) { <<~TEXT }
        program
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with two source units" do
      let(:first_scope) { brast.create_scope(kind: :top_level, variable_parent: nil, lexical_parent: nil) }
      let(:second_scope) { brast.create_scope(kind: :top_level, variable_parent: nil, lexical_parent: nil) }

      let(:first_body) { brast.create_body(span:, statements: [], scope: first_scope) }
      let(:second_body) { brast.create_body(span:, statements: [], scope: second_scope) }
      let(:first_source) { brast.create_source_unit(span:, path: "a.rb", body: first_body, scope: first_scope) }
      let(:second_source) { brast.create_source_unit(span:, path: "b.rb", body: second_body, scope: second_scope) }
      let(:sources) { [first_source, second_source] }

      let(:expected_text) { <<~TEXT }
        program
          source_unit path="a.rb" scope=0 @1
            body scope=0 @1
          source_unit path="b.rb" scope=1 @1
            body scope=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with nodes that start on line 2 and end on line 3" do
      let(:span) { super().with(start_line: 2, end_line: 3) }
      let(:statement) { one }

      let(:expected_text) { <<~TEXT }
        program
          source_unit path="main.rb" scope=0 @2
            body scope=0 @2
              literal kind=integer value=1 @2
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a nil literal" do
      let(:statement) { brast.create_literal(span:, kind: :nil, value: nil) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=nil value=nil @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an integer literal" do
      let(:statement) { brast.create_literal(span:, kind: :integer, value: 1) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a float literal" do
      let(:statement) { brast.create_literal(span:, kind: :float, value: "1.5") }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=float value="1.5" @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a string literal" do
      let(:statement) { brast.create_literal(span:, kind: :string, value: "a".b.freeze) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=string value="a" @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a symbol literal" do
      let(:statement) { brast.create_literal(span:, kind: :symbol, value: :a) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=symbol value=a @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a read of a local variable" do
      let(:variable) { brast.declare_local(scope: top, name: :x, kind: :assignment) }

      let(:statement) { brast.create_local_read(span:, variable:) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              local_read variable=0(x) @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a read of an instance variable" do
      let(:statement) { brast.create_instance_variable_read(span:, name: :@a) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              instance_variable_read name=@a @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a read of a class variable" do
      let(:statement) { brast.create_class_variable_read(span:, name: :@@a) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              class_variable_read name=@@a @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an assignment of 1" do
      let(:statement) { brast.create_assignment(span:, target:, value: one) }

      context "to a local variable" do
        let(:variable) { brast.declare_local(scope: top, name: :x, kind: :assignment) }

        let(:target) { brast.create_local_target(span:, variable:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                assignment @1
                  local_target variable=0(x) @1
                  literal kind=integer value=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "to an instance variable" do
        let(:target) { brast.create_instance_variable_target(span:, name: :@a) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                assignment @1
                  instance_variable_target name=@a @1
                  literal kind=integer value=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "to a class variable" do
        let(:target) { brast.create_class_variable_target(span:, name: :@@a) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                assignment @1
                  class_variable_target name=@@a @1
                  literal kind=integer value=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "to a constant" do
        let(:lexical_scope) { top }
        let(:constant) { brast.create_constant_reference(span:, form: :lexical, parent: nil, name: :A, lexical_scope:) }
        let(:target) { brast.create_constant_target(span:, constant:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                assignment @1
                  constant_target @1
                    constant_reference form=lexical name=A lexical_scope=0 @1
                  literal kind=integer value=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "to an attribute" do
        let(:receiver) { brast.create_self_reference(span:) }
        let(:target) { brast.create_attribute_target(span:, receiver:, name: :a, safe_navigation: false) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                assignment @1
                  attribute_target name=a safe_navigation=false @1
                    self_reference @1
                  literal kind=integer value=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "to an index" do
        let(:receiver) { brast.create_self_reference(span:) }
        let(:zero) { brast.create_literal(span:, kind: :integer, value: 0) }
        let(:arguments) { brast.create_arguments(span:, positionals: [zero], keywords: [], forwarding: false) }
        let(:target) { brast.create_index_target(span:, receiver:, arguments:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                assignment @1
                  index_target @1
                    self_reference @1
                    arguments forwarding=false @1
                      literal kind=integer value=0 @1
                  literal kind=integer value=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end
    end

    context "with a compound assignment" do
      let(:target) { brast.create_instance_variable_target(span:, name: :@a) }
      let(:statement) { brast.create_compound_assignment(span:, target:, operator: :+, value: one) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              compound_assignment operator=+ @1
                instance_variable_target name=@a @1
                literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a logical assignment" do
      let(:target) { brast.create_instance_variable_target(span:, name: :@a) }
      let(:statement) { brast.create_logical_assignment(span:, target:, operator: :or, value: one) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              logical_assignment operator=or @1
                instance_variable_target name=@a @1
                literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a definition in its own scope" do
      let(:scope) { brast.create_scope(kind:, variable_parent: nil, lexical_parent: top) }

      let(:body) { brast.create_body(span:, statements: [], scope:) }
      let(:lexical_lookup) { { form: :lexical, parent: nil, lexical_scope: top } }

      context "for a class with a superclass" do
        let(:kind) { :class }
        let(:name) { brast.create_constant_reference(span:, name: :C, **lexical_lookup) }
        let(:superclass) { brast.create_constant_reference(span:, name: :B, **lexical_lookup) }
        let(:statement) { brast.create_class_definition(span:, name:, superclass:, body:, scope:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                class_definition scope=1 @1
                  constant_reference form=lexical name=C lexical_scope=0 @1
                  constant_reference form=lexical name=B lexical_scope=0 @1
                  body scope=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "for a module" do
        let(:kind) { :module }
        let(:name) { brast.create_constant_reference(span:, name: :M, **lexical_lookup) }
        let(:statement) { brast.create_module_definition(span:, name:, body:, scope:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                module_definition scope=1 @1
                  constant_reference form=lexical name=M lexical_scope=0 @1
                  body scope=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "for the singleton class of self" do
        let(:kind) { :singleton_class }
        let(:target) { brast.create_self_reference(span:) }
        let(:statement) { brast.create_singleton_class_definition(span:, target:, body:, scope:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                singleton_class_definition scope=1 @1
                  self_reference @1
                  body scope=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end
    end

    context "with a method definition" do
      let(:scope) { brast.create_scope(kind: :method, variable_parent: nil, lexical_parent: top) }

      let(:body) { brast.create_body(span:, statements: [], scope:) }
      let(:statement) { brast.create_method_definition(span:, target:, name: :m, parameters:, body:, scope:) }

      context "on self" do
        let(:target) { brast.create_self_reference(span:) }
        let(:parameters) { empty_parameters }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                method_definition name=m scope=1 @1
                  self_reference @1
                  parameters forwarding=false trailing_comma=false @1
                  body scope=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "with required, optional, keyword and block parameters" do
        let(:parameter_names) { %i[a b k blk] }
        let(:ids) { parameter_names.to_h { |name| [name, brast.declare_local(scope:, name:, kind: :parameter)] } }

        let(:target) { nil }

        let(:required) { brast.create_parameter(span:, kind: :required, variable: ids.fetch(:a), default: nil) }
        let(:optional) { brast.create_parameter(span:, kind: :optional, variable: ids.fetch(:b), default: one) }
        let(:keyword) { brast.create_parameter(span:, kind: :keyword_required, variable: ids.fetch(:k), default: nil) }
        let(:block) { brast.create_parameter(span:, kind: :block, variable: ids.fetch(:blk), default: nil) }
        let(:positionals) { [required, optional] }
        let(:keywords) { [keyword] }
        let(:flags) { { forwarding: false, trailing_comma: false } }
        let(:parameters) { brast.create_parameters(span:, positionals:, keywords:, block:, **flags) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                method_definition name=m scope=1 @1
                  parameters forwarding=false trailing_comma=false @1
                    parameter kind=required variable=0(a) @1
                    parameter kind=optional variable=1(b) @1
                      literal kind=integer value=1 @1
                    parameter kind=keyword_required variable=2(k) @1
                    parameter kind=block variable=3(blk) @1
                  body scope=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end
    end

    context "with a native method definition" do
      let(:int) { { name: :Int, nilable: false }.freeze }
      let(:signature) { { parameters: [[:other, int].freeze].freeze, returns: int }.freeze }
      let(:statement) { brast.create_native_definition(span:, name: :+, function: :integer_add, signature:) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              native_definition name=+ function=integer_add signature={parameters: [[:other, {name: :Int, nilable: false}]], returns: {name: :Int, nilable: false}} @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a constant reference from the top level with ::" do
      let(:statement) { brast.create_constant_reference(span:, form: :root, parent: nil, name: :A, lexical_scope: top) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              constant_reference form=root name=A lexical_scope=0 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a constant reference qualified by another constant" do
      let(:lexical_scope) { top }
      let(:parent) { brast.create_constant_reference(span:, form: :lexical, parent: nil, name: :A, lexical_scope:) }
      let(:statement) { brast.create_constant_reference(span:, form: :qualified, parent:, name: :B, lexical_scope:) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              constant_reference form=qualified name=B lexical_scope=0 @1
                constant_reference form=lexical name=A lexical_scope=0 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a positional argument" do
      let(:keywords) { [] }
      let(:arguments) { brast.create_arguments(span:, positionals: [one], keywords:, forwarding: false) }

      context "on a safe navigation call with a block" do
        let(:scope) { brast.create_scope(kind: :block, variable_parent: top, lexical_parent: top) }

        let(:receiver) { brast.create_self_reference(span:) }

        let(:body) { brast.create_body(span:, statements: [], scope:) }
        let(:block_literal) { brast.create_block(span:, parameters: empty_parameters, body:, scope:) }
        let(:block) { brast.create_block_argument(span:, kind: :literal, value: block_literal) }
        let(:statement) { brast.create_call(span:, receiver:, name: :m, arguments:, block:, safe_navigation: true) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                call name=m safe_navigation=true @1
                  self_reference @1
                  arguments forwarding=false @1
                    literal kind=integer value=1 @1
                  block_argument kind=literal @1
                    block scope=1 @1
                      parameters forwarding=false trailing_comma=false @1
                      body scope=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "on a call with a keyword argument" do
        let(:keyword) { brast.create_keyword_argument(span:, name: :k, value: two) }
        let(:keywords) { [keyword] }
        let(:safe_navigation) { false }
        let(:statement) { brast.create_call(span:, receiver: nil, name: :m, arguments:, block: nil, safe_navigation:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                call name=m safe_navigation=false @1
                  arguments forwarding=false @1
                    literal kind=integer value=1 @1
                    keyword_argument name=k @1
                      literal kind=integer value=2 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "on a super call with a block passed by expression" do
        let(:value) { brast.create_literal(span:, kind: :nil, value: nil) }
        let(:block) { brast.create_block_argument(span:, kind: :expression, value:) }
        let(:statement) { brast.create_super_call(span:, arguments:, block:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                super_call @1
                  arguments forwarding=false @1
                    literal kind=integer value=1 @1
                  block_argument kind=expression @1
                    literal kind=nil value=nil @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "on yield" do
        let(:statement) { brast.create_yield_call(span:, arguments:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                yield_call @1
                  arguments forwarding=false @1
                    literal kind=integer value=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "on a primitive call" do
        let(:statement) { brast.create_primitive_call(span:, name: :new_instance, arguments:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                primitive_call name=new_instance @1
                  arguments forwarding=false @1
                    literal kind=integer value=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end
    end

    context "with a lambda" do
      let(:scope) { brast.create_scope(kind: :lambda, variable_parent: top, lexical_parent: top) }

      let(:body) { brast.create_body(span:, statements: [], scope:) }
      let(:statement) { brast.create_lambda(span:, parameters: empty_parameters, body:, scope:) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              lambda scope=1 @1
                parameters forwarding=false trailing_comma=false @1
                body scope=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with self as the condition" do
      let(:condition) { brast.create_self_reference(span:) }

      context "in an if with both branches" do
        let(:consequent) { brast.create_body(span:, statements: [one], scope: top) }
        let(:alternative) { brast.create_body(span:, statements: [two], scope: top) }
        let(:statement) { brast.create_conditional(span:, condition:, consequent:, alternative:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                conditional @1
                  self_reference @1
                  body scope=0 @1
                    literal kind=integer value=1 @1
                  body scope=0 @1
                    literal kind=integer value=2 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "in an if without branches" do
        let(:statement) { brast.create_conditional(span:, condition:, consequent: nil, alternative: nil) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                conditional @1
                  self_reference @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "in an unless with an else branch" do
        let(:body) { brast.create_body(span:, statements: [one], scope: top) }
        let(:alternative) { brast.create_body(span:, statements: [two], scope: top) }
        let(:statement) { brast.create_unless_conditional(span:, condition:, body:, alternative:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                unless_conditional @1
                  self_reference @1
                  body scope=0 @1
                    literal kind=integer value=1 @1
                  body scope=0 @1
                    literal kind=integer value=2 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "in a when clause followed by else" do
        let(:when_body) { brast.create_body(span:, statements: [one], scope: top) }
        let(:when_clause) { brast.create_when_clause(span:, conditions: [condition], body: when_body) }
        let(:alternative) { brast.create_body(span:, statements: [two], scope: top) }
        let(:statement) { brast.create_case_branch(span:, whens: [when_clause], alternative:) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                case_branch @1
                  when_clause @1
                    self_reference @1
                    body scope=0 @1
                      literal kind=integer value=1 @1
                  body scope=0 @1
                    literal kind=integer value=2 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "in a while loop" do
        let(:body) { brast.create_body(span:, statements: [one], scope: top) }
        let(:statement) { brast.create_loop(span:, kind: :while, condition:, body:, test: :before) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                loop kind=while test=before @1
                  self_reference @1
                  body scope=0 @1
                    literal kind=integer value=1 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end
    end

    context "with a short-circuit operator" do
      let(:statement) { brast.create_logical(span:, operator: :and, left: one, right: two) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              logical operator=and @1
                literal kind=integer value=1 @1
                literal kind=integer value=2 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a for loop" do
      let(:variable) { brast.declare_local(scope: top, name: :i, kind: :for) }

      let(:collection) { brast.create_self_reference(span:) }
      let(:body) { brast.create_body(span:, statements: [one], scope: top) }
      let(:statement) { brast.create_for_loop(span:, variable:, collection:, body:) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              for_loop variable=0(i) @1
                self_reference @1
                body scope=0 @1
                  literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a parenthesized sequence" do
      let(:body) { brast.create_body(span:, statements: [one, two], scope: top) }
      let(:statement) { brast.create_sequence(span:, body:) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              sequence @1
                body scope=0 @1
                  literal kind=integer value=1 @1
                  literal kind=integer value=2 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a break that passes a value" do
      let(:statement) { brast.create_transfer(span:, kind: :break, value: one) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              transfer kind=break @1
                literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an exception region" do
      let(:rescues) { [rescue_clause] }
      let(:statement) { brast.create_exception_region(span:, body:, rescues:, alternative:, ensure_body:) }

      context "with a rescue variable, else and ensure" do
        let(:variable) { brast.declare_local(scope: top, name: :e, kind: :rescue) }

        let(:three) { brast.create_literal(span:, kind: :integer, value: 3) }
        let(:four) { brast.create_literal(span:, kind: :integer, value: 4) }

        let(:body) { brast.create_body(span:, statements: [one], scope: top) }

        let(:lexical_scope) { top }
        let(:name) { :StandardError }
        let(:exception) { brast.create_constant_reference(span:, form: :lexical, parent: nil, name:, lexical_scope:) }
        let(:exception_classes) { [exception] }
        let(:rescue_body) { brast.create_body(span:, statements: [two], scope: top) }
        let(:rescue_clause) { brast.create_rescue_clause(span:, exception_classes:, variable:, body: rescue_body) }

        let(:alternative) { brast.create_body(span:, statements: [three], scope: top) }
        let(:ensure_body) { brast.create_body(span:, statements: [four], scope: top) }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                exception_region @1
                  body scope=0 @1
                    literal kind=integer value=1 @1
                  rescue_clause variable=0(e) @1
                    constant_reference form=lexical name=StandardError lexical_scope=0 @1
                    body scope=0 @1
                      literal kind=integer value=2 @1
                  body scope=0 @1
                    literal kind=integer value=3 @1
                  body scope=0 @1
                    literal kind=integer value=4 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end

      context "with a rescue clause without a variable" do
        let(:body) { brast.create_body(span:, statements: [], scope: top) }
        let(:rescue_body) { brast.create_body(span:, statements: [], scope: top) }
        let(:exception_classes) { [] }
        let(:rescue_clause) { brast.create_rescue_clause(span:, exception_classes:, variable: nil, body: rescue_body) }
        let(:alternative) { nil }
        let(:ensure_body) { nil }

        let(:expected_text) { <<~TEXT }
          #{source_header}
                exception_region @1
                  body scope=0 @1
                  rescue_clause @1
                    body scope=0 @1
        TEXT

        it { is_expected.to eq(expected_text) }
      end
    end

    context "with a rescue modifier" do
      let(:statement) { brast.create_rescue_modifier(span:, expression: one, rescue_value: two) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              rescue_modifier @1
                literal kind=integer value=1 @1
                literal kind=integer value=2 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an interpolated string" do
      let(:text) { brast.create_literal(span:, kind: :string, value: "a".b.freeze) }
      let(:statement) { brast.create_interpolation(span:, parts: [text, one]) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              interpolation @1
                literal kind=string value="a" @1
                literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an array literal" do
      let(:statement) { brast.create_array_literal(span:, elements: [one, two]) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              array_literal @1
                literal kind=integer value=1 @1
                literal kind=integer value=2 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a range literal" do
      let(:statement) { brast.create_range_literal(span:, low: one, high: two, exclusive: false) }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              range_literal exclusive=false @1
                literal kind=integer value=1 @1
                literal kind=integer value=2 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end
  end
end
