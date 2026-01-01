=begin

  fpxy.rb

  aos fpxy object.

  by i2097i

=end

module Aos
  class Fpxy < ActiveRecord::Base
    # table_name :fpxies
    belongs_to :you

    def get_lines
      [
        I18n.t(
          "flie.fpxies.display",
          you: self.you.name.ljust(Aro::Mancy::NUMERALS[:XIV]),
          cmd: self.cmd.ljust(Aro::Mancy::NUMERALS[:XXXVII])
        )
      ]
    end
  end
end