require_relative "./deck"

class Aro::Log < ActiveRecord::Base
  ALL = :all
  DEFAULT_COUNT = 1
  ORDERING = {
    ASC: :asc,
    DESC: :desc
  }

  belongs_to :deck, :class_name => :"#{Aro::Deck.name}".to_s
end