# frozen_string_literal: true

=begin

  imports.rb

  aro dom imports.

  by i2097i

=end

module Aro
  module Dom
    class Imports

      def self.get_plain_text_import(prompt_text)
        ensure_imports_dir_exists!

        options = [
          {name: :back, value: :back}
        ] + Dir[::File.join(imports_dir, "*")].map{|f|
          {name: ::File.basename(f), value: f}
        }

        selected_option = Aro::P.default_select(
          prompt_text,
          options
        )

        return false if selected_option.kind_of?(Symbol) &&
          selected_option == :back

        raise "invalid file path! #{selected_option}" unless File.exist?(selected_option)

        Aro::P.say("selected import: #{selected_option}")
        confirmed = Aro::P.p.ask(
          I18n.t(
            "open_menu.imports.confirm_import",
            file_name: File.basename(selected_option),
            prompt_text: prompt_text
          )
        ).to_sym

        if confirmed == :n
          Aro::P.say(I18n.t("open_menu.imports.user_cancelled"))
          return false
        end

        # ready to read import
        ::File.read(selected_option)
      end

      def self.imports_dir
        ::File.join(Aro::Cor.ivar(:OSS_OS_HOME), :imports.to_s)
      end

      private

      def self.ensure_imports_dir_exists!
        FileUtils.mkdir_p(imports_dir) unless Dir.exist?(imports_dir)
        ensure_keep_file_exists!
      end

      def ensure_keep_file_exists!
        keep_file_path = ::File.join(imports_dir, ".keep")
        ::File.open(keep_file_path, "w+") {|f|
          f.write("\n")
        } unless ::File.exist?(keep_file_path)
      end
    end
  end
end
