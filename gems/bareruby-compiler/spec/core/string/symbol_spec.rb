# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "Symbol" do
  include CoreProgram

  describe ".new" do
    subject(:output) { output_of(source) }

    context "without arguments" do
      let(:source) { "Symbol.new" }

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /undefined method 'new' for Class/) }
    end
  end

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

  describe "#===" do
    subject(:output) { output_of(source) }

    context "with a Symbol of the same name" do
      let(:source) { "puts :ready === :ready" }

      it { is_expected.to eq("true\n") }
    end

    context "with a Symbol of a different name" do
      let(:source) { "puts :ready === :done" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#equal?" do
    subject(:output) { output_of(source) }

    context "with a Symbol of the same name" do
      let(:source) { "puts :ready.equal?(:ready)" }

      it { is_expected.to eq("true\n") }
    end

    context "with a Symbol of a different name" do
      let(:source) { "puts :ready.equal?(:done)" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#<=>" do
    subject(:output) { output_of(source) }

    context "with a Symbol of the same name" do
      let(:source) { "puts :ready <=> :ready" }

      it { is_expected.to eq("0\n") }
    end

    context "with a Symbol whose name comes later" do
      let(:source) { "puts :apple <=> :banana" }

      it { is_expected.to eq("-1\n") }
    end

    context "with a Symbol whose name comes earlier but appears later in the program" do
      let(:source) { "puts :banana <=> :apple" }

      it { is_expected.to eq("1\n") }
    end

    context "with a Symbol whose name extends the receiver's name" do
      let(:source) { "puts :ab <=> :abc" }

      it { is_expected.to eq("-1\n") }
    end

    context "with names of digits" do
      let(:source) { 'puts :"10" <=> :"9"' }

      it { is_expected.to eq("-1\n") }
    end

    context "with a name whose bytes go on after a NUL byte" do
      let(:source) { 'puts :"a\0b" <=> :a' }

      it { is_expected.to eq("1\n") }
    end

    context "with a name that contains a double quote and a backslash" do
      let(:source) { 'puts :"a\"\\\\" <=> :"a\""' }

      it { is_expected.to eq("1\n") }
    end

    context "with a name of bytes above 0x7F" do
      let(:source) { 'puts :"é" <=> :z' }

      it { is_expected.to eq("1\n") }
    end
  end

  describe "#<" do
    subject(:output) { output_of(source) }

    context "with a Symbol whose name comes later" do
      let(:source) { "puts :apple < :banana" }

      it { is_expected.to eq("true\n") }
    end

    context "with a Symbol of the same name" do
      let(:source) { "puts :apple < :apple" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#<=" do
    subject(:output) { output_of(source) }

    context "with a Symbol of the same name" do
      let(:source) { "puts :apple <= :apple" }

      it { is_expected.to eq("true\n") }
    end

    context "with a Symbol whose name comes earlier" do
      let(:source) { "puts :banana <= :apple" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#>" do
    subject(:output) { output_of(source) }

    context "with a Symbol whose name comes earlier" do
      let(:source) { "puts :banana > :apple" }

      it { is_expected.to eq("true\n") }
    end

    context "with a Symbol of the same name" do
      let(:source) { "puts :apple > :apple" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#>=" do
    subject(:output) { output_of(source) }

    context "with a Symbol of the same name" do
      let(:source) { "puts :apple >= :apple" }

      it { is_expected.to eq("true\n") }
    end

    context "with a Symbol whose name comes later" do
      let(:source) { "puts :apple >= :banana" }

      it { is_expected.to eq("false\n") }
    end
  end

  describe "#between?" do
    subject(:output) { output_of(source) }

    context "with bounds whose names enclose the receiver's name" do
      let(:source) { "puts :banana.between?(:apple, :cherry)" }

      it { is_expected.to eq("true\n") }
    end

    context "with bounds whose names come after the receiver's name" do
      let(:source) { "puts :apple.between?(:banana, :cherry)" }

      it { is_expected.to eq("false\n") }
    end
  end
end
