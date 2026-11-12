# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "Integer" do
  include CoreProgram

  describe "#==" do
    subject(:output) { output_of(source) }

    context "with an equal Int" do
      let(:source) { "puts 7 == 7" }

      it { is_expected.to eq("true\n") }
    end

    context "with a different Int" do
      let(:source) { "puts 7 == 8" }

      it { is_expected.to eq("false\n") }
    end

    context "with the same value of the opposite sign" do
      let(:source) { "puts 7 == -7" }

      it { is_expected.to eq("false\n") }
    end

    context "with two equal Bytes" do
      let(:source) { "puts 7.to_u8 == 7.to_u8" }

      it { is_expected.to eq("true\n") }
    end

    context "with two different Bytes" do
      let(:source) { "puts 7.to_u8 == 8.to_u8" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#integer?" do
    subject(:output) { output_of(source) }

    context "with an Int" do
      let(:source) { "puts 7.integer?" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#abs" do
    subject(:output) { output_of(source) }

    context "with a positive Int" do
      let(:source) { "puts 7.abs" }

      it { is_expected.to eq("7\n") }
    end

    context "with a negative Int" do
      let(:source) { "puts(-7.abs)" }

      it { is_expected.to eq("7\n") }
    end
  end

  describe "#zero?" do
    subject(:output) { output_of(source) }

    context "with zero" do
      let(:source) { "puts 0.zero?" }

      it { is_expected.to eq("true\n") }
    end

    context "with a positive Int" do
      let(:source) { "puts 7.zero?" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#<" do
    subject(:output) { output_of(source) }

    context "with a smaller Int" do
      let(:source) { "puts 7 < 8" }

      it { is_expected.to eq("true\n") }
    end

    context "with an equal Int" do
      let(:source) { "puts 7 < 7" }

      it { is_expected.to eq("false\n") }
    end

    context "with a larger Int" do
      let(:source) { "puts 8 < 7" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#<=" do
    subject(:output) { output_of(source) }

    context "with a smaller Int" do
      let(:source) { "puts 7 <= 8" }

      it { is_expected.to eq("true\n") }
    end

    context "with an equal Int" do
      let(:source) { "puts 7 <= 7" }

      it { is_expected.to eq("true\n") }
    end

    context "with a larger Int" do
      let(:source) { "puts 8 <= 7" }

      it { is_expected.to eq("false\n") }
    end
  end
end
