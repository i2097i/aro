# frozen_string_literal: true

=begin

  book.rb

  aro dom book.

  by i2097i

=end

module Aro
  module Dom
    class Book

      def self.open_table_of_contents!(table_of_contents_item)
        raise "invalid menu item! #{table_of_contents_item.inspect}" unless table_of_contents_item.kind_of?(Aro::Dom::MenuItem)

        puts __method__
        puts table_of_contents_item.inspect
        Aro::Dom::Ma_ain.sane_backtrace!
        return

        # example usage of imports:
        # text = nil
        # while chapter_text.nil? ||
        #   text.empty?

        #   prompt_text = "plain_text_import: (choose file)"
        #   text = Aro::Dom::Imports.get_plain_text_import(prompt_text)
        # end
      end
    end
  end
end
