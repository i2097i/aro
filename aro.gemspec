=begin

  aro.gemspec

  aro gem specification.

  by i2097i

=end

require_relative :"sys/shr/version".to_s

Gem::Specification.new do |spec|
  spec.name          = "aro"
  spec.version       = Aro::VERSION.to_s
  spec.authors       = ["i2097i"]
  spec.email         = ["i2097i@hotmail.com"]
  spec.description   = "a cli for tarot."
  spec.summary       = Aro::RELEASE_NOTES.to_s
  spec.homepage      = "https://github.com/i2097i/aro"
  spec.license       = "MIT"
  spec.files         = `git ls-files`.split("\n").reject{|p| p.match?(/^(spec|.release|.*.gem$)/)}
  spec.bindir        = "bin"
  spec.executables   = ["aro"]
  spec.require_paths = ["sys"]
  spec.required_ruby_version = ">= 3.4.7"

  # development gems
  spec.add_development_dependency "bundler",      "~> 2.7", ">= 2.7.2"
  spec.add_development_dependency "rake",         "~> 13.3", ">= 13.3.1"
  spec.add_development_dependency "rspec",        "~> 3.13", ">= 3.13.2"
  spec.add_development_dependency "listen",       "~> 3.9", ">= 3.9.0"

  # runtime gems
  spec.add_runtime_dependency     "i18n",         "~> 1.14", ">= 1.14.7"
  spec.add_runtime_dependency     "activerecord", "~> 8.1", ">= 8.1.1"
  spec.add_runtime_dependency     "sqlite3",      "~> 2.8", ">= 2.8.0"
  spec.add_runtime_dependency     "tty-prompt",   "~> 0.23.1", ">= 0.23.1"
end
