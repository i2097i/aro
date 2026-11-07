=begin

  locale.rb

  aro dom locale.

  by i2097i

=end

module Aro
  module Dom
    class Locale

      def self.add_i18n_key(user_input_text, library = :menus)
        new_i18n_display_key = i18n_keyify_text(user_input_text)
        menu_library_yaml = load_library(library)
        if menu_library_yaml.nil?
          # todo: handle parse error
          return
        end
        menu_library_yaml[I18n.default_locale][new_i18n_display_key] = {
          i18n_display_key: new_i18n_display_key
        }

        # update menu_library_yaml with new_i18n_display_key
        ::File.open(library_named(library), "w") { |f| f.puts menu_library_yaml.to_yaml }

        # return new i18n_display_key
        return new_i18n_display_key
      end

      def self.update_i18n_key(user_input_text, parent_i18n_key, library = :menus)
        menu_library_yaml = load_library(library)
        if menu_library_yaml.nil?
          # todo: handle parse error
          return
        end
        menu_library_yaml[I18n.default_locale][parent_i18n_key] = {
          i18n_display_key: i18n_valuify_text(user_input_text)
        }
        ::File.open(library_named(library), "w") { |f| f.puts menu_library_yaml.to_yaml }
      end

      def self.locale_dir
        ::File.join(Aro::Mancy.root_dir, :locale.to_s)
      end

      def self.i18n_keyify_text(text)
        # downcase'd, gsub non-word characters with "_"
        text.downcase.gsub(/[\W]/, "_")
      end

      def self.i18n_valuify_text(text)
        # gsub non-word characters with " "
        text.gsub(/[\W]/, " ")
      end

      private

      def self.library_named(library_name)
        ::File.join(locale_dir, "#{I18n.default_locale}.#{named}.yml")
      end

      def self.load_library(named = :menus)
        library_filepath = library_named(library_name)
        unless ::File.exist?(library_filepath)
          FileUtils.touch(yaml_file)
        end

        begin
          Psych.load_file(library_filepath)
        rescue Psych::SyntaxError => e
          Aro::P.say(I18n.t("errors.locale_load_error", named: named))
          Aro::P.say(e.inspect)
          Aro::P.say(e.message)
          return nil
        end
      end
    end
  end
end
