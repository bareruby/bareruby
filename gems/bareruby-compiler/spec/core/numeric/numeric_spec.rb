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
end
