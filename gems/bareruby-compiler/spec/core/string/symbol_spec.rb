# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "Symbol" do
  include CoreProgram

  describe "#==" do
    subject(:output) { output_of(source) }

    context "with a Symbol of the same name" do
      let(:source) { "puts :ready == :ready" }

      it { is_expected.to eq("true\n") }
    end

    context "with a Symbol of a different name" do
      let(:source) { "puts :ready == :done" }

      it { is_expected.to eq("false\n") }
    end

    context "with the same name written in quotes" do
      let(:source) { 'puts :"ready" == :ready' }

      it { is_expected.to eq("true\n") }
    end

    context "with the same name written with %s" do
      let(:source) { "puts %s(ready) == :ready" }

      it { is_expected.to eq("true\n") }
    end

    context "with the same name written in a method of a class" do
      let(:source) do
        <<~RUBY
          class Foo
            def state = :ready
          end
          puts Foo.new.state == :ready
        RUBY
      end

      it { is_expected.to eq("true\n") }
    end

    context "with a Symbol read from a local variable" do
      let(:source) do
        <<~RUBY
          state = :ready
          puts state == :ready
        RUBY
      end

      it { is_expected.to eq("true\n") }
    end
  end

  describe "#!=" do
    subject(:output) { output_of(source) }

    context "with a Symbol of the same name" do
      let(:source) { "puts :ready != :ready" }

      it { is_expected.to eq("false\n") }
    end

    context "with a Symbol of a different name" do
      let(:source) { "puts :ready != :done" }

      it { is_expected.to eq("true\n") }
    end
  end
end
