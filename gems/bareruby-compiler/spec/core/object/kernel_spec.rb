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
  end
end
