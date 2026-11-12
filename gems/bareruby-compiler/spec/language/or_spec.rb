# frozen_string_literal: true

require_relative "../support/core_program"

RSpec.describe "||" do
  include CoreProgram

  describe "with Bool operands" do
    subject(:output) { output_of(source) }

    context "with a true left operand" do
      let(:source) { "puts(true || false)" }

      it { is_expected.to eq("true\n") }
    end

    context "with a false left operand and a true right operand" do
      let(:source) { "puts(false || true)" }

      it { is_expected.to eq("true\n") }
    end

    context "with two false operands" do
      let(:source) { "puts(false || false)" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "with a nil left operand" do
    subject(:output) { output_of(source) }

    context "with a call on the left" do
      let(:source) { "puts((puts 1) || 2)" }

      it { is_expected.to eq("1\n2\n") }
    end
  end
end
