=begin

  oss_open_menu.rb

  aro dom oss_open_menu.

  by i2097i

=end

module Aro
  module Dom
    class Oss_OpenMenu

      EXEC_CLASSES = [
        Aro::Dom::Oss_OpenMenu,
        Aro::Dom::Ma_ain
      ]

      def self.boot!
        # soft-load (source vars only) existing .cor
        Aro::P.say("sourcing existing Aro::Cor env...")
        Aro::Cor.instance.load_env

        # set up oss_om workspace
        Aro::P.say("Aro::Dom::Ma_ain.init!")
        return unless Aro::Dom::Ma_ain.init!

        # hard-load (source and generate config if needed)
        Aro::P.say("Aro::Cor.instance.load_env!")
        Aro::Cor.instance.load_env!

        # kick off database
        Aro::P.say("Aro::Db.ensure_connected!")
        Aro::Db.ensure_connected!

        # reload i18n locale configuration
        Aro::P.say("Reiquire.reload_i18n!")
        Reiquire.reload_i18n!

        puts TTY::Font.new(:standard).write(
          "open_menu",
          letter_spacing: 1
        )
      end

      def self.create_exec_oss_om_entry_for(menu_item)
        unless Aro::Dom::Ma_ain.is_encrypted?
          Aro::Dom::Ma_ain.exec_security!
          return
        end

        const_options = [
          {name: :back, value: :back}
        ] + EXEC_CLASSES.map{|oss_om_const|
          {name: oss_om_const.name, value: oss_om_const.name}
        }

        oss_om_const = Aro::P.default_select(
          I18n.t("open_menu.select_exec_oss_om_const"),
          const_options
        )

        return if oss_om_const == :back
        Aro::P.say("oss_om_const '#{oss_om_const}' selected")

        method_options = [{name: :back, value: :back}] +
          oss_om_const.to_s.constantize.methods.map{|m|
            {name: m, value: m}
          }

        oss_om_method = Aro::P.default_select(
          I18n.t("open_menu.select_exec_oss_om_method", class: oss_om_const),
          method_options
        )

        return if oss_om_const == :back
        Aro::P.say("oss_om_method '#{oss_om_method}' selected")

        menu_item.store.save_exec_oss_om_params!(
          oss_om_const,
          oss_om_method
        )

        Aro::Dom::Ma_ain.i2097i_bookmark
      end

      def self.create_exec_system_entry_for(menu_item)
        unless Aro::Dom::Ma_ain.is_encrypted?
          Aro::Dom::Ma_ain.exec_security!
          return
        end

        Aro::Dom::Ma_ain.i2097i_bookmark
      end

      def self.create_exec_data_base_entry_for(menu_item)
        unless Aro::Dom::Ma_ain.is_encrypted?
          Aro::Dom::Ma_ain.exec_security!
          return
        end

        Aro::Dom::Ma_ain.i2097i_bookmark
      end

      private

      def self.open_git_config
        Aro::Dom::Ma_ain.open!(:git_config)
      end

      def self.open_ssh_config
        Aro::Dom::Ma_ain.open!(:ssh_config)
      end
    end
  end
end