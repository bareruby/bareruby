# frozen_string_literal: true

require "open3"
require "tmpdir"

module CoreProgram
  def output_of(source)
    Dir.mktmpdir do |directory|
      program = File.join(directory, "program.rb")
      File.write(program, source)
      compilation = BareRuby::Compiler::Compilation.new(program, directory).run
      executable = File.join(directory, "program")
      build_output, build_status = Open3.capture2e("g++", "-flto", "-I", directory, "-o", executable,
                                                   *compilation.cpp_files)
      raise "g++ failed\n#{build_output}" unless build_status.success?

      Open3.capture2(executable).first
    end
  end
end
