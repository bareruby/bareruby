# frozen_string_literal: true

require "tmpdir"

RSpec.describe BareRuby::Compiler::Pass::ASTIR::CreateBareRubyAST do
  describe "#run" do
    subject { described_class.new("main.rb").run.result.inspect_text }

    around { |example| Dir.mktmpdir { |directory| Dir.chdir(directory) { example.run } } }

    before { File.write("main.rb", source) }

    context "with an empty source" do
      let(:source) { "" }

      let(:expected_text) { <<~TEXT }
        program
          source_unit path="main.rb" scope=0 @1
            body scope=0 @1
      TEXT

      it { is_expected.to eq(expected_text) }
    end
  end
end
