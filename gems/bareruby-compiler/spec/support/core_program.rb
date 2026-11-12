# frozen_string_literal: true

require "digest"
require "fileutils"
require "open3"
require "tmpdir"

module CoreProgram
  OBJECT_DIRECTORY = Dir.mktmpdir
  at_exit { FileUtils.remove_entry(OBJECT_DIRECTORY) }

  def output_of(source)
    Dir.mktmpdir do |directory|
      program = File.join(directory, "program.rb")
      File.write(program, source)
      main, *natives = BareRuby::Compiler::Compilation.new(program, directory).run.cpp_files
      executable = File.join(directory, "program")
      gxx("-I", directory, "-o", executable, main, *natives.map { native_object(it, directory) })
      Open3.capture2(executable).first
    end
  end

  private

  # The key covers the headers as well as the source, not the source alone, because the compilation writes the
  # headers for each program.
  def native_object(source, directory)
    headers = Dir.glob(File.join(directory, "*.hpp")).map { File.read(it) }
    key = Digest::SHA256.hexdigest(([source, File.read(source)] + headers).join("\0"))
    object = File.join(OBJECT_DIRECTORY, "#{key}.o")
    gxx("-c", "-I", directory, "-o", object, source) unless File.exist?(object)
    object
  end

  def gxx(*)
    output, status = Open3.capture2e("g++", "-flto", *)
    raise "g++ failed\n#{output}" unless status.success?
  end
end
