=begin

  locale.rb

  aro dom locale.

  by i2097i

=end

module Aro
  module Dom
    class Locale
      def self.locale_dir
        ::File.join(Aro::Mancy.root_dir, :locale.to_s)
      end
    end
  end
end
