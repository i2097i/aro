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
        # the book model is inline simple-form schema.
        # every value treated as a string and not required.

        book_params = {
          title: nil,
          author_name: nil,
          isbn: nil,
          copyright_year: nil,
          published_by: nil
        }

        while book_params.any?{|k, v| v.nil?} do
          options = [{name: :back, value: :back}] + book_params.map{|k, v| {name: k, value: k}}
          selected_option = Aro::P.default_select(
            I18n.t("open_menu.library.new_book_select"),
            options
          )

          case selected_option.to_sym
          when :back
            return Aro::Dom::Ma_ain.open!
          when :title, :author_name, :isbn, :copyright_year, :published_by
            book_params[selected_option] = Aro::Dom::Designer.get_new_value_from_user(selected_option)
          end

          Aro::P.say("book_params:")
          Aro::P.less(JSON.pretty_generate(book_params))
        end

        generate_new_book!(book_params)
      end

      private

      def self.generate_new_book!(book_params)
        # todo:
      end

    end
  end
end
