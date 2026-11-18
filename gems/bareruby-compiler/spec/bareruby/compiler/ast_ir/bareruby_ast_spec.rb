# frozen_string_literal: true

RSpec.describe BareRuby::Compiler::ASTIR::BareRubyAST do
  let(:brast) { described_class.new }

  describe "#inspect_text" do
    subject { sources.reduce(brast) { |ast, source| ast.add_source(source) }.inspect_text }

    context "without sources" do
      let(:sources) { [] }

      let(:expected_text) { <<~TEXT }
        program
      TEXT

      it { is_expected.to eq(expected_text) }
    end
  end
end
