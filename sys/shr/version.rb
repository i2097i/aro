=begin
  
  version.rb

  aro version.

  by i2097i

=end

module Aro
  VERSION = :"0.1.9"
  RELEASE_NOTES = :"this version".to_s + [
    "adds improved views.",
    "adds aro gameplay within an arodome game room.",
    "adds ability to set config ivars from aos."
  ].join(",")
end
