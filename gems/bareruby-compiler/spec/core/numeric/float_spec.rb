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

  describe "#+" do
    subject(:output) { output_of(source) }

    context "with two Floats" do
      let(:source) { "puts 1.5 + 2.25 == 3.75" }

      it { is_expected.to eq("true\n") }
    end

    context "with a sum that rounds to binary32" do
      let(:source) { "puts 16777216.0 + 1.0 == 16777216.0" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#-" do
    subject(:output) { output_of(source) }

    context "with two Floats" do
      let(:source) { "puts 5.5 - 2.25 == 3.25" }

      it { is_expected.to eq("true\n") }
    end

    context "with a larger Float" do
      let(:source) { "puts 1.5 - 2.25 == -0.75" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#*" do
    subject(:output) { output_of(source) }

    context "with two Floats" do
      let(:source) { "puts 1.5 * 2.5 == 3.75" }

      it { is_expected.to eq("true\n") }
    end

    context "with a negative Float" do
      let(:source) { "puts 1.5 * -2.0 == -3.0" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#/" do
    subject(:output) { output_of(source) }

    context "with two Floats" do
      let(:source) { "puts 7.5 / 2.5 == 3.0" }

      it { is_expected.to eq("true\n") }
    end

    context "with a quotient that rounds to binary32" do
      let(:source) { "puts 1.0 / 3.0 == 0.333333343" }

      it { is_expected.to eq("true\n") }
    end

    context "with zero divided by zero" do
      let(:source) do
        <<~SOURCE
          zero = 0.0
          nan = zero / zero
          puts nan == nan
        SOURCE
      end

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#-@" do
    subject(:output) { output_of(source) }

    context "with a positive Float" do
      let(:source) do
        <<~SOURCE
          value = 1.5
          puts(-value == -1.5)
        SOURCE
      end

      it { is_expected.to eq("true\n") }
    end

    context "with a negative Float" do
      let(:source) do
        <<~SOURCE
          value = -1.5
          puts(-value == 1.5)
        SOURCE
      end

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#%" do
    subject(:output) { output_of(source) }

    context "with two positive Floats" do
      let(:source) { "puts 7.5 % 2.0 == 1.5" }

      it { is_expected.to eq("true\n") }
    end

    context "with a negative dividend" do
      let(:source) { "puts((-7.5 % 2.0) == -1.5)" }

      it { is_expected.to eq("true\n") }
    end

    context "with a negative divisor" do
      let(:source) { "puts 7.5 % -2.0 == 1.5" }

      it { is_expected.to eq("true\n") }
    end
  end
end
