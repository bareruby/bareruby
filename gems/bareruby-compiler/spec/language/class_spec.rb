# frozen_string_literal: true

require_relative "../support/core_program"

RSpec.describe "class" do
  include CoreProgram

  describe "with a superclass" do
    subject(:output) { output_of(source) }

    context "with an instance method of the superclass" do
      let(:source) do
        <<~RUBY
          class Foo
            def answer = 1
          end

          class Bar < Foo
          end
          puts Bar.new.answer
        RUBY
      end

      it { is_expected.to eq("1\n") }
    end

    context "with a method that the subclass redefines" do
      let(:source) do
        <<~RUBY
          class Foo
            def answer = 1
          end

          class Bar < Foo
            def answer = 2
          end
          puts Foo.new.answer
          puts Bar.new.answer
        RUBY
      end

      it { is_expected.to eq("1\n2\n") }
    end

    context "with a class method of the superclass" do
      let(:source) do
        <<~RUBY
          class Foo
            def self.answer = which
            def self.which = 1
          end

          class Bar < Foo
            def self.which = 2
          end
          puts Bar.answer
        RUBY
      end

      it { is_expected.to eq("2\n") }
    end

    context "with a reopened subclass that does not repeat the superclass" do
      let(:source) do
        <<~RUBY
          class Foo
            def answer = 1
          end

          class Bar < Foo
          end

          class Bar
          end
          puts Bar.new.answer
        RUBY
      end

      it { is_expected.to eq("1\n") }
    end
  end
end
