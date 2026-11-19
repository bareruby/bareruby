# frozen_string_literal: true

require "tmpdir"

RSpec.describe BareRuby::Compiler::Pipeline do
  describe "#run" do
    subject { described_class.new("main.rb").run.result.inspect_text }

    around { |example| Dir.mktmpdir { |directory| Dir.chdir(directory) { example.run } } }

    before { File.write("main.rb", source) }

    context "with a program that assigns a local variable and passes it to a call" do
      let(:source) { <<~RUBY }
        x = 1
        puts x
      RUBY

      let(:expected_text) { <<~TEXT }
        program
          source_unit path="main.rb" scope=0 @1
            body scope=0 @1
              assignment @1
                local_target variable=0(x) @1
                literal kind=integer value=1 @1
              call name=puts safe_navigation=false @2
                arguments forwarding=false @2
                  local_read variable=0(x) @2
      TEXT

      it { is_expected.to eq(expected_text) }
    end
  end
end
