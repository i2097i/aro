=begin
  
  constants.rb

  define constants for the aro cli.

  by i2097i

=end

module CLI

  ARGV0 = ARGV[0]
  ARGV1 = ARGV[1]
  ARGV2 = ARGV[2]

  FLAGS = {
    HELP:     ["-h", "--help"],
    VERSION:  ["-v", "--version"],
  }

  EXIT_CODES = {
    SUCCESS: 0,
    GENERAL_ERROR: 1,
    INVALID_ARG: 3
  }

  CREATE_DECK_ACTIONS = {
    CREATE: :CREATE
  }

  LOAD_DECK_ACTIONS = {
    DRAW:     :DRAW,
    EXPLORE:  :EXPLORE,
    REPLACE:  :REPLACE,
    RESET:    :RESET,
    SHOW:     :SHOW,
    SHUFFLE:  :SHUFFLE,
  }
  
end
