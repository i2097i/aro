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
    TAROT:        [:"+t", :"-t"],
    VERSION:      [:"-v", :"--version"],
  }

  EXIT_CODES = {
    SUCCESS: Aro::Mancy::O,
    GENERAL_ERROR: Aro::Mancy::S,
    INVALID_ARG: Aro::Mancy::E,
  }

  CMDS = {
    ARO: {
      CREATE: :create,
      COR: :cor,
      TECK: :teck,
      DOM: :dom,
      INIT: :init,
    },
    COR: {}, # see Aos::Cor
    TECK: {
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
