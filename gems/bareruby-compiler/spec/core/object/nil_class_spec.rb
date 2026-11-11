# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "NilClass" do
  include CoreProgram

  describe ".new" do
    subject(:output) { output_of(source) }

    context "without arguments" do
      let(:source) { "NilClass.new" }

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /undefined method 'new' for Class/) }
    end
  end

  describe "#nil?" do
    subject(:output) { output_of(source) }

    context "with nil" do
      let(:source) { "puts nil.nil?" }

      it { is_expected.to eq("true\n") }
    end

    context "with nil returned by a call" do
      let(:source) { "puts(puts(1).nil?)" }

      it { is_expected.to eq("1\ntrue\n") }
    end

    context "with nil returned by a method that ends with nil" do
      let(:source) do
        <<~RUBY
          class Foo
            def bar = nil
          end
          puts Foo.new.bar.nil?
        RUBY
      end

      it { is_expected.to eq("true\n") }
    end
  end
  describe "#__id__" do
    subject(:output) { output_of(source) }

    context "with the 64-bit host" do
      let(:source) { "puts nil.__id__.length" }

      it { is_expected.to eq("9\n") }
    end

    context "with nil twice" do
      let(:source) { "puts nil.__id__ == nil.__id__" }

      it { is_expected.to eq("true\n") }
    end

    context "with an object" do
      let(:source) { "puts nil.__id__ == BasicObject.new.__id__" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#==" do
    subject(:output) { output_of(source) }

    context "with nil" do
      let(:source) { "puts nil == nil" }

      it { is_expected.to eq("true\n") }
    end

    context "with an object" do
      let(:source) { "puts nil == BasicObject.new" }

      it { is_expected.to eq("false\n") }
    end

    context "with nil as the argument of an object" do
      let(:source) { "puts BasicObject.new == nil" }

      it { is_expected.to eq("false\n") }
    end
  end
end
