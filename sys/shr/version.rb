=begin
  
  version.rb

  aro version.

  by i2097i

=end

module Aro
  VERSION = :"0.2.6"
  RELEASE_NOTES = [
    :removes_aos,
    :removes_ino,
    :reduces_ruby_4_0_7_to_3_4_7,
    :adds_menus_and_data,
  ].join("\n:")
end
