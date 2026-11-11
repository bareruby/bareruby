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

    context "with new in a class << self body" do
      let(:source) do
        <<~RUBY
          class Foo
            class << self
              undef_method :new
            end
          end
          Foo.new
        RUBY
      end

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /undefined method 'new' for Class/) }
    end

    context "with new of another class after a class << self body undefines it" do
      let(:source) do
        <<~RUBY
          class Foo
            class << self
              undef_method :new
            end
          end

          class Bar
            def answer = 3
          end
          puts Bar.new.answer
        RUBY
      end

      it { is_expected.to eq("3\n") }
    end

    context "with a name that no method has" do
      let(:source) do
        <<~RUBY
          class Foo
            undef_method :missing
          end
        RUBY
      end

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /undefined method 'missing' for class 'Foo'/) }
    end

    context "with the same name twice" do
      let(:source) do
        <<~RUBY
          class Foo
            def answer = 1
            undef_method :answer
            undef_method :answer
          end
        RUBY
      end

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /undefined method 'answer' for class 'Foo'/) }
    end

    context "with a name that no class-side method has" do
      let(:source) do
        <<~RUBY
          class Foo
            class << self
              undef_method :missing
            end
          end
        RUBY
      end

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /undefined method 'missing' for class 'Foo'/) }
    end
  end
end
