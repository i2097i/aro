=begin
  
  constants.rb

  define constants for the aro cli.

  by i2097i

=end

module CLI

  FLAGS = {
    HELP:         [:"-h", :"--help"],
    SHOW_COUNT:   [:"-n", :"--count"],
    SHOW_ORDER:   [:"-o", :"--order"],
    VERSION:      [:"-v", :"--version"],
  }

  EXIT_CODES = {
    SUCCESS: 0,
    GENERAL_ERROR: 1,
    INVALID_ARG: 3
  }

  CMDS = {
    ARO: {
      CREATE: :create,
      CONFIG: :config,
      DECK: :deck,
      DOM: :dom,
    },
    CONFIG: {
      # ...
    },
    DECK: {
      DRAW: :draw,
      EXPLORE: :explore,
      NEW: :new,
      REPLACE: :replace,
      RESET: :reset,
      SHOW: :show,
      SHUFFLE: :shuffle,
    },
    DOM: {
      NEW: :new,
      INIT: :init,
    }
  }
  
end
