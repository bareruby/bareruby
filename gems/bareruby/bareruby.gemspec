# frozen_string_literal: true

require_relative "lib/bareruby/version"

Gem::Specification.new do |spec|
  spec.name = "bareruby"
  spec.version = Bareruby::VERSION
  spec.authors = ["uproad"]
  spec.email = ["7349115+uproad@users.noreply.github.com"]

  spec.summary = "BareRuby: AOT Ruby compiler and toolchain."
  spec.description = ""
  spec.homepage = "https://github.com/bareruby/bareruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/main/gems/#{spec.name}"
  spec.metadata["changelog_uri"] = "#{spec.metadata["source_code_uri"]}/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "bareruby-compiler", "= 0.1.0"

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
end
