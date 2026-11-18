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
  end
end
