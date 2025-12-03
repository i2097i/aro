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
  config.formatter = :progress

  # suppress stdout
  # config.before { allow($stdout).to receive(:puts) }
end

def rmrf(dir_path)
  if File.exist?(dir_path)
    rm_cmd = "rm -rf #{dir_path}"
    # Aro::P.say(rm_cmd)
    system(rm_cmd)
  end
end