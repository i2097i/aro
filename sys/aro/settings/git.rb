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
        git_menu = Aro::Dom::DataBase.open_menu(:git)
        generate_git_menu_items! if Aro::Mancy::S == git_menu.menu_items.count
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

      private

      def self.generate_git_menu_items!
        git_menu = Aro::Dom::DataBase.open_menu(:git)
        # todo: generate git menu items if needed here
        existing_item = git_menu.menu_items.first
        raise "missing existing item in #{self.name}.#{__method__}!" if existing_item.nil?
        EXEC_METHODS.each{|method_name|
          menu_item = existing_item || git_menu.generate_new_item(method_name, for_type: :system)

          git_menu.rename_item(menu_item, method_name) unless existing_item.nil?
          menu_item.aro_file.write!(
            Aro::Dom::Store.build_exec_oss_om_params!(
              self,
              method_name,
              "#{:git} #{method_name}"
            )
          )
          # clear existing item var
          existing_item = nil unless existing_item.nil?
        }
      end

    end
  end
end
