=begin

  ilog.rb

  aos ilog object.

  by i2097i

=end

require_relative :"./base_model".to_s

module Aos
  class Ilog < ActiveRecord::Base
    belongs_to :you

    def get_lines
      [
        I18n.t(
          "data.ilogs.display",
          you: self.you.name.ljust(Aro::Mancy::NUMERALS[:XIV]),
          cmd: self.cmd.ljust(Aro::Mancy::NUMERALS[:XXXVII]),
          timestamp: self.created_at.strftime(Aos::Os::DATE_FORMAT),
          pwd: Aos::Os.osify(self.pwd).ljust(Aro::Mancy::NUMERALS[:XIV])
        )
      ]
    end
  end
end