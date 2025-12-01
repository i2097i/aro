module Aro
  DIRS = {
    ARO: Proc.new{Aro::IS_TEST.call ? ".aro_test" : ".aro"},
  }

  AROYES = "aroyes"

  NUMERALS = {
    O:    0,
    I:    1,
    II:   2,
    III:  3,
    IV:   4,
    V:    5,
    VI:   6,
    VII:  7,
    VIII: 8,
    IX:   9,
    X:    10,
    XI:   11,
    XII:  12,
    XIII: 13,
    XIV:  14,
    XV:   15,
    XVI:  16,
    XVII: 17,
    XVIII:18,
    XIX:  19,
    XX:   20,
    XXI:  21,
  }
end
