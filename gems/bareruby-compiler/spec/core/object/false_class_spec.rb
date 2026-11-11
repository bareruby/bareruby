# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "FalseClass" do
  include CoreProgram

  describe ".new" do
    subject(:output) { output_of(source) }

    context "without arguments" do
      let(:source) { "FalseClass.new" }

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /undefined method 'new' for Class/) }
    end
  end

  describe "#__id__" do
    subject(:output) { output_of(source) }

    context "with the 64-bit host" do
      let(:source) { "puts false.__id__.length" }

      it { is_expected.to eq("9\n") }
    end

    context "with false twice" do
      let(:source) { "puts false.__id__ == false.__id__" }

      it { is_expected.to eq("true\n") }
    end

    context "with true" do
      let(:source) { "puts false.__id__ == true.__id__" }

      it { is_expected.to eq("false\n") }
    end

    context "with nil" do
      let(:source) { "puts false.__id__ == nil.__id__" }

      it { is_expected.to eq("false\n") }
    end

    context "with false computed at run time" do
      let(:source) do
        <<~RUBY
          value = 1 == 2
          puts value.__id__ == false.__id__
        RUBY
      end

      it { is_expected.to eq("true\n") }
    end
  end
  describe "#==" do
    subject(:output) { output_of(source) }

    context "with false" do
      let(:source) { "puts false == false" }

      it { is_expected.to eq("true\n") }
    end

    context "with true" do
      let(:source) { "puts false == true" }

      it { is_expected.to eq("false\n") }
    end

    context "with nil" do
      let(:source) { "puts false == nil" }

      it { is_expected.to eq("false\n") }
    end

    context "with an object" do
      let(:source) { "puts false == BasicObject.new" }

      it { is_expected.to eq("false\n") }
    end
  end
end
