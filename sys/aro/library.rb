# frozen_string_literal: true

=begin

  library.rb

  aro dom library.

  by i2097i

=end

module Aro
  module Dom
    class Library

      EXEC_METHODS = [
        :create_book!,
      ]

      BOOK_PARAMS = {
        title: nil,
        author_name: nil,
        isbn: nil,
        copyright_year: nil,
        published_by: nil
      }

      def self.open!
        Aro::Dom::Ma_ain.open!(:library)
      end

      def self.navigate_to_book!(uuid = nil)
        book_menu = Aro::Dom::Menu.find_by(uuid: uuid)
        raise "invalid uuid! #{uuid}" if book_menu.nil?

        Aro::Dom::Ma_ain.navigate_to!(book_menu)
      end

      def self.information!(uuid = nil, data = {})
        book_menu = Aro::Dom::Menu.find_by(uuid: uuid)
        raise "invalid uuid! #{uuid}" if book_menu.nil?

        puts TTY::Font.new(:standard).write(
          book_menu.localized_name,
          letter_spacing: 1
        )
        Aro::P.less(JSON.pretty_generate(data))
      end

      def self.table_of_contents!(uuid = nil)
        book_menu = Aro::Dom::Menu.find_by(uuid: uuid)
        raise "invalid uuid! #{uuid}" if book_menu.nil?

        puts "todo: load book #{__method__} here."
        puts "open table_of_contents menu"
        Aro::Dom::Ma_ain.sane_backtrace!
      end

      def self.create_book!
        # the book model is inline simple-form schema.
        # every value treated as a string and not required.

        # get a copy of the book params hash
        book_params = Aro::Dom::Library::BOOK_PARAMS.dup

        while book_params.any?{|k, v| v.nil?} do
          options = [
            {name: :back, value: :back}
          ] + book_params.map{|k, v|
            {name: "#{k.to_s.ljust(Aro::Dom::Designer::ITEM_TITLE_JUSTIFY)} (#{v.nil? ? :not_set : v})", value: k}
          }

          selected_option = Aro::P.default_select(
            I18n.t("open_menu.library.new_book_select"),
            options
          )

          case selected_option.to_sym
          when :back
            confirmed = true
            if book_params.any?{|k, v| !v.nil?}
              confirmed = Aro::P.p.ask("unsaved changes. go back anyway? (y/n): ").to_sym
              confirmed = confirmed == :y
            end
            return Aro::Dom::Ma_ain.open! if confirmed
          when :title, :author_name, :isbn, :copyright_year, :published_by
            new_value = Aro::Dom::Designer.get_new_value_from_user(selected_option)
            Aro::P.say("setting #{selected_option} to #{new_value}")
            book_params[selected_option] = new_value
          end
        end

        unless generate_new_book!(book_params)
          raise "book title must be unique!"
        end
      end

      private

      def self.generate_new_book!(book_params)
        new_book_title_key = book_params[:title].downcase.gsub(" ", "_").to_sym

        book_menu = open_book(
          new_book_title_key,
          book_params
        )

        directory = book_data_base.data_base_directories.find_by(
          unix_path: new_book_title_key
        )
        return false if directory.nil?

        # generate menus data_base > library menu item for new book here
        library_menu = Aro::Dom::DataBase.open_menu(:library)
        library_contents_item = library_menu.generate_new_item(new_book_title_key, for_type: :system)
        library_contents_item.aro_file.write!(
          Aro::Dom::Store.build_exec_oss_om_params!(
            new_book_title_key,
            Aro::Dom::Library,
            "navigate_to_book!",
            [directory.uuid]
          )
        )

        # open and navigate to new book
        Aro::Dom::Ma_ain.navigate_to!(book_menu)
        return true
      end

      def self.open_book(book_title_sym, book_params = nil)
        # get the books directory
        @@data_base_directory = book_data_base.data_base_directories.find_or_create_by(
          unix_path: book_title_sym
        )

        book_menu = Aro::Dom::Menu.find_by(uuid: @@data_base_directory.uuid)
        if book_menu.nil?
          # find or create the new book_menu
          book_menu = Aro::Dom::Menu.create(uuid: @@data_base_directory.uuid)
          Aro::Dom::Locale.add_i18n_key(
            book_title_sym.to_s,
            new_i18n_display_key: book_menu.uuid
          )
        end

        generate_book_items_for!(book_menu, book_params)

        # return the book_menu
        return book_menu
      end

      def self.book_data_base
        Aro::Dom::DataBase.find_or_create_by(unix_path: :books)
      end

      def self.generate_book_items_for!(book_menu, book_params)
        raise "invalid book_menu!" if book_menu.nil?
        return unless !book_menu.nil? && book_menu.menu_items.empty?
        raise "invalid directory! #{@@data_base_directory}" if @@data_base_directory.nil? ||
          @@data_base_directory.uuid != book_menu.uuid

        # validate book_params
        # todo: validate uniqueness of params
        raise "invalid book_params! #{book_params}" unless book_params.all?{|k, v| !v.nil?} &&
          book_params.keys.all?{|k| Aro::Dom::Library::BOOK_PARAMS.keys.include?(k.to_sym)}

        [:information, :table_of_contents].each{|k|
          i = book_menu.generate_new_item(k, for_type: :system)

          # store book book_param values with :information menu item
          action_data = k == :information ? book_params : {}

          i.aro_file.write!(
            Aro::Dom::Store.build_exec_oss_om_params!(
              k,
              Aro::Dom::Library,
              "#{k}!",
              [book_menu.uuid],
              action_data
            )
          )
        }
      end

    end
  end
end
