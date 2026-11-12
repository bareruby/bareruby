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

  describe "#>" do
    subject(:output) { output_of(source) }

    context "with a smaller Int" do
      let(:source) { "puts 7 > 8" }

      it { is_expected.to eq("false\n") }
    end

    context "with an equal Int" do
      let(:source) { "puts 7 > 7" }

      it { is_expected.to eq("false\n") }
    end

    context "with a larger Int" do
      let(:source) { "puts 8 > 7" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#>=" do
    subject(:output) { output_of(source) }

    context "with a smaller Int" do
      let(:source) { "puts 7 >= 8" }

      it { is_expected.to eq("false\n") }
    end

    context "with an equal Int" do
      let(:source) { "puts 7 >= 7" }

      it { is_expected.to eq("true\n") }
    end

    context "with a larger Int" do
      let(:source) { "puts 8 >= 7" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#<=>" do
    subject(:output) { output_of(source) }

    context "with a larger Int" do
      let(:source) { "puts 7 <=> 8" }

      it { is_expected.to eq("-1\n") }
    end

    context "with an equal Int" do
      let(:source) { "puts 7 <=> 7" }

      it { is_expected.to eq("0\n") }
    end

    context "with a smaller Int" do
      let(:source) { "puts 8 <=> 7" }

      it { is_expected.to eq("1\n") }
    end
  end

  describe "#+" do
    subject(:output) { output_of(source) }

    context "with two positive Ints" do
      let(:source) { "puts 7 + 8" }

      it { is_expected.to eq("15\n") }
    end

    context "with a negative Int" do
      let(:source) { "puts 7 + -8" }

      it { is_expected.to eq("-1\n") }
    end

    context "with a Float" do
      let(:source) { "puts 1 + 0.5 == 1.5" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#-" do
    subject(:output) { output_of(source) }

    context "with a smaller Int" do
      let(:source) { "puts 8 - 7" }

      it { is_expected.to eq("1\n") }
    end

    context "with a larger Int" do
      let(:source) { "puts 7 - 8" }

      it { is_expected.to eq("-1\n") }
    end

    context "with a Float" do
      let(:source) { "puts 2 - 0.5 == 1.5" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#*" do
    subject(:output) { output_of(source) }

    context "with two positive Ints" do
      let(:source) { "puts 7 * 8" }

      it { is_expected.to eq("56\n") }
    end

    context "with a negative Int" do
      let(:source) { "puts 7 * -8" }

      it { is_expected.to eq("-56\n") }
    end

    context "with a Float" do
      let(:source) { "puts 3 * 0.5 == 1.5" }

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#/" do
    subject(:output) { output_of(source) }

    context "with an exact quotient" do
      let(:source) { "puts 8 / 2" }

      it { is_expected.to eq("4\n") }
    end

    context "with a positive quotient with a remainder" do
      let(:source) { "puts 7 / 2" }

      it { is_expected.to eq("3\n") }
    end

    context "with a negative dividend" do
      let(:source) { "puts(-7 / 2)" }

      it { is_expected.to eq("-3\n") }
    end

    context "with a negative divisor" do
      let(:source) { "puts 7 / -2" }

      it { is_expected.to eq("-3\n") }
    end
  end

  describe "#%" do
    subject(:output) { output_of(source) }

    context "with two positive Ints" do
      let(:source) { "puts 7 % 2" }

      it { is_expected.to eq("1\n") }
    end

    context "with a negative dividend" do
      let(:source) { "puts(-7 % 2)" }

      it { is_expected.to eq("-1\n") }
    end

    context "with a negative divisor" do
      let(:source) { "puts 7 % -2" }

      it { is_expected.to eq("1\n") }
    end
  end

  describe "#-@" do
    subject(:output) { output_of(source) }

    context "with a positive Int" do
      let(:source) do
        <<~RUBY
          x = 7
          puts(-x)
        RUBY
      end

      it { is_expected.to eq("-7\n") }
    end

    context "with a negative Int" do
      let(:source) do
        <<~RUBY
          x = -7
          puts(-x)
        RUBY
      end

      it { is_expected.to eq("7\n") }
    end
  end

  describe "#equal?" do
    subject(:output) { output_of(source) }

    context "with an equal Int" do
      let(:source) { "puts 7.equal?(7)" }

      it { is_expected.to eq("true\n") }
    end

    context "with a different Int" do
      let(:source) { "puts 7.equal?(8)" }

      it { is_expected.to eq("false\n") }
    end
  end
end
