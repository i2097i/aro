=begin

  log.rb

  log object.

  by i2097i

=end

require_relative :"./deck".to_s

class Aro::Log < ActiveRecord::Base
  belongs_to :deck, :class_name => :"#{Aro::Deck.name}".to_s

  ORDERING = {
    ASC: :asc,
    DESC: :desc
  }
end