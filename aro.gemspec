# coding: utf-8

require 'aro/version'

Gem::Specification.new do |spec|
  spec.name          = "aro"
  spec.version       = Aro::VERSION
  spec.authors       = ["i2097i"]
  spec.email         = ["i2097i@hotmail.com"]
  spec.summary       = "follow the way of the aro eht."
  spec.description   = "a cli for tarot."
  spec.homepage      = "https://github.com/i2097i/aro"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = ["aro"]
  spec.require_paths = ["lib"]
  spec.files         = Dir["lib/**/*.rb"] +
    Dir["db/**/*.rb"] +
    Dir["locale/**/*.yml"]

  # development gems
  spec.add_development_dependency "bundler",      "~> 2.7", ">= 2.7.2"
  spec.add_development_dependency "rake",         "~> 13.3", ">= 13.3.1"
  spec.add_development_dependency "rspec",        "~> 3.13", ">= 3.13.2"


  # runtime gems
  spec.add_runtime_dependency     "x",            "~> 0.16", ">= 0.16.0"
  spec.add_runtime_dependency     "i18n",         "~> 1.14", ">= 1.14.7"
  spec.add_runtime_dependency     "activerecord", "~> 8.1", ">= 8.1.1"
  spec.add_runtime_dependency     "sqlite3",      "~> 2.8", ">= 2.8.0"
  spec.add_runtime_dependency     "tty-prompt"
  # spec.add_runtime_dependency "require_all",  "~> 3.0", ">= 3.0.0"
end
