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
end
