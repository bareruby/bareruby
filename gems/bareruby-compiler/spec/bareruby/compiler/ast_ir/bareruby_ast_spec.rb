# frozen_string_literal: true

RSpec.describe BareRuby::Compiler::ASTIR::BareRubyAST do
  let(:brast) { described_class.new }

  let(:path) { "main.rb" }
  let(:start_offset) { 0 }
  let(:end_offset) { 1 }
  let(:start_line) { 1 }
  let(:start_column) { 0 }
  let(:end_line) { 1 }
  let(:end_column) { 1 }
  let(:span_fields) { { path:, start_offset:, end_offset:, start_line:, start_column:, end_line:, end_column: } }
  let(:span) { described_class::Span.new(**span_fields) }

  describe "#add_source" do
    subject { brast.add_source(source_unit) }

    let(:scope) { brast.create_scope(kind: :top_level, variable_parent: nil, lexical_parent: nil) }
    let(:body) { brast.create_body(span:, statements: [], scope:) }
    let(:source_unit) { brast.create_source_unit(span:, path:, body:, scope:) }

    it { is_expected.to equal(brast) }
  end

  describe "#inspect_text" do
    subject { sources.reduce(brast) { |ast, source| ast.add_source(source) }.inspect_text }

    let(:top) { brast.create_scope(kind: :top_level, variable_parent: nil, lexical_parent: nil) }
    let(:statements) { [statement] }
    let(:source_body) { brast.create_body(span:, statements:, scope: top) }
    let(:sources) { [brast.create_source_unit(span:, path:, body: source_body, scope: top)] }

    let(:source_unit_text) { <<~TEXT }
      program
        source_unit path="main.rb" scope=0 @1
          body scope=0 @1
    TEXT

    let(:expected_text) { source_unit_text + statements_text.gsub(/^/, "      ") }

    context "without sources" do
      let(:sources) { [] }

      let(:expected_text) { <<~TEXT }
        program
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with two source units" do
      let!(:first_scope) { brast.create_scope(kind: :top_level, variable_parent: nil, lexical_parent: nil) }
      let!(:second_scope) { brast.create_scope(kind: :top_level, variable_parent: nil, lexical_parent: nil) }

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
      let(:start_line) { 2 }
      let(:end_line) { 3 }
      let(:statement) { brast.create_literal(span:, kind: :integer, value: 1) }

      let(:expected_text) { <<~TEXT }
        program
          source_unit path="main.rb" scope=0 @2
            body scope=0 @2
              literal kind=integer value=1 @2
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a nil literal" do
      let(:kind) { :nil }
      let(:value) { nil }
      let(:statement) { brast.create_literal(span:, kind:, value:) }

      let(:statements_text) { <<~TEXT }
        literal kind=nil value=nil @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an integer literal" do
      let(:kind) { :integer }
      let(:value) { 1 }
      let(:statement) { brast.create_literal(span:, kind:, value:) }

      let(:statements_text) { <<~TEXT }
        literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a float literal" do
      let(:kind) { :float }
      let(:value) { "1.5" }
      let(:statement) { brast.create_literal(span:, kind:, value:) }

      let(:statements_text) { <<~TEXT }
        literal kind=float value="1.5" @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a string literal" do
      let(:kind) { :string }
      let(:value) { "a".b.freeze }
      let(:statement) { brast.create_literal(span:, kind:, value:) }

      let(:statements_text) { <<~TEXT }
        literal kind=string value="a" @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a symbol literal" do
      let(:kind) { :symbol }
      let(:value) { :a }
      let(:statement) { brast.create_literal(span:, kind:, value:) }

      let(:statements_text) { <<~TEXT }
        literal kind=symbol value=a @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a read of a local variable" do
      let!(:variable) { brast.declare_local(scope: top, name: :x, kind: :assignment) }

      let(:statement) { brast.create_local_read(span:, variable:) }

      let(:statements_text) { <<~TEXT }
        local_read variable=0(x) @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an assignment to a local variable" do
      let!(:variable) { brast.declare_local(scope: top, name: :x, kind: :assignment) }

      let(:target) { brast.create_local_target(span:, variable:) }
      let(:value) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:statement) { brast.create_assignment(span:, target:, value:) }

      let(:statements_text) { <<~TEXT }
        assignment @1
          local_target variable=0(x) @1
          literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a class definition with a superclass" do
      let!(:scope) { brast.create_scope(kind: :class, variable_parent: nil, lexical_parent: top) }

      let(:form) { :lexical }
      let(:parent) { nil }
      let(:lexical_scope) { top }
      let(:name) { brast.create_constant_reference(span:, form:, parent:, name: :C, lexical_scope:) }
      let(:superclass) { brast.create_constant_reference(span:, form:, parent:, name: :B, lexical_scope:) }
      let(:body) { brast.create_body(span:, statements: [], scope:) }
      let(:statement) { brast.create_class_definition(span:, name:, superclass:, body:, scope:) }

      let(:statements_text) { <<~TEXT }
        class_definition scope=1 @1
          constant_reference form=lexical name=C lexical_scope=0 @1
          constant_reference form=lexical name=B lexical_scope=0 @1
          body scope=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a module definition" do
      let!(:scope) { brast.create_scope(kind: :module, variable_parent: nil, lexical_parent: top) }

      let(:form) { :lexical }
      let(:parent) { nil }
      let(:lexical_scope) { top }
      let(:name) { brast.create_constant_reference(span:, form:, parent:, name: :M, lexical_scope:) }
      let(:body) { brast.create_body(span:, statements: [], scope:) }
      let(:statement) { brast.create_module_definition(span:, name:, body:, scope:) }

      let(:statements_text) { <<~TEXT }
        module_definition scope=1 @1
          constant_reference form=lexical name=M lexical_scope=0 @1
          body scope=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a singleton class definition of self" do
      let!(:scope) { brast.create_scope(kind: :singleton_class, variable_parent: nil, lexical_parent: top) }

      let(:target) { brast.create_self_reference(span:) }
      let(:body) { brast.create_body(span:, statements: [], scope:) }
      let(:statement) { brast.create_singleton_class_definition(span:, target:, body:, scope:) }

      let(:statements_text) { <<~TEXT }
        singleton_class_definition scope=1 @1
          self_reference @1
          body scope=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a method definition on self" do
      let!(:scope) { brast.create_scope(kind: :method, variable_parent: nil, lexical_parent: top) }

      let(:target) { brast.create_self_reference(span:) }
      let(:name) { :m }
      let(:positionals) { [] }
      let(:keywords) { [] }
      let(:block) { nil }
      let(:forwarding) { false }
      let(:trailing_comma) { false }
      let(:parameters) { brast.create_parameters(span:, positionals:, keywords:, block:, forwarding:, trailing_comma:) }
      let(:body) { brast.create_body(span:, statements: [], scope:) }
      let(:statement) { brast.create_method_definition(span:, target:, name:, parameters:, body:, scope:) }

      let(:statements_text) { <<~TEXT }
        method_definition name=m scope=1 @1
          self_reference @1
          parameters forwarding=false trailing_comma=false @1
          body scope=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a method definition that takes a parameter of each kind" do
      let!(:scope) { brast.create_scope(kind: :method, variable_parent: nil, lexical_parent: top) }
      let!(:a) { brast.declare_local(scope:, name: :a, kind: :parameter) }
      let!(:b) { brast.declare_local(scope:, name: :b, kind: :parameter) }
      let!(:k) { brast.declare_local(scope:, name: :k, kind: :parameter) }
      let!(:blk) { brast.declare_local(scope:, name: :blk, kind: :parameter) }

      let(:target) { nil }
      let(:name) { :m }
      let(:default) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:required) { brast.create_parameter(span:, kind: :required, variable: a, default: nil) }
      let(:optional) { brast.create_parameter(span:, kind: :optional, variable: b, default:) }
      let(:keyword_required) { brast.create_parameter(span:, kind: :keyword_required, variable: k, default: nil) }
      let(:positionals) { [required, optional] }
      let(:keywords) { [keyword_required] }
      let(:block) { brast.create_parameter(span:, kind: :block, variable: blk, default: nil) }
      let(:forwarding) { false }
      let(:trailing_comma) { false }
      let(:parameters) { brast.create_parameters(span:, positionals:, keywords:, block:, forwarding:, trailing_comma:) }
      let(:body) { brast.create_body(span:, statements: [], scope:) }
      let(:statement) { brast.create_method_definition(span:, target:, name:, parameters:, body:, scope:) }

      let(:statements_text) { <<~TEXT }
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

    context "with a native method definition" do
      let(:name) { :+ }
      let(:function) { :integer_add }
      let(:int) { { name: :Int, nilable: false }.freeze }
      let(:signature) { { parameters: [[:other, int].freeze].freeze, returns: int }.freeze }
      let(:statement) { brast.create_native_definition(span:, name:, function:, signature:) }

      let(:statements_text) { <<~TEXT }
        native_definition name=+ function=integer_add signature={parameters: [[:other, {name: :Int, nilable: false}]], returns: {name: :Int, nilable: false}} @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a constant reference from the top level with ::" do
      let(:form) { :root }
      let(:parent) { nil }
      let(:name) { :A }
      let(:lexical_scope) { top }
      let(:statement) { brast.create_constant_reference(span:, form:, parent:, name:, lexical_scope:) }

      let(:statements_text) { <<~TEXT }
        constant_reference form=root name=A lexical_scope=0 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a constant reference qualified by another constant" do
      let(:form) { :qualified }
      let(:lexical_scope) { top }
      let(:parent) { brast.create_constant_reference(span:, form: :lexical, parent: nil, name: :A, lexical_scope:) }
      let(:name) { :B }
      let(:statement) { brast.create_constant_reference(span:, form:, parent:, name:, lexical_scope:) }

      let(:statements_text) { <<~TEXT }
        constant_reference form=qualified name=B lexical_scope=0 @1
          constant_reference form=lexical name=A lexical_scope=0 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a safe navigation call that passes an argument and a block" do
      let!(:scope) { brast.create_scope(kind: :block, variable_parent: top, lexical_parent: top) }

      let(:receiver) { brast.create_self_reference(span:) }
      let(:name) { :m }
      let(:one) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:arguments) { brast.create_arguments(span:, positionals: [one], keywords: [], forwarding: false) }
      let(:positionals) { [] }
      let(:keywords) { [] }
      let(:block) { nil }
      let(:forwarding) { false }
      let(:trailing_comma) { false }
      let(:parameters) { brast.create_parameters(span:, positionals:, keywords:, block:, forwarding:, trailing_comma:) }
      let(:body) { brast.create_body(span:, statements: [], scope:) }
      let(:block_literal) { brast.create_block(span:, parameters:, body:, scope:) }
      let(:passed_block) { brast.create_block_argument(span:, kind: :literal, value: block_literal) }
      let(:safe_navigation) { true }
      let(:statement) { brast.create_call(span:, receiver:, name:, arguments:, block: passed_block, safe_navigation:) }

      let(:statements_text) { <<~TEXT }
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

    context "with a call that passes a positional and a keyword argument" do
      let(:receiver) { nil }
      let(:name) { :m }
      let(:one) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:value) { brast.create_literal(span:, kind: :integer, value: 2) }
      let(:keyword) { brast.create_keyword_argument(span:, name: :k, value:) }
      let(:arguments) { brast.create_arguments(span:, positionals: [one], keywords: [keyword], forwarding: false) }
      let(:block) { nil }
      let(:safe_navigation) { false }
      let(:statement) { brast.create_call(span:, receiver:, name:, arguments:, block:, safe_navigation:) }

      let(:statements_text) { <<~TEXT }
        call name=m safe_navigation=false @1
          arguments forwarding=false @1
            literal kind=integer value=1 @1
            keyword_argument name=k @1
              literal kind=integer value=2 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a super call that passes an argument and a block with &" do
      let(:one) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:arguments) { brast.create_arguments(span:, positionals: [one], keywords: [], forwarding: false) }
      let(:value) { brast.create_literal(span:, kind: :nil, value: nil) }
      let(:block) { brast.create_block_argument(span:, kind: :expression, value:) }
      let(:statement) { brast.create_super_call(span:, arguments:, block:) }

      let(:statements_text) { <<~TEXT }
        super_call @1
          arguments forwarding=false @1
            literal kind=integer value=1 @1
          block_argument kind=expression @1
            literal kind=nil value=nil @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a yield that passes an argument" do
      let(:one) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:arguments) { brast.create_arguments(span:, positionals: [one], keywords: [], forwarding: false) }
      let(:statement) { brast.create_yield_call(span:, arguments:) }

      let(:statements_text) { <<~TEXT }
        yield_call @1
          arguments forwarding=false @1
            literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a primitive call that passes an argument" do
      let(:name) { :new_instance }
      let(:one) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:arguments) { brast.create_arguments(span:, positionals: [one], keywords: [], forwarding: false) }
      let(:statement) { brast.create_primitive_call(span:, name:, arguments:) }

      let(:statements_text) { <<~TEXT }
        primitive_call name=new_instance @1
          arguments forwarding=false @1
            literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a lambda" do
      let!(:scope) { brast.create_scope(kind: :lambda, variable_parent: top, lexical_parent: top) }

      let(:positionals) { [] }
      let(:keywords) { [] }
      let(:block) { nil }
      let(:forwarding) { false }
      let(:trailing_comma) { false }
      let(:parameters) { brast.create_parameters(span:, positionals:, keywords:, block:, forwarding:, trailing_comma:) }
      let(:body) { brast.create_body(span:, statements: [], scope:) }
      let(:statement) { brast.create_lambda(span:, parameters:, body:, scope:) }

      let(:statements_text) { <<~TEXT }
        lambda scope=1 @1
          parameters forwarding=false trailing_comma=false @1
          body scope=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a read of an instance variable" do
      let(:name) { :@a }
      let(:statement) { brast.create_instance_variable_read(span:, name:) }

      let(:statements_text) { <<~TEXT }
        instance_variable_read name=@a @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a read of a class variable" do
      let(:name) { :@@a }
      let(:statement) { brast.create_class_variable_read(span:, name:) }

      let(:statements_text) { <<~TEXT }
        class_variable_read name=@@a @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an assignment to an instance variable" do
      let(:name) { :@a }
      let(:target) { brast.create_instance_variable_target(span:, name:) }
      let(:value) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:statement) { brast.create_assignment(span:, target:, value:) }

      let(:statements_text) { <<~TEXT }
        assignment @1
          instance_variable_target name=@a @1
          literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an assignment to a class variable" do
      let(:name) { :@@a }
      let(:target) { brast.create_class_variable_target(span:, name:) }
      let(:value) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:statement) { brast.create_assignment(span:, target:, value:) }

      let(:statements_text) { <<~TEXT }
        assignment @1
          class_variable_target name=@@a @1
          literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an assignment to a constant" do
      let(:form) { :lexical }
      let(:parent) { nil }
      let(:name) { :A }
      let(:lexical_scope) { top }
      let(:constant) { brast.create_constant_reference(span:, form:, parent:, name:, lexical_scope:) }
      let(:target) { brast.create_constant_target(span:, constant:) }
      let(:value) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:statement) { brast.create_assignment(span:, target:, value:) }

      let(:statements_text) { <<~TEXT }
        assignment @1
          constant_target @1
            constant_reference form=lexical name=A lexical_scope=0 @1
          literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an assignment to an attribute" do
      let(:receiver) { brast.create_self_reference(span:) }
      let(:name) { :a }
      let(:safe_navigation) { false }
      let(:target) { brast.create_attribute_target(span:, receiver:, name:, safe_navigation:) }
      let(:value) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:statement) { brast.create_assignment(span:, target:, value:) }

      let(:statements_text) { <<~TEXT }
        assignment @1
          attribute_target name=a safe_navigation=false @1
            self_reference @1
          literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an assignment to an index" do
      let(:receiver) { brast.create_self_reference(span:) }
      let(:zero) { brast.create_literal(span:, kind: :integer, value: 0) }
      let(:arguments) { brast.create_arguments(span:, positionals: [zero], keywords: [], forwarding: false) }
      let(:target) { brast.create_index_target(span:, receiver:, arguments:) }
      let(:value) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:statement) { brast.create_assignment(span:, target:, value:) }

      let(:statements_text) { <<~TEXT }
        assignment @1
          index_target @1
            self_reference @1
            arguments forwarding=false @1
              literal kind=integer value=0 @1
          literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a compound assignment" do
      let(:target) { brast.create_instance_variable_target(span:, name: :@a) }
      let(:operator) { :+ }
      let(:value) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:statement) { brast.create_compound_assignment(span:, target:, operator:, value:) }

      let(:statements_text) { <<~TEXT }
        compound_assignment operator=+ @1
          instance_variable_target name=@a @1
          literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a logical assignment" do
      let(:target) { brast.create_instance_variable_target(span:, name: :@a) }
      let(:operator) { :or }
      let(:value) { brast.create_literal(span:, kind: :integer, value: 1) }
      let(:statement) { brast.create_logical_assignment(span:, target:, operator:, value:) }

      let(:statements_text) { <<~TEXT }
        logical_assignment operator=or @1
          instance_variable_target name=@a @1
          literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end
  end
end
