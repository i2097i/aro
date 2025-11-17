require_relative './deck'

class Log < ActiveRecord::Base
  belongs_to :deck, :class_name => :Deck.to_s
end