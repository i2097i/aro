ENV[:ARO_ENV.to_s] = :test.to_s

require :aro.to_s

# name for aro instance used in tests
TESTING_NAME = :success

# name for deck used in tests
TESTING_DECK = :test

# rspec cheat sheet:
# https://devhints.io/rspec

RSpec.configure do |config|
  # use color in stdout
  config.color = true

  # use color not only in stdout but also in pagers and files
  config.tty = true

  # use the specified formatter
  config.formatter = :documentation # :progress

  # suppress stdout
  # config.before { allow($stdout).to receive(:puts) }
end
