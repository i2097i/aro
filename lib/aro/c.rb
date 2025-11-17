module Aro
  DIRS = {
    ARO: Proc.new{Aro::IS_TEST.call ? ".aro_test" : ".aro"},
  }
end