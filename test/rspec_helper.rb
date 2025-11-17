require :aro.to_s

# rspec cheat sheet:
# https://devhints.io/rspec

RSpec.configure do |config|
  ENV[:ARO_ENV.to_s] = :test.to_s
  # use color in stdout
  config.color = true

  # use color not only in stdout but also in pagers and files
  config.tty = true

  # use the specified formatter
  config.formatter = :documentation

  # suppress stdout
  # config.before { allow($stdout).to receive(:puts) }
end