require_relative :"./deck".to_s

class Aro::Log < ActiveRecord::Base
  ORDERING = {
    ASC: :asc,
    DESC: :desc
  }

  belongs_to :deck, :class_name => :"#{Aro::Deck.name}".to_s
end