# frozen_string_literal: true

=begin

  tar_go_for_root_sec.rb

  oss_om encryption system

  by i2097i

=end

module Aro
  module Dom
    module TarGoForRootSec
      extend ActiveSupport::Concern

      # todo: implement tar_go_for_root_sec
      # currently only for Aro::Dom::MenuItem

      included do
        before_create :do_encryption_stuff
        before_commit :do_encryption_stuff
      end

      private

      def do_encryption_stuff
        Aro::P.say(__method__)
        Aro::P.say("todo: #{self.class.name}")
        Aro::P.say(self.class.inspect)
        Aro::Dom::Ma_ain.i2097i_bookmark
      end
    end
  end
end

