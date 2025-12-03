module CLI
  class Config
    include Singleton

    ARO_CONFIG_VAR_PREFIX = :ARO_CONFIG_

    CONFIG_FILE = :".config".to_s
    CONFIG_FILE_PATH = "#{Aro::Db.base_aro_dir(Aro::Db.get_name_from_namefile)}/#{CLI::Config::CONFIG_FILE}"

    DEFAULT_CONFIG = {
      # todo:
      FORMAT: {
        value: :text,
        possible_values: [
          {name: :text, description: I18n.t("cli.config.text_format_description")},
          {name: :json, description: I18n.t("cli.config.json_format_description")},
        ]
      }
    }

    def initialize
      unless File.exist(CLI::Config::CONFIG_FILE_PATH)
        generate_config
      end

      source_config

      # todo: get this of this after config developed
      exit(0)
    end

    def generate_config
      Aro::P.say(I18n.t("cli.config.generating_default_config", name: CLI::Config::CONFIG_FILE_PATH))
      File.open(CLI::Config::CONFIG_FILE_PATH, "w") do |file|
        DEFAULT_CONFIG.each{|k, v|
          var_name = "#{CLI::Config::ARO_CONFIG_VAR_PREFIX}#{k}"
          file.write("# #{var_name}:")
          file.write(I18n.t("cli.config.possible_values"))
          file.write("export =#{v[:value]}")
        }
        file.write("\n")
      end
    end

    def source_config
      Aro::P.say(I18n.t("cli.config.sourcing_config", name: CLI::Config::CONFIG_FILE_PATH))
      response = system("source #{CLI::Config::CONFIG_FILE_PATH}")
      Aro::P.say(I18n.t("cli.config.source_config_result", result: response))
    end
  end
end