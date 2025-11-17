module Aro
  IS_TEST = Proc.new{ENV[:ARO_ENV.to_s] == :test.to_s}
end