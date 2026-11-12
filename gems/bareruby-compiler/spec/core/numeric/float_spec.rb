# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "Float" do
  include CoreProgram

  describe "#==" do
    subject(:output) { output_of(source) }

    context "with an equal Float" do
      let(:source) { "puts 1.5 == 1.5" }

      it { is_expected.to eq("true\n") }
    end

    context "with a different Float" do
      let(:source) { "puts 1.5 == 2.5" }

      it { is_expected.to eq("false\n") }
    end

    context "with two literals that round to the same binary32 value" do
      let(:source) { "puts 0.1 == 0.1000000015" }

      it { is_expected.to eq("true\n") }
    end

    context "with the same value written with an exponent" do
      let(:source) { "puts 15e-1 == 1.5" }

      it { is_expected.to eq("true\n") }
    end

    context "with the same value written with an underscore" do
      let(:source) { "puts 1_000.5 == 1000.5" }

      it { is_expected.to eq("true\n") }
    end

    context "with zero of the opposite sign" do
      let(:source) { "puts 0.0 == -0.0" }

      it { is_expected.to eq("true\n") }
    end
  end
end
