=begin

  statement.rb

  statement object.

  by i2097i

=end

class Aro::Statement < ActiveRecord::Base
  belongs_to :player
  belongs_to :chapter
end