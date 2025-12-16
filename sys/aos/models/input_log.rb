=begin

  input_log.rb

  aos input log object.

  by i2097i

=end

module Aos
  class InputLog < ActiveRecord::Base
    belongs_to :you

    def get_lines
      [
        I18n.t(
          "data.logs.display",
          you: self.you.name,
          cmd: self.cmd,
          timestamp: self.created_at.strftime(Aos::Os::DATE_FORMAT),
          pwd: Aos::Os.osify(self.pwd)
        )
      ]
    end
  end
end