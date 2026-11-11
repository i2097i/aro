# frozen_string_literal: true

=begin

  designer.rb

  aro dom designer.

  by i2097i

=end

module Aro
  module Dom
    class Designer
      ACTION_LJUST = 27
      VALUE_LJUST = 27
      CLASS_LJUST = 27

      def self.design_oss_om
        oss_home_path = File.expand_path(Dir.pwd)
        Aro::P.say("set up oss_om home directory in '#{oss_home_path}'?")
        abs_home = Aro::Dom::Designer.get_new_value_from_user(
          "leave empty to use '#{oss_home_path}' as home.",
          "enter new path: "
        )
        raise "missing required value for oss_om home!" if abs_home.nil? && oss_home_path.nil?
        oss_home_path = abs_home.nil? ? oss_home_path : File.expand_path(abs_home)
        oss_om_base_dir = ::File.join(oss_home_path, Aro::Mancy::ARO_DIRECTORY.to_s)
        Aro::P.say("FileUtils.mkdir_p(#{oss_om_base_dir})")
        FileUtils.mkdir_p(oss_om_base_dir)

        Aro::P.say("Aro::Cor.set_ivar(:OSS_OM_HOME, #{oss_home_path})")
        Aro::Cor.set_ivar(:OSS_OM_HOME, oss_home_path)

        if ::File.expand_path(Dir.pwd) != Aro::Cor.ivar(:OSS_OM_HOME)
          Aro::P.say("run the following commands to continue:")
          Aro::P.say("$ cd #{Aro::Cor.ivar(:OSS_OM_HOME)} && oss_om")
          Aro::P.say("exiting...")
          exit
        else
          # restarts Aro::Dom::Ma_ain.reign!
          raise "needs install!"
        end
        design
      end

      def self.design
        if Aro::Cor.ivar(:OSS_OM_HOME).nil?
          design_oss_om
          return
        end

        Aro::P.say("Aro::Dom::Ma_ain.open!")
        Aro::Dom::Ma_ain.open!
        loop do
          selected_menu_item_uuid = Aro::P.default_select(
            "#{Aro::Dom::Ma_ain.instance.current_menu.localized_name}",
            Aro::Dom::Ma_ain.get_current_options
          )

          case selected_menu_item_uuid.to_sym
          when :back
            # todo: call_stack_bread_crumbs
            Aro::Dom::Ma_ain.back!
          when :open_menu
            design_menu(
              Aro::Dom::Ma_ain.instance.current_menu
            )
          else
            if Aro::Dom::Ma_ain.running?
              selected_menu_item = Aro::Dom::Ma_ain.instance.current_menu.menu_items.find_by(
                uuid: selected_menu_item_uuid
              )
              selected_menu_item.run!
            else
              design_menu_item(
                selected_menu_item_uuid,
                Aro::Dom::Ma_ain.instance.current_menu
              )
            end
          end
        end
      end

      def self.create_menu
        new_name = get_new_value_from_user(
          "#{Aro::Dom::Menu.name} #{I18n.t("open_menu.designer.#{__method__}")}"
        )

        unless new_name.nil? ||
            new_name.empty? ||
            new_name.kind_of?(FalseClass)

          # create menu active record with i18n_display_key
          new_menu = Aro::Dom::DataBase.open_menu(Aro::Dom::Locale.i18n_keyify_text(new_name))

          # open new menu in designer
          design_menu(new_menu)
        else
          Aro::P.say("#{new_name.inspect} is invalid")
        end
      end

      def self.create_menu_item(menu)
        return create_menu if menu.nil?

        new_name = get_new_value_from_user(
          "#{__method__} #{Aro::Dom::MenuItem.name} for menu: '#{I18n.t(menu.full_i18n_path)}'"
        )

        unless new_name.nil? ||
          new_name.empty? ||
          new_name.kind_of?(FalseClass)

          new_item = menu.generate_new_item(new_name)
          raise "error generating new item!" if new_item.nil?

          design_menu_item(new_item.uuid, menu)
        else
          Aro::P.say("#{new_name.inspect} is invalid")
          design_menu(menu)
        end
      end

      def self.design_menu(menu = nil)
        return create_menu if menu.nil?

        # action,value,class
        options = [
          {
            name: :back,
            value: :back
          },
          {
            name: "(#{Aro::Dom::Ma_ain::UNICODE_KEYS[:yinyang]}) toggle_run_mode".ljust(ACTION_LJUST) +
              ":#{Aro::Dom::Ma_ain::RUN_MODES[Aro::Dom::Ma_ain.instance.run_mode || Aro::Mancy::O]}".ljust(VALUE_LJUST) +
              "available_modes: #{Aro::Dom::Ma_ain::RUN_MODES.to_s}".ljust(CLASS_LJUST),
            value: :toggle_run_mode
          },
          {
            name: "(#{Aro::Dom::Ma_ain::UNICODE_KEYS[:yinyang]}) open_shell".ljust(ACTION_LJUST) +
              "open a bash session".ljust(VALUE_LJUST),
            value: :open_shell
          },
          {
            name: "(edit_title)".ljust(ACTION_LJUST) +
              "#{menu.localized_name}".ljust(VALUE_LJUST) +
              "#{menu.class.name}(#{menu.id})".ljust(CLASS_LJUST),
            value: :edit_title
          }
        ] + menu.menu_items.map{|mi|
          {
            name: "(edit_item)".ljust(ACTION_LJUST) +
              "#{mi.localized_name}".ljust(VALUE_LJUST) +
              "#{mi.class.name}(#{mi.id})".ljust(CLASS_LJUST),
            value: mi.uuid
          }
        } + [
          {
            name: "(create_item)".ljust(ACTION_LJUST) +
              "".ljust(VALUE_LJUST) +
              "#{Aro::Dom::MenuItem.name}(+)".ljust(CLASS_LJUST),
            value: :create_item
          }
        ]

        v = Aro::P.default_select(
          I18n.t("open_menu.edit_menu_localized_name", localized_name: menu.localized_name),
          options
        )

        case v.to_sym
        when :edit_title
          new_name = get_new_value_from_user(
            "rename #{menu.class} '#{menu.localized_name}'"
          )
          unless new_name.nil? ||
            new_name.empty? ||
            new_name.kind_of?(FalseClass)

            Aro::Dom::Locale.update_i18n_key(
              new_name,
              menu.uuid
            )
          else
            Aro::P.say("#{new_name.inspect} is invalid")
          end
        when :create_item
          create_menu_item(menu)
        when :back
          return
        when :toggle_run_mode
          Aro::Dom::Ma_ain.toggle_run_mode
          return
        when :open_shell
          Aro::P.say("starting bash session for #{`whoami`.strip}")
          system(:bash.to_s)
        else
          design_menu_item(v, menu)
        end
      end

      def self.design_menu_item(menu_item_uuid = nil, menu)
        return create_menu_item(menu) if menu_item_uuid.nil?

        menu_item = menu.menu_items.find_by(uuid: menu_item_uuid)

        # action,class,value
        options = [
          {
            name: :back,
            value: :back
          },
          {
            name: "(edit_title)".ljust(ACTION_LJUST) +
              "#{menu_item.localized_name}".ljust(VALUE_LJUST) +
              "#{menu_item.class.name}(#{menu_item.id})".ljust(CLASS_LJUST),
            value: :edit_title
          },
          {
            name: "(edit_action)".ljust(ACTION_LJUST) +
              "#{menu_item.action_display_text}".ljust(VALUE_LJUST) +
              "Aro::Dom::MenuItem::Action(+)".ljust(CLASS_LJUST),
            value: :edit_action
          }
        ]

        v = Aro::P.default_select(
          I18n.t("open_menu.edit_menu_item_localized_name", localized_name: menu_item.localized_name),
          options
        )

        case v.to_sym
        when :edit_title
          new_name = get_new_value_from_user(
            "rename #{menu_item.class} '#{menu_item.localized_name}'"
          )
          unless new_name.nil? ||
            new_name.empty? ||
            new_name.kind_of?(FalseClass)

            Aro::Dom::Locale.update_i18n_key(
              new_name,
              menu_item.uuid,
              library_name: :menu_items
            )
          else
            Aro::P.say("#{new_name.inspect} is invalid")
          end
        when :edit_action
          design_action_for(menu_item)
        when :back
          return
        end
      end

      def self.edit_action_for(menu_item)
        action_name = menu_item.store.safe_get_key("action_name")&.to_sym

        raise "missing action!" if action_name.nil?

        options = [
          {
            name: :back,
            value: :back
          },
          {
            name: "(edit_type)".ljust(ACTION_LJUST) +
              "#{menu_item.action_storage_key}".ljust(VALUE_LJUST) +
              "#{Aro::Dom::Action.name}(#{action_name})".ljust(CLASS_LJUST),
            value: :edit_type
          },
          {
            name: "(edit_method)".ljust(ACTION_LJUST) +
              "#{menu_item.action_display_text}".ljust(VALUE_LJUST) +
              "Aro::Dom::MenuItem::Action(#{action_name})".ljust(CLASS_LJUST),
            value: :edit_method
          }
        ]
        v = Aro::P.default_select(
          I18n.t("open_menu.edit_action_for_menu_item", localized_name: menu_item.localized_name, action_name: action_name),
          options
        )

        case v.to_sym
        when :edit_type
          design_action_for(menu_item, overwrite: true)
        when :edit_method
          # todo: case when for oss_om_entry types here
          Aro::Dom::Oss_OpenMenu.create_exec_oss_om_entry_for(menu_item)
        end
      end

      def self.design_action_for(menu_item, overwrite: false)
        return if menu_item.nil?
        return edit_action_for(menu_item) if menu_item.actionable? && !overwrite

        # action,class,value
        options = [
          {
            name: :back,
            value: :back
          }
        ] + Aro::Dom::Action::TYPES.keys.map{|k|
          {
            name: "(#{k})".ljust(ACTION_LJUST) +
              "#{menu_item.localized_name}".ljust(VALUE_LJUST) +
              "#{menu_item.class.name}(#{menu_item.id})".ljust(CLASS_LJUST),
            value: k
          }
        }

        v = Aro::P.default_select(
          I18n.t("open_menu.design_action_for_menu_item", localized_name: menu_item.localized_name),
          options
        )

        case v.to_sym
        when :back
          return
        else
          Aro::Dom::Action.create(v, menu_item)
        end
      end

      def self.get_new_value_from_user(ask_text, prompt_text_override = nil)
        Aro::P.say(__method__)
        new_val = nil
        user_cancelled = false
        while new_val.nil? && !user_cancelled
          Aro::P.say(ask_text)
          puts "\n"
          new_val = Aro::P.p.ask(prompt_text_override || I18n.t("open_menu.get_new_value_from_user"))
          user_cancelled = new_val.nil? || new_val.empty?
          new_val = nil if user_cancelled
        end

        return nil if user_cancelled
        return new_val
      end

    end
  end
end