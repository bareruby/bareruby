# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "NilClass" do
  include CoreProgram

  describe "#nil?" do
    subject(:output) { output_of(source) }

    context "with nil" do
      let(:source) { "puts nil.nil?" }

      it { is_expected.to eq("true\n") }
    end
  end
end
