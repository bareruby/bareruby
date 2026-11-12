# frozen_string_literal: true

require_relative "../support/core_program"

RSpec.describe "Int?" do
  include CoreProgram

  describe "narrowed by its truth" do
    subject(:output) { output_of(source) }

    context "with an Integer assigned under a true condition" do
      let(:source) do
        <<~RUBY
          x = 5 if 1 < 2
          puts(x ? x + 1 : 0)
        RUBY
      end

      it { is_expected.to eq("6\n") }
    end

    context "with an assignment skipped under a false condition" do
      let(:source) do
        <<~RUBY
          x = 5 if 2 < 1
          puts(x ? x + 1 : 0)
        RUBY
      end

      it { is_expected.to eq("0\n") }
    end

    context "with 0 assigned" do
      let(:source) do
        <<~RUBY
          x = 0 if 1 < 2
          puts(x ? 1 : 2)
        RUBY
      end

      it { is_expected.to eq("1\n") }
    end

    context "with unless" do
      let(:source) do
        <<~RUBY
          x = 5 if 1 < 2
          unless x
            puts 0
          else
            puts x + 1
          end
        RUBY
      end

      it { is_expected.to eq("6\n") }
    end

    context "with nil assigned in the other branch" do
      let(:source) do
        <<~RUBY
          x = 2 < 1 ? 5 : nil
          puts(x ? x + 1 : 0)
        RUBY
      end

      it { is_expected.to eq("0\n") }
    end
  end

  describe "narrowed by nil?" do
    subject(:output) { output_of(source) }

    context "with an Integer" do
      let(:source) do
        <<~RUBY
          x = 5 if 1 < 2
          puts(x.nil? ? 0 : x + 1)
        RUBY
      end

      it { is_expected.to eq("6\n") }
    end

    context "with nil" do
      let(:source) do
        <<~RUBY
          x = 5 if 2 < 1
          puts(x.nil? ? 0 : x + 1)
        RUBY
      end

      it { is_expected.to eq("0\n") }
    end

    context "with nil? redefined in Integer" do
      let(:source) do
        <<~RUBY
          class Integer
            def nil? = false
          end
          x = 5 if 1 < 2
          puts(x.nil? ? 0 : x + 1)
        RUBY
      end

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /undefined method '\+' for nil/) }
    end
  end

  describe "narrowed by !" do
    subject(:output) { output_of(source) }

    context "with an Integer" do
      let(:source) do
        <<~RUBY
          x = 5 if 1 < 2
          puts(!x ? 0 : x + 1)
        RUBY
      end

      it { is_expected.to eq("6\n") }
    end

    context "with nil" do
      let(:source) do
        <<~RUBY
          x = 5 if 2 < 1
          puts(!x ? 0 : x + 1)
        RUBY
      end

      it { is_expected.to eq("0\n") }
    end

    context "with nil? negated" do
      let(:source) do
        <<~RUBY
          x = 5 if 1 < 2
          puts(!x.nil? ? x + 1 : 0)
        RUBY
      end

      it { is_expected.to eq("6\n") }
    end
  end

  describe "narrowed by short-circuit evaluation" do
    subject(:output) { output_of(source) }

    context "with the right operand of && as a condition" do
      let(:source) do
        <<~RUBY
          x = 5 if 1 < 2
          puts(x && x > 3 ? 1 : 0)
        RUBY
      end

      it { is_expected.to eq("1\n") }
    end

    context "with nil as the left operand of && as a condition" do
      let(:source) do
        <<~RUBY
          x = 5 if 2 < 1
          puts(x && x > 3 ? 1 : 0)
        RUBY
      end

      it { is_expected.to eq("0\n") }
    end

    context "with the right operand of ||" do
      let(:source) do
        <<~RUBY
          x = 5 if 1 < 2
          puts(x.nil? || x > 6)
        RUBY
      end

      it { is_expected.to eq("false\n") }
    end

    context "with the false branch of || as a condition" do
      let(:source) do
        <<~RUBY
          x = 5 if 1 < 2
          puts(x.nil? || 1 > 2 ? 0 : x + 1)
        RUBY
      end

      it { is_expected.to eq("6\n") }
    end
  end

  describe "as a receiver" do
    subject(:output) { output_of(source) }

    context "with an Integer calling a method that NilClass also has" do
      let(:source) do
        <<~RUBY
          x = 5 if 1 < 2
          puts x.nil?
        RUBY
      end

      it { is_expected.to eq("false\n") }
    end

    context "with nil calling a method that Integer also has" do
      let(:source) do
        <<~RUBY
          x = 5 if 2 < 1
          puts x.nil?
        RUBY
      end

      it { is_expected.to eq("true\n") }
    end

    context "with a method that NilClass does not have" do
      let(:source) do
        <<~RUBY
          x = 5 if 1 < 2
          puts x + 1
        RUBY
      end

      it { expect { output }.to raise_error(BareRuby::Compiler::Error, /undefined method '\+' for nil/) }
    end
  end
end

RSpec.describe "Float?" do
  include CoreProgram

  describe "narrowed by its truth" do
    subject(:output) { output_of(source) }

    context "with a Float assigned under a true condition" do
      let(:source) do
        <<~RUBY
          x = 1.5 if 1 < 2
          puts(x ? x + 1.0 == 2.5 : false)
        RUBY
      end

      it { is_expected.to eq("true\n") }
    end

    context "with an assignment skipped under a false condition" do
      let(:source) do
        <<~RUBY
          x = 1.5 if 2 < 1
          puts(x ? true : false)
        RUBY
      end

      it { is_expected.to eq("false\n") }
    end

    context "with 0.0 assigned" do
      let(:source) do
        <<~RUBY
          x = 0.0 if 1 < 2
          puts(x ? true : false)
        RUBY
      end

      it { is_expected.to eq("true\n") }
    end
  end
end
