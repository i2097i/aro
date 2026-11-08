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
        Aro::P.say("FileUtils.chdir(#{aro_home_dir})")
        FileUtils.chdir(aro_home_dir) do
          Aro::P.say("Aro::Cor.instance.load_env")
          Aro::Cor.instance.load_env
          Aro::P.say("Aro::Cor.set_ivar(:OSS_OM_HOME, #{File.absolute_path(aro_home_dir)})")
          Aro::Cor.set_ivar(:OSS_OM_HOME, File.absolute_path(aro_home_dir))
          Aro::P.say("Aro::Db.ensure_connected!")
          Aro::Db.ensure_connected!
          Aro::P.say("Aro::Mancy.init(#{aro_home_dir})")
          Aro::Mancy.init(aro_home_dir)
          Aro::P.say("Reiquire.reload_i18n!")
          Reiquire.reload_i18n!
          # design_menu(Aro::Dom::Menu.first)
        end

        if File.absolute_path(Dir.pwd) != Aro::Cor.ivar(:OSS_OM_HOME)
          Aro::P.say("user needs to cd")
          Aro::P.say("enter $ cd #{Aro::Cor.ivar(:OSS_OM_HOME)}")
          exit
        end
        design
      end


      def self.design
        if Aro::Cor.ivar(:OSS_OM_HOME).nil?
          design_aro
          return
        end
        Aro::Dom::Ma_ain.instance.current_menu = Aro::Dom::DataBase.open_menu(:ma_ain)

        loop do
          selected_menu_item_uuid = Aro::P.p.select(
            "#{Aro::Dom::Ma_ain.instance.current_menu.localized_name}",
            [{name: :open_menu, value: :open_menu}] + Aro::Dom::Ma_ain.instance.current_menu.menu_items.map{|mi| mi.as_tty},
            show_help: :always,
            cycle: true,
            per_page: 11
          )

          if selected_menu_item_uuid == :open_menu
            Aro::Dom::Designer.design_menu(Aro::Dom::Ma_ain.instance.current_menu)
          else
            Aro::Dom::Designer.design_menu_item(
              selected_menu_item_uuid,
              Aro::Dom::Ma_ain.instance.current_menu
            )
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

          menu_item = menu.menu_items.create(tty_name: Aro::Dom::Locale.i18n_keyify_text(new_name))
          Aro::Dom::Locale.add_i18n_key(
            new_name,
            library_name: :menu_items,
            new_i18n_display_key: menu_item.uuid,
          )
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

        v = Aro::P.p.select(
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
        else
          design_menu_item(v, menu)
        end
      end

      def self.design_menu_item(menu_item_uuid = nil, menu)
        return create_menu_item(menu) if menu_item_uuid.nil?

        menu_item = menu.menu_items.find_by(uuid: menu_item_uuid)

        # new_name = get_new_value_from_user(
        #   "rename #{menu_item.class} '#{I18n.t(menu_item.full_i18n_path)}'"
        # )
        # unless new_name.nil? ||
        #   new_name.empty? ||
        #   new_name.kind_of?(FalseClass)

        #   Aro::Dom::Locale.update_i18n_key(
        #     new_name,
        #     menu_item.uuid,
        #     library_name: :menu_items
        #   )
        # else
        #   Aro::P.say("#{new_name.inspect} is invalid")
        # end

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

        v = Aro::P.p.select(
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
          puts "this is where i am working"
          return
        when :back
          return
        end

        # this is for updating data stores
        # todo:
        #   Aro::P.say([
        #     to_s,
        #     "=> writing property :tty_name => '#{new_name}'",
        #     "=> to #{menu_item.aro_file.class}(#{menu_item.aro_file.uuid})",
        #     "=> in #{Aro::Dom::DataBase.name} #{menu_item.aro_file.aro_file_path}",
        #     "=> for #{menu_item.class}(#{menu_item.uuid})"
        #   ].join("\n"))

        #   menu_item.aro_file.write!({tty_name: new_name})
      end

      private

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

        return user_cancelled if user_cancelled
        return new_val
      end

    end
  end
end