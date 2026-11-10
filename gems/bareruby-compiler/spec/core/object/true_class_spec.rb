# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "TrueClass" do
  include CoreProgram

  describe "#__id__" do
    subject(:output) { output_of(source) }

    context "with the 64-bit host" do
      let(:source) { "puts true.__id__.length" }

      it { is_expected.to eq("9\n") }
    end

    context "with true twice" do
      let(:source) { "puts true.__id__ == true.__id__" }

      it { is_expected.to eq("true\n") }
    end

    context "with false" do
      let(:source) { "puts true.__id__ == false.__id__" }

      it { is_expected.to eq("false\n") }
    end

    context "with nil" do
      let(:source) { "puts true.__id__ == nil.__id__" }

      it { is_expected.to eq("false\n") }
    end

    context "with true computed at run time" do
      let(:source) do
        <<~RUBY
          value = 1 == 1
          puts value.__id__ == true.__id__
        RUBY
      end

      it { is_expected.to eq("true\n") }
    end
  end
  describe "#==" do
    subject(:output) { output_of(source) }

    context "with true" do
      let(:source) { "puts true == true" }

      it { is_expected.to eq("true\n") }
    end

    context "with false" do
      let(:source) { "puts true == false" }

      it { is_expected.to eq("false\n") }
    end

    context "with nil" do
      let(:source) { "puts true == nil" }

      it { is_expected.to eq("false\n") }
    end

    context "with an object" do
      let(:source) { "puts true == BasicObject.new" }

      it { is_expected.to eq("false\n") }
    end
  end
end
