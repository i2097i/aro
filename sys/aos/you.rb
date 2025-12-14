=begin

  you.rb

  aos you object.

  by i2097i

=end

module Aos
  class You < ActiveRecord::Base
    after_update :clear_aos_display

    private

    def clear_aos_display
      Aos::Os.instance.display_lines = [Aos::Os.osify(pwd, true)]
    end
  end
end