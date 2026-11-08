# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "Class" do
  include CoreProgram

  describe "#new" do
    subject(:output) { output_of(source) }

    context "with an argument for initialize" do
      let(:source) do
        <<~RUBY
          class Foo
            def initialize(value) = puts(value)
          end
          Foo.new(7)
        RUBY
      end

      it { is_expected.to eq("7\n") }
    end

    context "with two arguments for initialize" do
      let(:source) do
        <<~RUBY
          class Foo
            def initialize(first, second)
              puts(first)
              puts(second)
            end
          end
          Foo.new(1, true)
        RUBY
      end

      it { is_expected.to eq("1\ntrue\n") }
    end

    context "with a method called on the new object" do
      let(:source) do
        <<~RUBY
          class Foo
            def initialize
            end

            def answer = 42
          end
          puts Foo.new.answer
        RUBY
      end

      it { is_expected.to eq("42\n") }
    end

    context "with fewer arguments than initialize takes" do
      let(:source) do
        <<~RUBY
          class Foo
            def initialize(value) = puts(value)
          end
          Foo.new
        RUBY
      end

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /wrong number of arguments/) }
    end
  end
end
