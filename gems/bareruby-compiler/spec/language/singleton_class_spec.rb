# frozen_string_literal: true

require_relative "../support/core_program"

RSpec.describe "class << self" do
  include CoreProgram

  describe "def in the body" do
    subject(:output) { output_of(source) }

    context "with a method in a class" do
      let(:source) do
        <<~RUBY
          class Foo
            class << self
              def answer
                42
              end
            end
          end
          puts Foo.answer
        RUBY
      end

      it { is_expected.to eq("42\n") }
    end

    context "with a method in a module" do
      let(:source) do
        <<~RUBY
          module Foo
            class << self
              def answer = 3
            end
          end
          puts Foo.answer
        RUBY
      end

      it { is_expected.to eq("3\n") }
    end

    context "with a call without a receiver to another method in the body" do
      let(:source) do
        <<~RUBY
          class Foo
            class << self
              def answer = double(4)
              def double(value) = value + value
            end
          end
          puts Foo.answer
        RUBY
      end

      it { is_expected.to eq("8\n") }
    end

    context "with an instance method of the same name" do
      let(:source) do
        <<~RUBY
          class Foo
            class << self
              def answer = 1
            end

            def answer = 2
          end
          puts Foo.answer
          puts Foo.new.answer
        RUBY
      end

      it { is_expected.to eq("1\n2\n") }
    end
  end
end
