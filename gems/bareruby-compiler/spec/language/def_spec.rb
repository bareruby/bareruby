# frozen_string_literal: true

require_relative "../support/core_program"

RSpec.describe "def" do
  include CoreProgram

  describe "with self as the receiver" do
    subject(:output) { output_of(source) }

    context "with a method body in a class" do
      let(:source) do
        <<~RUBY
          class Foo
            def self.answer
              42
            end
          end
          puts Foo.answer
        RUBY
      end

      it { is_expected.to eq("42\n") }
    end

    context "with an endless method in a class" do
      let(:source) do
        <<~RUBY
          class Foo
            def self.double(value) = value + value
          end
          puts Foo.double(4)
        RUBY
      end

      it { is_expected.to eq("8\n") }
    end

    context "with a method in a module" do
      let(:source) do
        <<~RUBY
          module Foo
            def self.answer = 3
          end
          puts Foo.answer
        RUBY
      end

      it { is_expected.to eq("3\n") }
    end

    context "with a method defined on the superclass" do
      let(:source) do
        <<~RUBY
          class Object
            def self.answer = which
            def self.which = 1
          end

          class Foo
            def self.which = 2
          end
          puts Foo.answer
        RUBY
      end

      it { is_expected.to eq("2\n") }
    end

    context "with an instance method of the same name" do
      let(:source) do
        <<~RUBY
          class Foo
            def self.answer = 1
            def answer = 2
          end
          puts Foo.answer
          puts Foo.new.answer
        RUBY
      end

      it { is_expected.to eq("1\n2\n") }
    end

    context "with a method named new" do
      let(:source) do
        <<~RUBY
          class Foo
            def self.new = 42
          end
          puts Foo.new
        RUBY
      end

      it { is_expected.to eq("42\n") }
    end
  end
end
