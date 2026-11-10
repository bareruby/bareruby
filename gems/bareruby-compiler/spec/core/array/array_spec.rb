# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "Array" do
  include CoreProgram

  describe "#==" do
    subject(:output) { output_of(source) }

    context "with the same elements in the same order" do
      let(:source) { "puts [1, 2, 3] == [1, 2, 3]" }

      it { is_expected.to eq("true\n") }
    end

    context "with a different element" do
      let(:source) { "puts [1, 2, 3] == [1, 5, 3]" }

      it { is_expected.to eq("false\n") }
    end

    context "with the same elements in a different order" do
      let(:source) { "puts [1, 2, 3] == [3, 2, 1]" }

      it { is_expected.to eq("false\n") }
    end

    context "with fewer elements" do
      let(:source) { "puts [1, 2, 3] == [1, 2]" }

      it { is_expected.to eq("false\n") }
    end

    context "with more elements" do
      let(:source) { "puts [1, 2] == [1, 2, 3]" }

      it { is_expected.to eq("false\n") }
    end
  end
end
