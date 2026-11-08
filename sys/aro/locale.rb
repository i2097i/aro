=begin

  locale.rb

  aro dom locale.

  by i2097i

=end

module Aro
  module Dom
    class Locale

      def self.add_i18n_key(user_input_text, library_name: :menus, new_i18n_display_key: nil)
        Aro::P.say(__method__)
        library_yaml = load_library(library_name: library_name)
        new_i18n_display_key = i18n_keyify_text(user_input_text) if new_i18n_display_key.nil?

        library_yaml[
          I18n.default_locale.to_s
        ][
          library_name.to_s
        ][
          new_i18n_display_key
        ] = i18n_valuify_text(user_input_text)

        # update library_yaml with new_i18n_display_key
        write_library!(library_named(library_name), library_yaml)

        # return new i18n_display_key
        return new_i18n_display_key
      end

      def self.update_i18n_key(user_input_text, i18n_path, library_name: :menus)
        raise I18n.t("open_menu.errors.invalid_i18n_path") if i18n_path&.to_s.empty?
        Aro::P.say(__method__)
        library_yaml = load_library(library_name: library_name)
        if library_yaml.nil?
          Aro::D.say("todo: handle parse error")
          return
        end
        Aro::V.say("before:")
        Aro::V.say(library_yaml.inspect)
        if library_yaml[I18n.default_locale.to_s][i18n_path].nil?
          add_i18n_key(user_input_text, library_name: library_name, new_i18n_display_key: i18n_path)
          return
        end

        library_yaml[
          I18n.default_locale.to_s
        ][
          library_name.to_s
        ][
          i18n_path
        ] = i18n_valuify_text(user_input_text)

        write_library!(library_named(library_name), library_yaml)
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

      def self.write_library!(library_path, library_yaml)
        # todo: validate yaml
        ::File.open(library_path, "w+") {|f|
          f.write(library_yaml.to_yaml)
        }
        Reiquire.configure_i18n
      end

      def self.valid_library!(library_yaml, library_name: :menus)
        if library_yaml.nil?
          Aro::D.say("todo: handle parse error")
          raise "invalid yaml"
        end
        puts library_yaml.inspect

        default_locale = library_yaml[
          I18n.default_locale.to_s
        ]
        raise "default_locale!" if default_locale.nil?
        library = default_locale[library_name.to_s]
        library_yaml[
          I18n.default_locale.to_s
        ][
          library_name.to_s
        ] = {} if library.nil?

        library_yaml
      end

      def self.library_named(library_name)
        ::File.join(locale_dir, "#{I18n.default_locale}.#{library_name}.yml")
      end

      def self.load_library(library_name: :menus)
        library_filepath = library_named(library_name)
        unless ::File.exist?(library_filepath)
          FileUtils.touch(library_filepath)
        end

        loaded_file = nil
        begin
          Aro::P.say("Psych.load_file(#{library_filepath})")
          loaded_file = Psych.load_file(library_filepath)
        rescue Psych::SyntaxError => e
          Aro::P.say(I18n.t("errors.locale_load_error", named: library_name))
          Aro::P.say(e.inspect)
          Aro::P.say(e.message)
          return nil
        end

        return valid_library!(loaded_file, library_name: library_name)
      end
    end
  end
end
