=begin

  tlog.rb

  teck tlog object.

  by i2097i

=end

require_relative :"./teck".to_s

class Aro::Tlog < ActiveRecord::Base
  belongs_to :teck

  ORDERING = {
    ASC: :asc,
    DESC: :desc
  }

end