=begin

  chapter.rb

  chapter object.

  by i2097i

=end

# require_relative :story.to_s
# require_relative :statement.to_s

class Aro::Chapter < ActiveRecord::Base
  has_many :statements
  belongs_to :story

end
