=begin
  
  config.rb

  configuration interface.

  by i2097i

=end

module CLI

  # cli entrypoint
  def self.config
    Aro::D.say("#{__FILE__}:#{__method__} was called (todo)...")
  end

  class Config
    include Singleton

    ARO_CONFIG_PREFIX = :ARO_CONFIG_
    ARO_ENV_PREFIX = :ARO_ENV_

    CONFIG_FILE = :".config"

    DATE_FORMAT = "%Y:%m:%d:%H:%M:%S"

    # possible formats
    # 
    # example usage:
    # CLI::Config::FORMATS[:TEXT]
    FORMATS = {
      TEXT: :text,
      JSON: :json,
    }

    # possible dimensions
    # 
    # example usage:
    # CLI::Config::DMS[:DEV_TAROT]
    DMS = {
      DEV_TAROT: :dev_tarot,
      RUBY_FACOT: :ruby_facot,
    }

    DEF_ACCESS = {
      READ: :read,
      WRITE: :write
    }

    # types used in definition
    # 
    # example usage:
    # CLI::Config::DEF_TYPES[:INT][:validator].call(unvalid, CLI::Config::DEF[:DIMENSION])
    DEF_TYPES = {
      INT: {
        name: :int,
        description: I18n.t("cli.config.type_int_description"),
        validator: Proc.new{|unvalid, k, v|
          int_valid = CLI::Config.def_valid?(k, v) &&
            CLI::Config.int_valid?(unvalid)        &&
            unvalid.to_i >= v[:min]                &&
            unvalid.to_i <= v[:max]

          Aro::D.say("validating #{k} (#{CLI::Config::DEF_TYPES[:INT][:name]})")
          Aro::D.say("unvalid = #{unvalid}")
          Aro::D.say("unvalid is#{int_valid ? " " : :" not ".to_s}valid.")
          int_valid
        }
      },
      STRING: {
        name: :string,
        description: I18n.t("cli.config.type_string_description"),
        validator: Proc.new{|unvalid, k, v|
          unvalid.is_a?(String)
        }
      },
      VALUES: {
        name: :values,
        description: I18n.t("cli.config.type_values_description"),
        validator: Proc.new{|unvalid, k, v|
          CLI::Config.def_valid?(k, v) &&
          v[:possible_values].keys.include?(unvalid&.to_sym)
        }
      },
    }

    def validate_config
      invalid_defs = []
      CLI::Config::DEF.each{|k, v|
        var_value = CLI::Config.cvar(k)
        is_valid = CLI::Config::DEF_TYPES[
          v[:type].to_s.upcase.to_sym
        ][:validator].call(var_value, k, v)
        
        invalid_defs << k unless is_valid
      }
      invalid_defs
    end

    # adapts I18n translations to generate bash environment vars.
    # 
    # example usage:
    # CLI::Config::DEF[:Z_MAX]
    DEF = {

      # writable variables
      FORMAT: { # not implemented yet.
        type: :values,
        access: :write,
        description: I18n.t(
          "cli.config.format_description",
          possible_values: CLI::Config::FORMATS.values.join(", ")
        ),
        value: :text,
        possible_values: {
          text: I18n.t("cli.config.text_format_description"),
          json: I18n.t("cli.config.json_format_description")
        }
      },
      DIMENSION: {
        type: :values,
        access: :write,
        description: I18n.t(
          "cli.config.dimension_description",
          possible_values: CLI::Config::DMS.values.join(", ")
         ),
        value: :dev_tarot,
        possible_values: {
          dev_tarot: I18n.t("cli.config.dimension_dev_tarot_description"),
          ruby_facot: I18n.t("cli.config.dimension_ruby_facot_description"),
        }
      },
      DISPLAY_COLUMNS: {
        type: :int,
        access: :write,
        description: I18n.t(
          "cli.config.display_columns_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:XXII] / Aro::Mancy::OS,
        ),
        value: Aro::Mancy::NUMERALS[:VII],
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:XXII] / Aro::Mancy::OS,
      },
      Z: {
        type: :int,
        access: :write,
        description: I18n.t(
          "cli.config.z_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:MMXCVII],
        ),
        value: Aro::Mancy::NUMERALS[:I],
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:MMXCVII],
      },
      Z_MAX: {
        type: :int,
        access: :write,
        description: I18n.t(
          "cli.config.z_max_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:XXII],
        ),
        value: Aro::Mancy::NUMERALS[:VII],
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:XXII],
      },

      # read only variables
      ARO_ENV_O: {
        type: :string,
        access: :read,
        description: I18n.t(
          "cli.config.aro_env_O_description"
        ),
        value: Aro::Mancy::O
      },
      ARO_ENV_S: {
        type: :string,
        access: :read,
        description: I18n.t(
          "cli.config.aro_env_S_description"
        ),
        value: Aro::Mancy::S
      },
      ARO_ENV_N: {
        type: :string,
        access: :read,
        description: I18n.t(
          "cli.config.aro_env_N_description"
        ),
        value: Aro::Mancy::N
      },
      ARO_ENV_PS1: {
        type: :string,
        access: :read,
        description: I18n.t(
          "cli.config.aro_env_PS1_description"
        ),
        value: Aro::Mancy::PS1
      },
      ARO_ENV_NAME_FILE: {
        type: :string,
        access: :read,
        description: I18n.t(
          "cli.config.aro_env_NAME_FILE_description"
        ),
        value: Aro::Mancy::NAME_FILE
      },
      ARO_ENV_I2097I: {
        type: :string,
        access: :read,
        description: I18n.t(
          "cli.config.aro_env_I2097I_description"
        ),
        value: Aro::Mancy::I2097I
      },
      ARO_ENV_YES: {
        type: :string,
        access: :read,
        description: I18n.t(
          "cli.config.aro_env_YES_description"
        ),
        value: Aro::Mancy::YES
      },

      # ...
    }

    def print_cr f_object_id
      file = ObjectSpace._id2ref f_object_id
      Aro::Mancy::OS.times do
        file.write("#\n")
      end
    end

    def print_config_header f_object_id
      file = ObjectSpace._id2ref f_object_id
      file.write("# #{Aro::Mancy::PS1} configuration file.\n")
      file.write("# this file was auto generated by the aro cli.\n")
    end

    def print_def_types f_object_id
      file = ObjectSpace._id2ref f_object_id
      file.write("# CLI::Config::DEF_TYPES\n")
      file.write("# describes the possible types of variables.\n")
      CLI::Config::DEF_TYPES.each{|k, v|
        file.write("# #{k}: #{v[:description]}\n")
      }
      print_cr file.object_id
      file.write("# CLI::Config::DEF\n")
      file.write("# define & expose an aro bash api via ENV variables.\n")
      file.write("# modifying them in this file will change aro's behavior.\n")
    end

    def print_var f_object_id, k, v
      file = ObjectSpace._id2ref f_object_id

      if CLI::Config::DEF[k][:access] == CLI::Config::DEF_ACCESS[:READ]
        var_name = k
      else
        var_name = CLI::Config.cvar_k(k)
      end
      Aro::D.say("access for #{k} is #{CLI::Config::DEF[k][:access]}")
      Aro::D.say("using var_name: #{var_name}")
      file.write("# [#{var_name}]\n")
      file.write("#   => #{I18n.t("cli.config.def_type")}: #{v[:type]}\n")
      case v[:type]
      when CLI::Config::DEF_TYPES[:INT][:name]
        file.write("#   => #{I18n.t("cli.config.minimum")}: #{v[:min]}\n")
        file.write("#   => #{I18n.t("cli.config.maximum")}: #{v[:max]}\n")
      when CLI::Config::DEF_TYPES[:STRING][:name]
        file.write("#   => #{I18n.t("cli.config.type_string_description")}\n")
        file.write("#   => use \"double quotes\" if there are any spaces.\n")
      when CLI::Config::DEF_TYPES[:VALUES][:name]
        file.write("#   => #{I18n.t("cli.config.possible_values")}:\n")
        v[:possible_values].each{|name, description|
          file.write("#   => #{name} - #{description}\n")
        }
      end
      file.write("export #{var_name}=#{v[:value]}\n")
      print_cr file.object_id
    end

    def generate_config
      # todo: localize generated config text
      Aro::D.say(I18n.t("cli.config.generating_default_config", name: CLI::Config.config_filepath))
      File.open(CLI::Config.config_filepath, "w+") do |file|
        print_config_header file.object_id
        print_cr file.object_id
        print_def_types file.object_id
        print_cr file.object_id
        CLI::Config::DEF.each{|k, v|
          print_var file.object_id, k, v
        }
        print_cr file.object_id
      end
    end

    def initialize
      return unless Aro::Mancy.is_aro_space? && Aro::Mancy.is_initialized?
      unless File.exist?(CLI::Config.config_filepath)
        generate_config
      end

      source_config
    end

    def self.display_config
      Aro::D.say("getting display config...")
      columns = CLI::Config.cvar(:DISPLAY_COLUMNS)
      Aro::D.say("DISPLAY_COLUMNS: #{columns}")

      # default
      width = CLI::Config::DEF[:DISPLAY_COLUMNS][:value]
      if columns.respond_to?(:to_i)
        # user setting
        columns = columns.to_i
        width = columns.to_i.pow(Aro::Mancy::OS)
      end
      Aro::D.say("WIDTH: #{width}")

      {
        COLUMNS: columns,
        WIDTH: width,
        DIVIDER: :"-".to_s
      }
    end

    def self.config_filepath
      File.join(Aro::Db.base_aro_dir, CLI::Config::CONFIG_FILE.to_s)
    end

    def self.def_valid?(key, deff)
      def_valid = deff == CLI::Config::DEF[key]
      unless def_valid
        Aro::D.say("invalid def! #{key} => #{deff}")
      end

      def_valid
    end

    def self.int_valid?(unvalid)
      !unvalid&.to_i.nil?
    end

    def self.evar(suffix)
      ENV[CLI::Config.evar_k(suffix)]
    end

    def self.evar_k(suffix)
      "#{CLI::Config::ARO_ENV_PREFIX}#{suffix}"
    end

    def self.cvar(suffix)
      ENV[CLI::Config.cvar_k(suffix)]
    end

    def self.cvar_k(suffix)
      "#{CLI::Config::ARO_CONFIG_PREFIX}#{suffix}"
    end

    def source_config
      Aro::D.say(I18n.t("cli.config.sourcing_config", name: CLI::Config.config_filepath))
      File.read(CLI::Config.config_filepath).split("\n").select{|line|
        line.match?(/export #{:ARO_}/)
      }.map{|line| 
        line.gsub("export ", "").split("=")
      }.each{|kv|
        Aro::D.say("variable to set: #{kv}")
        ENV[kv[0]] = kv[1] # source
        Aro::D.say("value actually set: #{ENV[kv[0]]}")
      }
      
      # todo: implement
      invalid_defs = validate_config
      CLI::Config::DEF.keys.each{|dfk|
        Aro::D.say("$#{CLI::Config.cvar_k(dfk)}=#{CLI::Config.cvar(dfk)}")
      }
      Aro::D.say("invalid_defs: #{invalid_defs}")

      # todo: set all invalid_refs to default in ENV
      # invalid_defs.each{|id| 

      # }
    end

  end
end
