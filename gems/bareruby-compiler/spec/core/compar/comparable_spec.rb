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

  describe "#>" do
    subject(:output) { output_of(classes + source) }

    context "with a larger object" do
      let(:source) { "puts Low.new > High.new" }

      it { is_expected.to eq("false\n") }
    end

    context "with an equal object" do
      let(:source) { "puts Low.new > Low.new" }

      it { is_expected.to eq("false\n") }
    end

    context "with a smaller object" do
      let(:source) { "puts High.new > Low.new" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#>=" do
    subject(:output) { output_of(classes + source) }

    context "with a larger object" do
      let(:source) { "puts Low.new >= High.new" }

      it { is_expected.to eq("false\n") }
    end

    context "with an equal object" do
      let(:source) { "puts Low.new >= Low.new" }

      it { is_expected.to eq("true\n") }
    end

    context "with a smaller object" do
      let(:source) { "puts High.new >= Low.new" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#between?" do
    subject(:output) { output_of(classes + source) }

    context "with the receiver between the two objects" do
      let(:source) { "puts Low.new.between?(Low.new, High.new)" }

      it { is_expected.to eq("true\n") }
    end

    context "with the receiver above the maximum" do
      let(:source) { "puts High.new.between?(Low.new, Low.new)" }

      it { is_expected.to eq("false\n") }
    end

    context "with the receiver below the minimum" do
      let(:source) { "puts Low.new.between?(High.new, High.new)" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#==" do
    subject(:output) { output_of(classes + source) }

    context "with the same object" do
      let(:source) do
        <<~SOURCE
          low = Low.new
          puts low == low
        SOURCE
      end

      it { is_expected.to eq("true\n") }
    end

    context "with another object that <=> finds equal" do
      let(:source) { "puts Low.new == Low.new" }

      it { is_expected.to eq("true\n") }
    end

    context "with an object that <=> finds different" do
      let(:source) { "puts Low.new == High.new" }

      it { is_expected.to eq("false\n") }
    end
  end
  describe "#== with a <=> that may return nil" do
    subject(:output) { output_of(classes + source) }

    let(:classes) do
      <<~RUBY
        class Unordered
          include Comparable

          def <=>(other) = (0 if 2 < 1)
        end

        class Same
          include Comparable

          def <=>(other) = (0 if 1 < 2)
        end
      RUBY
    end

    context "with nil returned by <=>" do
      let(:source) { "puts Unordered.new == Unordered.new" }

      it { is_expected.to eq("false\n") }
    end

    context "with the same object and nil returned by <=>" do
      let(:source) do
        <<~SOURCE
          unordered = Unordered.new
          puts unordered == unordered
        SOURCE
      end

      it { is_expected.to eq("true\n") }
    end

    context "with 0 returned by <=>" do
      let(:source) { "puts Same.new == Same.new" }

      it { is_expected.to eq("true\n") }
    end
  end
end
