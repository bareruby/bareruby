# frozen_string_literal: true

require_relative "../../support/core_program"

RSpec.describe "Module" do
  include CoreProgram

  describe "#undef_method" do
    subject(:output) { output_of(source) }

    context "with a method defined in the same class" do
      let(:source) do
        <<~RUBY
          class Foo
            def answer = 1
            undef_method :answer
          end
          Foo.new.answer
        RUBY
      end

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /undefined method 'answer' for Foo/) }
    end

    context "with a method inherited from Kernel" do
      let(:source) do
        <<~RUBY
          class Foo
            undef_method :nil?
          end
          Foo.new.nil?
        RUBY
      end

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /undefined method 'nil\?' for Foo/) }
    end

    context "with another class that inherits the method" do
      let(:source) do
        <<~RUBY
          class Foo
            undef_method :nil?
          end

          class Bar
          end
          puts Bar.new.nil?
        RUBY
      end

      it { is_expected.to eq("false\n") }
    end

    context "with two names" do
      let(:source) do
        <<~RUBY
          class Foo
            def first = 1
            def second = 2
            undef_method :first, :second
          end
          Foo.new.second
        RUBY
      end

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /undefined method 'second' for Foo/) }
    end

    context "with a def after undef_method" do
      let(:source) do
        <<~RUBY
          class Foo
            def answer = 1
            undef_method :answer
            def answer = 2
          end
          puts Foo.new.answer
        RUBY
      end

      it { is_expected.to eq("2\n") }
    end
  end
end
