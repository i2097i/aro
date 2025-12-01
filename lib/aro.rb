# TODO: this doesn't work
# require :"active_support/time_with_zone".to_s

# require aro directories
[
  :aro,
  :models,
].each{|dir|
  Dir[File.join(
    __dir__,
    dir.to_s,
    :"**/*.rb".to_s
  )].each { |file| require file}
}

module Aro
  # TODO: this doesn't work
  # Time.zone = ActiveSupport::TimeZone[Time.now.gmtoff].tzinfo.name
end