# frozen_string_literal: true

=begin

  oss_open_menu.rb

  aro dom oss_open_menu.

  by i2097i

=end

module Aro
  module Dom
    class Oss_OpenMenu

      EXEC_CLASSES = [
        "Aro::Cor",
        "Aro::Dom::Oss_OpenMenu",
        "Aro::Dom::Ma_ain",
        "Aro::Dom::Library",
        "Aro::Dom::Git",
        "Aro::Dom::Ssh"
      ]

      EXEC_METHODS = [
        :open_cor!,
        :open_git!,
        :open_ssh!
      ]

      def self.boot!
        # soft-load (source vars only) existing .cor
        Aro::P.say("sourcing existing Aro::Cor env...")
        Aro::Cor.instance.source_config

        # set up oss_om workspace
        Aro::P.say("Aro::Dom::Ma_ain.init!")
        return unless Aro::Dom::Ma_ain.init!

        # hard-load (source and generate config if needed)
        Aro::P.say("Aro::Cor.instance.load_env!")
        Aro::Cor.instance.load_env!

        # kick off database
        Aro::P.say("Aro::Db.ensure_connected!")
        Aro::Db.ensure_connected!

        # reload i18n locale configuration
        Aro::P.say("Reiquire.reload_i18n!")
        Reiquire.reload_i18n!

        puts TTY::Font.new(:standard).write(
          "f#{Aro::Mancy::ARO_DIRECTORY}",
          letter_spacing: 1
        )
      end

      def self.domain(git_username = nil)
        if git_username.nil?
          git_username = `git config user.name`&.strip
          raise "invalid git config!" if git_username.nil?
        end
        "#{git_username}@oss_om.#{Aro::Dom::Ma_ain.aro_mancy_name}.local"
      end

      def self.install!
        begin
          ensure_global_git!
        rescue RuntimeError => e
          Aro::P.say(e)
          return false
        end
        # soft-load (source vars only) existing .cor
        Aro::P.say("sourcing existing Aro::Cor env...")
        Aro::Cor.instance.source_config

        # set up oss_om workspace
        Aro::P.say("Aro::Dom::Ma_ain.init!")
        Aro::Dom::Ma_ain.init!

        key_path = Aro::Cor.ivar(:OSS_OM_HOME)
        Aro::Dom::Designer.design_oss_om unless !key_path.nil? && Dir.exist?(key_path)

        private_key_path = Aro::Dom::Ssh.id_key_path
        required_local_files = [
          ".gitignore",
          ".git/config",
          File.basename(private_key_path),
          File.basename(private_key_path) + :".pub".to_s,
        ]
        missing_required_files = required_local_files.any?{|rlf| !::File.exist?(rlf)}
        return true unless missing_required_files
        # run the install program until setup is complete
        # return false to cancel
        while missing_required_files do
          gitconfig_path = ::File.join(key_path, ".git/config")
          Aro::P.say("checking for local .git/config at #{gitconfig_path}")
          if ::File.exist?(gitconfig_path)
            Aro::P.say("#{self.name} already installed. continuing...")
            return true if required_local_files.all?{|rlf| ::File.exist?(rlf)}
          else
            Aro::P.say("missing local .git/config!")
            Aro::P.say("setting up local git config...")

            default_git_email = `git config user.email`.strip
            default_text = default_git_email.nil? ? "" : " (default: #{default_git_email})"
            git_email = Aro::Dom::Designer.get_new_value_from_user(
              "enter git config user.email#{default_text}: ",
              "(enter to use default):"
            )
            git_email = default_git_email if git_email.nil?
            if git_email.nil? || git_email.empty?
              Aro::P.say("missing git email! unable to continue #{self.name}.#{__method__}")
              return false
            end
            Aro::P.say("using #{git_email} for email.")

            default_git_username = (`git config user.email`.strip || git_email).split("@")[0]
            git_username = Aro::Dom::Designer.get_new_value_from_user(
              "enter git config user.name (default is #{default_git_username}): ",
              "(enter to use default):"
            )
            git_username ||= default_git_username
            if git_username.nil? || git_username.empty?
              Aro::P.say("missing git username! unable to continue #{self.name}.#{__method__}")
              return false
            end
            Aro::P.say("using #{git_username} for username.")

            unless ::File.exist?(private_key_path)
              key_domain = domain(git_username)

              Aro::P.say("generating new ssh key in #{key_path} using domain #{key_domain}")
              Aro::P.say("ssh-keygen -t RSA -f #{private_key_path} -b #{Aro::Mancy::NUMERALS[:MMXCVII] * 2} -C #{key_domain}")
              keygen_result = `ssh-keygen -t RSA -f #{private_key_path} -b #{Aro::Mancy::NUMERALS[:MMXCVII] * 2} -C "#{key_domain}"`
              Aro::P.say("ssh-keygen result: #{keygen_result}")
              unless ::File.exist?(private_key_path)
                Aro::P.say("oss_om ssh-keygen failed! unable to continue #{self.name}.#{__method__}")
                return false
              end
              system("chmod 700 #{private_key_path}")
              Aro::P.say("#{self.name} uses the project .gitignore to ensure privacy.")
              Aro::P.say("write .gitignore!")
              File.open(".gitignore", "w+") do |f|
                f.write([
                  "#",
                  "#",
                  "# auto-generated by #{self.name} > #{key_domain} on #{Time.now}",
                  "#",
                  "# ignore oss_om private key!",
                  File.basename(private_key_path),
                  "#",
                  "# ignore entire '.oss_om/' directory!",
                  "#{Aro::Dom::Ma_ain::ARO_DIRECTORY.to_s}/*",
                  "#",
                  "#"
                ].join("\n"))
                f.write("\n")
              end
            end

            Aro::P.say("system(git init)")
            system(:"git init".to_s)

            ensure_git_hooks_installed!

            default_config = {
              user_email: git_email,
              user_name: git_username,
              user_signingkey: "#{private_key_path}.pub",
              gpg_format: :ssh,
              commit_gpgsign: true,
              core_editor: :nano
            }.each{|k, v|
              Aro::P.say("system(git config #{k.to_s.gsub("_", ".")} #{v})")
              system(:"git config #{k.to_s.gsub("_", ".")} '#{v}'".to_s)
            }
          end

          Aro::P.say("system(git add .)")
          system(:"git add .".to_s)
          Aro::P.say("system(git commit -m '#{key_domain} initial commit'")
          system(:"git commit -m \"#{key_domain} initial commit\"".to_s)

          Aro::P.say("#{self.name} installed successfully.")
        end

        return true
      end

      def self.create_exec_oss_om_entry_for(menu_item)
        # todo: this is a placeholder
        # remove when is_encrypted complete
        allow_exec_unsecure_oss_om_entries = true

        unless allow_exec_unsecure_oss_om_entries || Aro::Dom::Ma_ain.is_encrypted?
          Aro::P.say(__method__)
          Aro::P.say("redirecting to settings until Aro::Dom::Ma_ain.is_encrypted!")
          Aro::Dom::Ma_ain.exec_settings!
          return
        end

        const_options = [
          {name: :back, value: :back}
        ] + EXEC_CLASSES.map{|exec_class_name|
          {name: exec_class_name, value: exec_class_name}
        }

        selected_const_name = Aro::P.default_select(
          I18n.t("open_menu.select_exec_oss_om_const"),
          const_options
        )

        return if selected_const_name == :back
        Aro::P.say("'#{selected_const_name}' selected")

        selected_const = selected_const_name.constantize
        raise "invalid const! #{selected_const}" unless EXEC_CLASSES.include?(selected_const.name)

        method_options = [{name: :back, value: :back}] +
          selected_const.methods.select{|m|
            selected_const::EXEC_METHODS.include?(m)
          }.map{|m|
            {name: m, value: m}
          }

        selected_method_name = Aro::P.default_select(
          I18n.t("open_menu.select_exec_oss_om_method", class: selected_const_name),
          method_options
        )

        return if selected_method_name == :back
        Aro::P.say("oss_om_method '#{selected_method_name}' selected")

        menu_item.store.save_exec_oss_om_params!(
          selected_const_name.constantize,
          selected_method_name,
          menu_item.localized_name
        )
      end

      def self.create_exec_system_entry_for(menu_item)
        unless Aro::Dom::Ma_ain.is_encrypted?
          Aro::P.say(__method__)
          Aro::P.say("redirecting to settings until Aro::Dom::Ma_ain.is_encrypted!")
          Aro::Dom::Ma_ain.exec_settings!
          return
        end

        puts __method__
        puts self.name
        Aro::Dom::Ma_ain.sane_backtrace!
      end

      def self.create_exec_data_base_entry_for(menu_item)
        unless Aro::Dom::Ma_ain.is_encrypted?
          Aro::P.say(__method__)
          Aro::P.say("redirecting to settings until Aro::Dom::Ma_ain.is_encrypted!")
          Aro::Dom::Ma_ain.exec_settings!
          return
        end

        puts __method__
        puts self.name
        Aro::Dom::Ma_ain.sane_backtrace!
      end

      def self.open_git!
        Aro::Dom::Git.open!
      end

      def self.open_ssh!
        Aro::Dom::Ssh.open!
      end

      def self.open_cor!
        Aro::Cor.open!
      end

      private

      def self.ensure_global_git!
        raise "git not installed!" unless Aro::Mancy::O == system(:"which -s git".to_s).to_s.strip.to_i
        raise "git not configured!" unless system(:"git config user.name".to_s) || false
      end

      def self.ensure_git_hooks_installed!
        raise "git not initialized!" unless Dir.exist?(".git")
        pre_commit_hook_path = ::File.join(
          Aro::Cor.ivar(:OSS_OM_HOME),
          ".git/hooks/pre-commit"
        )

        Aro::Dom::Ma_ain.sane_backtrace!
        puts "todo: ensure pre-commit file matches current generated content"
        pre_commit_validation_allow_invalid = true
        pre_commit_hook_valid = ::File.exist?(pre_commit_hook_path) && pre_commit_validation_allow_invalid
        return true if pre_commit_hook_valid
        Aro::P.say("warning: pre_commit_validation_allow_invalid is set to #{pre_commit_validation_allow_invalid}!")

        File.open(pre_commit_hook_path, "w+") do |f|
          f.write([
            "#",
            "#",
            "# auto-generated by #{self.name} > #{self.domain} on #{Time.now}",
            "#",
            "# #{self.name} pre-commit git hook.",
            "#",
            "# validate .gitignore",
            "# tar oss_om using id_oss_om keypair",
            "echo '#{self.name} pre-commit hook running'",
            "echo 'todo:'",
            "echo 'initialize tar_oss_om.tar.gz'",
          ].join("\n"))
          f.write("\n")
        end
        Aro::P.say("system(chmod +x #{pre_commit_hook_path}")
        system("chmod +x #{pre_commit_hook_path}")
        Aro::P.say("git hook installed successfully.")
      end

    end
  end
end