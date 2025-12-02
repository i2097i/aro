require_relative './deck'

class Aro::Log < ActiveRecord::Base
  belongs_to :deck, :class_name => :"Aro::Deck".to_s
end