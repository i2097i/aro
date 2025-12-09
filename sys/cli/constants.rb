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
    SUCCESS: Aro::Mancy::O,
    GENERAL_ERROR: Aro::Mancy::S,
    INVALID_ARG: Aro::Mancy::E,
  }

  CMDS = {
    AOS: {
      RUN: :run,
      WATCH: :watch,
    },
    ARO: {
      CREATE: :create,
      CONFIG: :config,
      DECK: :deck,
      DOM: :dom,
      INIT: :init,
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
      INIT: :init,
      NEW: :new,
    },
  }
  
end
