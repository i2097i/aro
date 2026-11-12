# frozen_string_literal: true

=begin

  git.rb

  aro dom git.

  by i2097i

=end

module Aro
  module Dom
    class Git

      EXEC_METHODS = [
        :status,
        :log,
        :config
      ]

      def self.open!
        Aro::Dom::Ma_ain.open!(:git)
      end

      def self.status
        Aro::P.say("system(git status)")
        system(:"git status".to_s)
      end

      def self.log
        Aro::P.say("system(git log)")
        system(:"git log".to_s)
      end

      def self.config
        Aro::P.say("system(git config list --local)")
        system(:"git config list --local".to_s)
      end

    end
  end
end
