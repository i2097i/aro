=begin

  designer.rb

  aro dom designer.

  by i2097i

=end

module Aro
  module Dom
    class Designer
      ACTION_LJUST = 22
      CLASS_LJUST = 33

      def self.design_aro
        env_home_val = ENV[:HOME.to_s]
        Aro::P.say(:"checking for bash env var $HOME in ruby ENV".to_s)
        Aro::P.say(:"$HOME is set to #{env_home_val}".to_s)
        abs_home = Aro::P.p.ask(:"use alternative aro_root? (empty to use $HOME): ".to_s)
        raise "missing required value for aro_root!" if abs_home.nil? && env_home_val.nil?
        aro_home_dir = abs_home || env_home_val
        oss_om_base_dir = ::File.join(aro_home_dir, Aro::Mancy::ARO_DIRECTORY.to_s)
        Aro::P.say("FileUtils.mkdir_p(#{oss_om_base_dir})")
        FileUtils.mkdir_p(oss_om_base_dir)

        Aro::P.say("Aro::Cor.set_ivar(:OSS_OM_HOME, #{File.absolute_path(aro_home_dir)})")
        Aro::Cor.set_ivar(:OSS_OM_HOME, File.absolute_path(aro_home_dir))

        if File.absolute_path(Dir.pwd) != File.absolute_path(Aro::Cor.ivar(:OSS_OM_HOME))
          Aro::P.say("run the following commands to continue:")
          Aro::P.say("$ cd #{Aro::Cor.ivar(:OSS_OM_HOME)} && oss_om")
          Aro::P.say("exiting...")
          exit
        else
          Aro::P.say("Aro::Dom::Oss_OpenMenu.boot!")
          Aro::Dom::Oss_OpenMenu.boot!
        end
        design
      end

      def self.design
        if Aro::Cor.ivar(:OSS_OM_HOME).nil?
          design_aro
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

          design_menu_item(menu.generate_new_item(new_name))
        else
          Aro::P.say("#{new_name.inspect} is invalid")
        end

        design_menu(menu)
      end

      def self.design_menu(menu = nil)
        return create_menu if menu.nil?

        # action,class,value
        options = [
          {
            name: :back,
            value: :back
          },
          {
            name: :toggle_run_mode,
            value: :toggle_run_mode
          },
          {
            name: "(edit_title)".ljust(ACTION_LJUST) +
              "#{menu.class.name}(#{menu.id})".ljust(CLASS_LJUST) +
              "#{menu.localized_name}",
            value: :edit_title
          }
        ] + menu.menu_items.map{|mi|
          {
            name: "(edit_item)".ljust(ACTION_LJUST) +
              "#{mi.class.name}(#{mi.id})".ljust(CLASS_LJUST) +
              "#{mi.localized_name}",
            value: mi.uuid
          }
        } + [
          {
            name: "(create_item)".ljust(ACTION_LJUST) +
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
              "#{menu_item.class.name}(#{menu_item.id})".ljust(CLASS_LJUST) +
              "#{menu_item.localized_name}",
            value: :edit_title
          },
          {
            name: "(edit_action)".ljust(ACTION_LJUST) +
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
        # {
        #   action_name:,
        #   action_key: Aro::Dom::Action::TYPES[*][:key],
        #   action_params: {
        #     aro_class_name:,
        #     aro_class_method:
        #   }
        # }

        action_name = menu_item.store.get_key("action_name")&.to_sym

        raise "missing action!" if action_name.nil?

        options = [
          {
            name: :back,
            value: :back
          },
          {
            name: "(edit_type)".ljust(ACTION_LJUST) +
              "#{Aro::Dom::Action.name}(#{action_name})".ljust(CLASS_LJUST) +
              "#{menu_item.action_storage_key}",
            value: :edit_type
          },
          {
            name: "(edit_action)".ljust(ACTION_LJUST) +
              "Aro::Dom::MenuItem::Action(#{action_name})".ljust(CLASS_LJUST),
            value: :edit_action
          }
        ]
        v = Aro::P.default_select(
          I18n.t("open_menu.edit_action_for_menu_item", localized_name: menu_item.localized_name, action_name: action_name),
          options
        )

        case v.to_sym
        when :edit_type
          design_action_for(menu_item, overwrite: true)
        when :edit_action
          Aro::Dom::Ma_ain.i2097i_bookmark
          puts :todo_open_action_editor
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
              "#{menu_item.class.name}(#{menu_item.id})".ljust(CLASS_LJUST) +
              "#{menu_item.localized_name}",
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

      def self.get_new_value_from_user(ask_text)
        Aro::P.say(__method__)
        new_val = nil
        user_cancelled = false
        while new_val.nil? && !user_cancelled
          Aro::P.say(ask_text)
          new_val = Aro::P.p.ask(I18n.t("open_menu.get_new_value_from_user"))
          user_cancelled = new_val.nil? || new_val.empty?
          new_val = nil if user_cancelled
        end

        return nil if user_cancelled
        return new_val
      end

    end
  end
end