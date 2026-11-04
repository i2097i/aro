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
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "listen"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  # runtime gems
  spec.add_runtime_dependency     "activerecord"
  spec.add_runtime_dependency     "i18n"
  spec.add_runtime_dependency     "sqlite3"
  spec.add_runtime_dependency     "tty-prompt"
end
