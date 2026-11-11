=begin

  aro.gemspec

  aro gem specification.

  by i2097i

=end

require_relative :"sys/shr/version".to_s

Gem::Specification.new do |spec|
  spec.name          = Aro.name.downcase
  spec.version       = Aro::VERSION.to_s
  spec.authors       = ["i2097i"]
  spec.email         = ["i2097i@hotmail.com"]
  spec.description   = "aro is a unix utility for designing and creating linux applications."
  spec.summary       = Aro::RELEASE_NOTES.to_s
  spec.homepage      = "https://github.com/i2097i/aro"
  spec.license       = "MIT"
  spec.files         = `git ls-files`.split("\n").reject{|p| p.match?(/^(spec|.release|.*.gem$)/)}
  spec.bindir        = "bin"
  spec.executables   = ["oss_om"]
  spec.require_paths = ["sys"]
  spec.required_ruby_version = ">= 3.4.7"

  # development gems
  spec.add_development_dependency "bundler",              "~> 4.0", ">= 4.0.22"
  spec.add_development_dependency "listen",              "~> 3.10", ">= 3.10.1"
  spec.add_development_dependency "rake",              "~> 13.4", ">= 13.4.2"
  spec.add_development_dependency "rspec",              "~> 3.13", ">= 3.13.2"

  # runtime gems
  spec.add_runtime_dependency     "activerecord",              "~> 8.1", ">= 8.1.4.1"
  spec.add_runtime_dependency     "i18n",              "~> 1.15", ">= 1.15.2"
  spec.add_runtime_dependency     "sqlite3",              "~> 2.10", ">= 2.10.2"
  spec.add_runtime_dependency     "tty-prompt",              "~> 0.23", ">= 0.23.1"
  spec.add_runtime_dependency     "tty-font",              "~> 0.5", ">= 0.5.0"
end
