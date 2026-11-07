=begin

  designer.rb

  aro dom designer.

  by i2097i

=end

module Aro
  module Dom
    class Designer

      def create_menu
        new_name = get_new_value_from_user(
          "#{I18n.t("open_menu.#{__method__}")}(#{menu.class})"
        )

        # create i18n entry for new_name as i18n_display_key
        i18n_display_key = Aro::Dom::Locale.add_i18n_key(new_name)

        # create menu active record with i18n_display_key
        new_menu = Aro::Dom::DataBase.open_menu(i18n_display_key.to_sym)

        # open new menu in designer
        design_menu(new_menu)
      end

      def self.design_menu(menu)
        if menu.nil?
          create_menu
          return
        end

        options = [
          {
            name: "#{:update_menu_title}(#{menu.uuid}): #{menu.localized_name}",
            value: :update_menu_title
          }
        ] + menu.menu_items.map{|mi|
          {
            name: "#{:edit_menu_item}(#{mi.uuid}): #{mi.localized_name}",
            value: mi.uuid
          }
        }

        v = Aro::P.p.select(I18n.t("open_menu.design_menu_title"), options)
        if v == :update_menu_title
          new_name = get_new_value_from_user(
            "rename #{menu.class} '#{menu.localized_name}'"
          )

          Aro::Dom::Locale.update_i18n_key(new_name, menu.i18n_display_key)
        else
          design_menu_item(menu.menu_items.find_by(uuid: v))
        end
      end

      def self.design_menu_item(menu_item)
        return if menu_item.nil?

        #  only name update for now
        new_name = get_new_value_from_user(
          "rename #{menu_item.class} '#{I18n.t(menu_item.i18n_display_key)}'"
        )

        unless new_name.nil? ||
          new_name.kind_of?(FalseClass)


          Aro::P.say([
            to_s,
            "=> writing property :tty_name => '#{new_name}'",
            "=> to #{menu_item.aro_file.class}(#{menu_item.aro_file.uuid})",
            "=> in #{Aro::Dom::DataBase.name} #{menu_item.aro_file.aro_file_path}",
            "=> for #{menu_item.class}(#{menu_item.uuid})"
          ].join("\n"))

          menu_item.aro_file.write!({tty_name: new_name})
        end
      end

      private

      def self.get_new_value_from_user(ask_text)
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