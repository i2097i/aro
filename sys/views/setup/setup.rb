=begin
  
  views/setup/setup.rb

  the setup view.

  by i2097i

=end

require_relative :"../base".to_s

module Aro
  module Vi
    class Setup < Aro::Vi::Base
      def self.generate(model)
        # todo: implement this
        CLI::Nterface.exit_error_invalid_usage!
      end

      def self.draw(model)
        # todo: implement this
        CLI::Nterface.exit_error_invalid_usage!
      end
    end
  end
end