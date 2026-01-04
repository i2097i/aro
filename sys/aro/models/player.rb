=begin

  player.rb

  player object.

  by i2097i

=end

# require_relative :scroll.to_s
# require_relative :statement.to_s

class Aro::Player < ActiveRecord::Base
  has_many :statements
  belongs_to :scroll
end
