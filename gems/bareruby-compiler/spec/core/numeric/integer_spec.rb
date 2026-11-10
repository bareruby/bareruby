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
end
