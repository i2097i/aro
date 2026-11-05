=begin

  cmd.rb

  cmd interface.

  by i2097i

=end

module Aro
  class Cmd
    include Singleton

    CMDS = {
      CONSOLE: {
        key: :console,
        description: I18n.t("cmd.commands.console_description"),
        usage: I18n.t("cmd.commands.console_usage")
      },
      CREATE: {
        key: :create,
        description: I18n.t("cmd.commands.create_description"),
        usage: I18n.t("cmd.commands.create_usage")
      },
      COR: {
        key: :cor,
        description: I18n.t("cmd.commands.cor_description"),
        usage: I18n.t("cmd.commands.cor_usage"),
        subcommands: {
          IVARS: {
            key: :ivars,
            description: I18n.t("cmd.subcommands.ivars_description"),
            usage: I18n.t("cmd.subcommands.ivars_usage")
          },
          OVARS: {
            key: :ovars,
            description: I18n.t("cmd.subcommands.ovars_description"),
            usage: I18n.t("cmd.subcommands.ovars_usage")
          }
        }
      },
      TECK: {
        key: :teck,
        description: I18n.t("cmd.commands.teck_description"),
        usage: I18n.t("cmd.commands.teck_usage"),
        subcommands: {
          DRAW: {
            key: :draw,
            description: I18n.t("cmd.subcommands.draw_description"),
            usage: I18n.t("cmd.subcommands.draw_usage")
          },
          EXPLORE: {
            key: :explore,
            description: I18n.t("cmd.subcommands.explore_description"),
            usage: I18n.t("cmd.subcommands.explore_usage")
          },
          NEW: {
            key: :new,
            description: I18n.t("cmd.subcommands.teck_new_description"),
            usage: I18n.t("cmd.subcommands.teck_new_usage")
          },
          REPLACE: {
            key: :replace,
            description: I18n.t("cmd.subcommands.replace_description"),
            usage: I18n.t("cmd.subcommands.replace_usage")
          },
          RESET: {
            key: :reset,
            description: I18n.t("cmd.subcommands.reset_description"),
            usage: I18n.t("cmd.subcommands.reset_usage")
          },
          SHOW: {
            key: :show,
            description: I18n.t("cmd.subcommands.show_description"),
            usage: I18n.t("cmd.subcommands.show_usage")
          },
          SHUFFLE: {
            key: :shuffle,
            description: I18n.t("cmd.subcommands.shuffle_description"),
            usage: I18n.t("cmd.subcommands.shuffle_usage")
          }
        }
      },
      INIT: {
        key: :init,
        description: I18n.t("cmd.commands.init_description"),
        usage: I18n.t("cmd.commands.init_usage")
      }
    }

    def self.display_lines
      JSON.pretty_generate(CMDS).split("\n")
    end
  end
end
