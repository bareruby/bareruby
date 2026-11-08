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
  end
end
