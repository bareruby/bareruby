# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "BasicObject" do
  include CoreProgram

  describe "#initialize" do
    subject(:output) { output_of(source) }

    context "with a class that does not define initialize" do
      let(:source) do
        <<~RUBY
          class Foo
          end
          Foo.new
          puts 1
        RUBY
      end

      it { is_expected.to eq("1\n") }
    end

    context "with an argument" do
      let(:source) { "BasicObject.new(1)" }

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /wrong number of arguments/) }
    end
  end

  describe "#__id__" do
    subject(:output) { output_of(source) }

    context "with the 64-bit host" do
      let(:source) { "puts BasicObject.new.__id__.length" }

      it { is_expected.to eq("9\n") }
    end

    context "with the same object" do
      let(:source) do
        <<~RUBY
          object = BasicObject.new
          puts object.__id__ == object.__id__
        RUBY
      end

      it { is_expected.to eq("true\n") }
    end

    context "with two different objects" do
      let(:source) { "puts BasicObject.new.__id__ == BasicObject.new.__id__" }

      it { is_expected.to eq("false\n") }
    end
  end
  describe "#equal?" do
    subject(:output) { output_of(source) }

    context "with the same object" do
      let(:source) do
        <<~RUBY
          object = BasicObject.new
          puts object.equal?(object)
        RUBY
      end

      it { is_expected.to eq("true\n") }
    end

    context "with two different objects" do
      let(:source) { "puts BasicObject.new.equal?(BasicObject.new)" }

      it { is_expected.to eq("false\n") }
    end
  end
  describe "#==" do
    subject(:output) { output_of(source) }

    context "with the same object" do
      let(:source) do
        <<~RUBY
          object = BasicObject.new
          puts object == object
        RUBY
      end

      it { is_expected.to eq("true\n") }
    end

    context "with two different objects" do
      let(:source) { "puts BasicObject.new == BasicObject.new" }

      it { is_expected.to eq("false\n") }
    end
  end
end
