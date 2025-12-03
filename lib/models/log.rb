require_relative :"./deck".to_s

class Aro::Log < ActiveRecord::Base
  ALL = :all
  DEFAULT_COUNT = 1
  ORDERING = {
    ASC: :ASC,
    DESC: :DESC
  }

  belongs_to :deck, :class_name => :"Aro::Deck".to_s
end