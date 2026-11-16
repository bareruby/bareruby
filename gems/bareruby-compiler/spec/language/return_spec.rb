# frozen_string_literal: true

require_relative "../support/core_program"

RSpec.describe "return" do
  include CoreProgram

  describe "in a method body" do
    subject(:output) { output_of(source) }

    context "with a value at the end of the body" do
      let(:source) do
        <<~RUBY
          class Foo
            def self.answer
              return 42
            end
          end
          puts Foo.answer
        RUBY
      end

      it { is_expected.to eq("42\n") }
    end

    context "with a value in a branch taken" do
      let(:source) do
        <<~RUBY
          class Foo
            def self.sign(value)
              return 1 if value > 0
              0
            end
          end
          puts Foo.sign(5)
        RUBY
      end

      it { is_expected.to eq("1\n") }
    end

    context "with a value in a branch not taken" do
      let(:source) do
        <<~RUBY
          class Foo
            def self.sign(value)
              return 1 if value > 0
              0
            end
          end
          puts Foo.sign(-5)
        RUBY
      end

      it { is_expected.to eq("0\n") }
    end
  end
end
