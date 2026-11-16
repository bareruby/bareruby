# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "Numeric" do
  include CoreProgram

  describe "as the superclass of Integer" do
    subject(:output) { output_of(source) }

    context "with a method that the program adds to Numeric" do
      let(:source) do
        <<~RUBY
          class Numeric
            def answer = 42
          end
          puts 7.answer
        RUBY
      end

      it { is_expected.to eq("42\n") }
    end

    context "with Comparable#between? on an Int inside the range" do
      let(:source) { "puts 7.between?(1, 9)" }

      it { is_expected.to eq("true\n") }
    end

    context "with Comparable#between? on an Int outside the range" do
      let(:source) { "puts 7.between?(8, 9)" }

      it { is_expected.to eq("false\n") }
    end
  end

  let(:classes) do
    <<~RUBY
      class Plus < Numeric
        def <=>(other) = 1 <=> other
        def ==(other) = 1 == other
        def -@ = Plus.new
      end

      class Zero < Numeric
        def <=>(other) = 0 <=> other
        def ==(other) = 0 == other
        def -@ = Zero.new
      end

      class Minus < Numeric
        def <=>(other) = -1 <=> other
        def ==(other) = -1 == other

        def -@
          puts 9
          Minus.new
        end
      end
    RUBY
  end

  describe "#positive?" do
    subject(:output) { output_of(classes + source) }

    context "with a positive value" do
      let(:source) { "puts Plus.new.positive?" }

      it { is_expected.to eq("true\n") }
    end

    context "with zero" do
      let(:source) { "puts Zero.new.positive?" }

      it { is_expected.to eq("false\n") }
    end

    context "with a negative value" do
      let(:source) { "puts Minus.new.positive?" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#negative?" do
    subject(:output) { output_of(classes + source) }

    context "with a positive value" do
      let(:source) { "puts Plus.new.negative?" }

      it { is_expected.to eq("false\n") }
    end

    context "with zero" do
      let(:source) { "puts Zero.new.negative?" }

      it { is_expected.to eq("false\n") }
    end

    context "with a negative value" do
      let(:source) { "puts Minus.new.negative?" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#zero?" do
    subject(:output) { output_of(classes + source) }

    context "with zero" do
      let(:source) { "puts Zero.new.zero?" }

      it { is_expected.to eq("true\n") }
    end

    context "with a positive value" do
      let(:source) { "puts Plus.new.zero?" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#nonzero?" do
    subject(:output) { output_of(source) }

    context "with a nonzero Int" do
      let(:source) { "puts(5.nonzero? || 0)" }

      it { is_expected.to eq("5\n") }
    end

    context "with the Int 0" do
      let(:source) { "puts 0.nonzero?.nil?" }

      it { is_expected.to eq("true\n") }
    end

    context "with a nonzero Float" do
      let(:source) { "puts((1.5.nonzero? || 0.0) == 1.5)" }

      it { is_expected.to eq("true\n") }
    end

    context "with the Float 0.0" do
      let(:source) { "puts 0.0.nonzero?.nil?" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#integer?" do
    subject(:output) { output_of(classes + source) }

    context "with a value of a subclass" do
      let(:source) { "puts Plus.new.integer?" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#finite?" do
    subject(:output) { output_of(classes + source) }

    context "with a value of a subclass" do
      let(:source) { "puts Plus.new.finite?" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#infinite?" do
    subject(:output) { output_of(classes + source) }

    context "with a value of a subclass" do
      let(:source) { "puts Plus.new.infinite?.nil?" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#abs" do
    subject(:output) { output_of(classes + source) }

    context "with a positive value" do
      let(:source) { "puts Plus.new.abs.positive?" }

      it { is_expected.to eq("true\n") }
    end

    context "with a negative value" do
      let(:source) { "puts Minus.new.abs.positive?" }

      it { is_expected.to eq("9\nfalse\n") }
    end
  end
end
