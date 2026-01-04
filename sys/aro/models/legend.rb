=begin

  legend.rb

  legend object.

  by i2097i

=end

# require_relative :scroll.to_s
require_relative :"./story".to_s

class Aro::Legend < ActiveRecord::Base
  has_one :scroll
  has_many :stories
  belongs_to :story

  # play_to:integer default 11

  after_create :create_story

  private

  def create_story
    self.story = Aro::Story.create()
  end
end
