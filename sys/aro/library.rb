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
        :new_book!
      ]

      def self.open!
        Aro::Dom::Ma_ain.open!(:library)
      end

      def self.new_book!
        book_params = {
          title: nil,
          author_name: nil,
          isbn: nil,
          copyright_year: nil,
          published_by: nil
        }

        while book_params.any?{|k, v| v.nil?} do
          # book_params.select{|k, v| v.nil? || v.empty?}.each{|k, v|
          #   book_params[k] = Aro::P.ask(I18n.t("open_menu.library.get_book_param", key: k))
          # }
          # options = [{name: :back, value: :back}] + book_params.map{|k, v|
          #   {
          #     name: 
          #   }
          # }

          # selected_menu_item_uuid = Aro::P.default_select(
          #   "#{Aro::Dom::Ma_ain.instance.current_menu.localized_name}",
          #   options
          # )

          # case selected_menu_item_uuid.to_sym
          # when :back
          #   # todo: call_stack_bread_crumbs
          #   Aro::Dom::Ma_ain.back!
          # when :open_menu
          #   design_menu(
          #     Aro::Dom::Ma_ain.instance.current_menu
          #   )
          # else
          #   if Aro::Dom::Ma_ain.running?
          #     selected_menu_item = Aro::Dom::Ma_ain.instance.current_menu.menu_items.find_by(
          #       uuid: selected_menu_item_uuid
          #     )
          #     selected_menu_item.run!
          #   else
          #     design_menu_item(
          #       selected_menu_item_uuid,
          #       Aro::Dom::Ma_ain.instance.current_menu
          #     )
          #   end
          # end
        end
      end

      private

      def self.generate_new_book!
        # todo:
      end

    end
  end
end
