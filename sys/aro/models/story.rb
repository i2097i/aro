=begin

  story.rb

  story object.

  by i2097i

=end

require_relative :"./legend".to_s
require_relative :"./chapter".to_s
require_relative :"./player".to_s

class Aro::Story < ActiveRecord::Base
  has_many :chapters
  belongs_to :legend
  belongs_to :chapter, class_name: Aro::Chapter.name
  # belongs_to :dealer, class_name: Aro::Player.name

  after_create :create_chapter

  private

  def create_chapter
    self.chapter = Aro::Chapter.create()
  end
end
