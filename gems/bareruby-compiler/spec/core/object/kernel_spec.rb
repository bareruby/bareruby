# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "Kernel" do
  include CoreProgram

  describe "#puts" do
    subject(:output) { output_of(source) }

    context "with true" do
      let(:source) { "puts true" }

      it { is_expected.to eq("true\n") }
    end

    context "with false" do
      let(:source) { "puts false" }

      it { is_expected.to eq("false\n") }
    end

    context "with zero" do
      let(:source) { "puts 0" }

      it { is_expected.to eq("0\n") }
    end

    context "with a positive Int" do
      let(:source) { "puts 42" }

      it { is_expected.to eq("42\n") }
    end

    context "with a negative Int" do
      let(:source) { "puts(-42)" }

      it { is_expected.to eq("-42\n") }
    end

    context "with the largest Int" do
      let(:source) { "puts 2147483647" }

      it { is_expected.to eq("2147483647\n") }
    end

    context "with the smallest Int" do
      let(:source) { "puts(-2147483648)" }

      it { is_expected.to eq("-2147483648\n") }
    end
  end
  describe "#nil?" do
    subject(:output) { output_of(source) }

    context "with an object" do
      let(:source) { "puts Object.new.nil?" }

      it { is_expected.to eq("false\n") }
    end
  end
end
