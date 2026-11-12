# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "Comparable" do
  include CoreProgram

  let(:classes) do
    <<~RUBY
      class Low
        include Comparable

        def rank = 1
        def <=>(other) = rank <=> other.rank
      end

      class High
        include Comparable

        def rank = 2
        def <=>(other) = rank <=> other.rank
      end
    RUBY
  end

  describe "#<" do
    subject(:output) { output_of(classes + source) }

    context "with a larger object" do
      let(:source) { "puts Low.new < High.new" }

      it { is_expected.to eq("true\n") }
    end

    context "with an equal object" do
      let(:source) { "puts Low.new < Low.new" }

      it { is_expected.to eq("false\n") }
    end

    context "with a smaller object" do
      let(:source) { "puts High.new < Low.new" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#<=" do
    subject(:output) { output_of(classes + source) }

    context "with a larger object" do
      let(:source) { "puts Low.new <= High.new" }

      it { is_expected.to eq("true\n") }
    end

    context "with an equal object" do
      let(:source) { "puts Low.new <= Low.new" }

      it { is_expected.to eq("true\n") }
    end

    context "with a smaller object" do
      let(:source) { "puts High.new <= Low.new" }

      it { is_expected.to eq("false\n") }
    end
  end
end
