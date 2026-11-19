# frozen_string_literal: true

require "tmpdir"

RSpec.describe BareRuby::Compiler::Pass::ASTIR::CreateBareRubyAST do
  describe "#run" do
    subject { described_class.new("main.rb").run.result.inspect_text }

    around { |example| Dir.mktmpdir { |directory| Dir.chdir(directory) { example.run } } }

    before { File.write("main.rb", source) }

    let(:source_header) { <<~TEXT.chomp }
      program
        source_unit path="main.rb" scope=0 @1
          body scope=0 @1
    TEXT

    context "with an empty source" do
      let(:source) { "" }

      let(:expected_text) { <<~TEXT }
        program
          source_unit path="main.rb" scope=0 @1
            body scope=0 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with nil" do
      let(:source) { "nil" }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=nil value=nil @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with true" do
      let(:source) { "true" }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=true value=nil @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with false" do
      let(:source) { "false" }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=false value=nil @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an integer literal" do
      let(:source) { "1_000" }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=integer value=1000 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a float literal" do
      let(:source) { "1_000.5" }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=float value="1000.5" @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a string literal" do
      let(:source) { '"a\n"' }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=string value="a\\n" @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a symbol literal" do
      let(:source) { ":a" }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=symbol value=a @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with statements on two lines" do
      let(:source) { <<~RUBY }
        1
        2
      RUBY

      let(:expected_text) { <<~TEXT }
        #{source_header}
              literal kind=integer value=1 @1
              literal kind=integer value=2 @2
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an assignment to a local variable and a read of it" do
      let(:source) { <<~RUBY }
        x = 1
        x
      RUBY

      let(:expected_text) { <<~TEXT }
        #{source_header}
              assignment @1
                local_target variable=0(x) @1
                literal kind=integer value=1 @1
              local_read variable=0(x) @2
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with assignments to two local variables" do
      let(:source) { <<~RUBY }
        x = 1
        y = x
      RUBY

      let(:expected_text) { <<~TEXT }
        #{source_header}
              assignment @1
                local_target variable=0(x) @1
                literal kind=integer value=1 @1
              assignment @2
                local_target variable=1(y) @2
                local_read variable=0(x) @2
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with a compound assignment to a local variable" do
      let(:source) { "x += 1" }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              compound_assignment operator=+ @1
                local_target variable=0(x) @1
                literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an or-assignment to a local variable" do
      let(:source) { "x ||= 1" }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              logical_assignment operator=or @1
                local_target variable=0(x) @1
                literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end

    context "with an and-assignment to a local variable" do
      let(:source) { "x &&= 1" }

      let(:expected_text) { <<~TEXT }
        #{source_header}
              logical_assignment operator=and @1
                local_target variable=0(x) @1
                literal kind=integer value=1 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end
  end
end
