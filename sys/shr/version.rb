=begin
  
  version.rb

  aro version.

  by i2097i

=end

module Aro
  VERSION = :"0.1.7"
  RELEASE_NOTES = :"this version".to_s + [
    "adds views",
    "adds ivars and ovars",
    "adds verbose logging",
  ].join(",")
end
