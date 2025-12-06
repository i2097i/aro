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

    # possible envs
    # 
    # example usage:
    # CLI::Config::ENVS[:PRODUCTION]
    ENVS = {
      DEVELOPMENT: :development,
      PRODUCTION: :production,
      TEST: :test,
    }

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

          Aro::V.say("validating #{k} (#{CLI::Config::DEF_TYPES[:INT][:name]})")
          Aro::V.say("unvalid = #{unvalid}")
          Aro::V.say("unvalid is#{int_valid ? " " : :" not ".to_s}valid.")
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

    def self.int_valid?(unvalid)
      !unvalid&.to_i.nil?
    end

    def self.def_valid?(key, deff)
      def_valid = deff == CLI::Config::DEF[key]
      unless def_valid
        Aro::V.say("invalid def! #{key} => #{deff}")
      end

      def_valid
    end

    def validate_config
      invalid_defs = []
      CLI::Config::DEF.each{|k, v|        
        invalid_defs << k unless validate_value(CLI::Config.ivar(k), k, v)
      }
      invalid_defs
    end

    def validate_value(var_value, k, v)
      CLI::Config::DEF_TYPES[
        v[:type].to_s.upcase.to_sym
      ][:validator].call(var_value, k, v)
    end   

    # adapts I18n translations to generate bash environment vars.
    # 
    # example usage:
    # CLI::Config::DEF[:Z_MAX]
    DEF = {
      # writable variables
      ENV: {
        type: :values,
        access: CLI::Config::DEF_ACCESS[:WRITE],
        value: CLI::Config::ENVS[:PRODUCTION],
        description: I18n.t(
          "cli.config.env_description",
          possible_values: CLI::Config::ENVS.values.join(", ")
         ),
        possible_values: {
          development: I18n.t("cli.config.env_development_description"),
          production: I18n.t("cli.config.env_production_description"),
          test: I18n.t("cli.config.env_test_description"),
        }
      },
      FORMAT: { # not implemented yet.
        type: :values,
        implemented: false,
        access: CLI::Config::DEF_ACCESS[:WRITE],
        value: CLI::Config::FORMATS[:TEXT],
        description: I18n.t(
          "cli.config.format_description",
          possible_values: CLI::Config::FORMATS.values.join(", ")
        ),
        possible_values: {
          text: I18n.t("cli.config.text_format_description"),
          json: I18n.t("cli.config.json_format_description")
        }
      },
      DIMENSION: {
        type: :values,
        access: CLI::Config::DEF_ACCESS[:WRITE],
        value: CLI::Config::DMS[:DEV_TAROT],
        description: I18n.t(
          "cli.config.dimension_description",
          possible_values: CLI::Config::DMS.values.join(", ")
         ),
        possible_values: {
          dev_tarot: I18n.t("cli.config.dimension_dev_tarot_description"),
          ruby_facot: I18n.t("cli.config.dimension_ruby_facot_description"),
        }
      },
      DISPLAY_COLUMNS: {
        type: :int,
        access: CLI::Config::DEF_ACCESS[:WRITE],
        value: Aro::Mancy::NUMERALS[:VII],
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:XXII] / Aro::Mancy::OS,
        description: I18n.t(
          "cli.config.display_columns_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:XXII] / Aro::Mancy::OS,
        ),
      },
      Z: {
        type: :int,
        access: CLI::Config::DEF_ACCESS[:WRITE],
        value: Aro::Mancy::NUMERALS[:I],
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:MMXCVII],
        description: I18n.t(
          "cli.config.z_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:MMXCVII],
        ),
      },
      Z_MAX: {
        type: :int,
        access: CLI::Config::DEF_ACCESS[:WRITE],
        value: Aro::Mancy::NUMERALS[:VII],
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:XXII],
        description: I18n.t(
          "cli.config.z_max_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:XXII],
        ),
      },

      # read only variables
      ARO_ENV_O: {
        type: :string,
        access: CLI::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::O,
        description: I18n.t(
          "cli.config.aro_env_O_description"
        ),
      },
      ARO_ENV_S: {
        type: :string,
        access: CLI::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::S,
        description: I18n.t(
          "cli.config.aro_env_S_description"
        ),
      },
      ARO_ENV_OS: {
        type: :string,
        access: CLI::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::OS,
        description: I18n.t(
          "cli.config.aro_env_OS_description"
        ),
      },
      ARO_ENV_N: {
        type: :string,
        access: CLI::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::N,
        description: I18n.t(
          "cli.config.aro_env_N_description"
        ),
      },
      ARO_ENV_PS1: {
        type: :string,
        access: CLI::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::PS1,
        description: I18n.t(
          "cli.config.aro_env_PS1_description"
        ),
      },
      ARO_ENV_NAME_FILE: {
        type: :string,
        access: CLI::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::NAME_FILE,
        description: I18n.t(
          "cli.config.aro_env_NAME_FILE_description"
        ),
      },
      ARO_ENV_I2097I: {
        type: :string,
        access: CLI::Config::DEF_ACCESS[:READ],
        description: I18n.t(
          "cli.config.aro_env_I2097I_description"
        ),
        value: Aro::Mancy::I2097I
      },
      ARO_ENV_YES: {
        type: :string,
        access: CLI::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::YES,
        description: I18n.t(
          "cli.config.aro_env_YES_description"
        ),
      },

      # ...
    }

    def initialize
      Aro::P.say("config init")
      return unless Aro::Mancy.is_aro_space? && Aro::Mancy.is_initialized?
      unless File.exist?(CLI::Config.config_filepath)
        generate_config
      end

      source_config
      setup_env
    end

    def self.config_filepath
      File.join(Aro::Db.base_aro_dir, CLI::Config::CONFIG_FILE.to_s)
    end

    def self.display_config
      Aro::V.say("getting display config...")
      columns = CLI::Config.ivar(:DISPLAY_COLUMNS)
      Aro::V.say("DISPLAY_COLUMNS: #{columns}")

      # default
      width = CLI::Config::DEF[:DISPLAY_COLUMNS][:value]
      if columns.respond_to?(:to_i)
        # user setting
        columns = columns.to_i
        width = columns.to_i.pow(Aro::Mancy::OS)
      end
      Aro::V.say("WIDTH: #{width}")

      {
        COLUMNS: columns,
        WIDTH: width,
        DIVIDER: :"-".to_s
      }
    end

    # out vars
    def self.ovar(suffix)
      ENV[CLI::Config.ovar_k(suffix)]
    end
    # out vars
    def self.ovar_k(suffix)
      "#{CLI::Config::ARO_ENV_PREFIX}#{suffix}"
    end

    # in vars
    def self.ivar(suffix)
      ENV[CLI::Config.ivar_k(suffix)]
    end
    # in vars
    def self.ivar_k(suffix)
      "#{CLI::Config::ARO_CONFIG_PREFIX}#{suffix}"
    end

    def setup_env
      # do not change - update $ARO_CONFIG_ENV .aro/.config file
      # 
      # default is production
      varenv = CLI::Config.ivar(:ENV)
      var_valid = validate_value(varenv, :ENV, CLI::Config::DEF[:ENV])
      ENV[:ARO_ENV.to_s] = var_valid ? varenv : CLI::Config::ENVS[:PRODUCTION].to_s
      Aro::D.say("setup_env: #{ENV[:ARO_ENV.to_s]}")
    end

    def self.is_test?
      ENV[:ARO_ENV.to_s] == CLI::Config::ENVS[:TEST].to_s
    end

    def source_config
      Aro::D.say(I18n.t("cli.config.sourcing_config", name: CLI::Config.config_filepath))
      File.read(CLI::Config.config_filepath).split("\n").select{|line|
        line.match?(/export #{:ARO_}/)
      }.map{|line| 
        line.gsub("export ", "").split("=")
      }.each{|kv|
        Aro::V.say("variable to set: #{kv}")
        ENV[kv[0]] = kv[1] # source
        Aro::V.say("value actually set: #{ENV[kv[0]]}")
      }
      
      # todo: implement
      invalid_defs = validate_config
      CLI::Config::DEF.keys.each{|dfk|
        Aro::V.say("$#{CLI::Config.ivar_k(dfk)}=#{CLI::Config.ivar(dfk)}")
      }
      Aro::V.say("todo: invalid_defs: #{invalid_defs}")
      # todo: set all invalid_refs to default in ENV
      # invalid_defs.each{|id| 

      # }
    end

    def generate_config
      # todo: localize generated config text
      Aro::D.say(I18n.t("cli.config.generating_default_config", name: CLI::Config.config_filepath))
      File.open(CLI::Config.config_filepath, "w+") do |file|
        # intro
        Aro::Mancy::OS.times do
          print_div file.object_id
        end
        # header
        print_div file.object_id
          print_sr file.object_id
            print_config_header file.object_id
          print_sr file.object_id
        print_div file.object_id
        
        print_osr file.object_id
        
        # def_types
        print_div file.object_id
          print_sr file.object_id
            print_def_types file.object_id
          print_sr file.object_id
        print_div file.object_id

        print_osr file.object_id
        
        # var section
        print_div file.object_id
          print_sr file.object_id
            print_var_section file.object_id
          print_sr file.object_id
        print_div file.object_id

        print_osr file.object_id

        # vars
        CLI::Config::DEF.each{|k, v|
          print_var file.object_id, k, v
        }

        print_osr file.object_id
        
        # var section
        print_div file.object_id
          print_sr file.object_id
            print_var_section file.object_id
          print_sr file.object_id
        print_div file.object_id

        print_osr file.object_id
        # outro
        Aro::Mancy::OS.times do
          print_div file.object_id
        end
        file.write("\n")
      end
    end

    def print_div f_object_id
      file = ObjectSpace._id2ref f_object_id
      file.write("#{"#" * Aro::Mancy::NUMERALS[:VIII].pow(2)}\n")
    end

    def print_sr f_object_id
      file = ObjectSpace._id2ref f_object_id
      Aro::Mancy::S.times do
        file.write("#\n")
      end
    end

    def print_osr f_object_id
      Aro::Mancy::OS.times do
        print_sr f_object_id
      end
    end

    def print_config_header f_object_id
      file = ObjectSpace._id2ref f_object_id
      file.write("# #{Aro::Mancy::PS1} configuration file.\n")
      file.write("# this file was auto generated by the aro cli.\n")
    end

    def print_var_section f_object_id
      file = ObjectSpace._id2ref f_object_id
      file.write("# VARIABLE SECTION!\n")
    end

    def print_def_types f_object_id
      file = ObjectSpace._id2ref f_object_id
      file.write("# CLI::Config::DEF_TYPES\n")
      file.write("# describes the possible types of variables.\n")
      CLI::Config::DEF_TYPES.each{|k, v|
        file.write("# #{k}: #{v[:description]}\n")
      }
      print_osr f_object_id
      file.write("# CLI::Config::DEF\n")
      file.write("# define & expose an aro bash api via ENV variables.\n")
      file.write("# there are two types of bash vars in aro.\n")
      file.write("# 1) in vars (ivars). \n")
      file.write("#     => ivars enter aro from this file during aro init.\n")
      file.write("#     => aro validates them and uses them unless unvalid.\n")
      file.write("#     => otherwise aro will use the defaults listed below.\n")
      file.write("# 2) out vars (ovars).\n")
      file.write("#     => ovars are read-only vars that aro exposes to bash.\n")
      file.write("#     => this is useful because it provides a bash interface\n")
      file.write("#     => which can be used to write programs on top of aro.\n")
    end

    def print_var f_object_id, k, v
      file = ObjectSpace._id2ref f_object_id

      is_ovar = CLI::Config::DEF[k][:access] == CLI::Config::DEF_ACCESS[:READ]
      if is_ovar
        var_name = k
      else
        var_name = CLI::Config.ivar_k(k)
      end
      Aro::V.say("access for #{k} is #{CLI::Config::DEF[k][:access]}")
      Aro::V.say("using var_name: #{var_name}")
      file.write("# [#{var_name}] (#{is_ovar ? :ovar : :ivar})\n")
      file.write("#   => #{I18n.t("cli.config.def_type")}: #{v[:type]}\n")
      case v[:type]
      when CLI::Config::DEF_TYPES[:INT][:name]
        file.write("#   => #{I18n.t("cli.config.type_int_description")}\n")
        file.write("#   => #{I18n.t("cli.config.minimum")}: #{v[:min]}\n")
        file.write("#   => #{I18n.t("cli.config.maximum")}: #{v[:max]}\n")
      when CLI::Config::DEF_TYPES[:STRING][:name]
        file.write("#   => #{I18n.t("cli.config.type_string_description")}\n")
        file.write("#   => use \"double quotes\" if there are any spaces.\n")
      when CLI::Config::DEF_TYPES[:VALUES][:name]
        file.write("#   => #{I18n.t("cli.config.type_values_description")}\n")
        file.write("#   => #{I18n.t("cli.config.possible_values")}:\n")
        print_sr f_object_id
        v[:possible_values].each{|name, description|
          file.write("#     => #{name}\n")
          print_sr f_object_id
          file.write("#           =>#{description}\n")
          print_sr f_object_id
        }
      end
      print_osr f_object_id
      file.write("#   => description:\n")
      file.write("#   => #{v[:description]}\n")
      file.write("export #{var_name}=#{v[:value]}\n")
      print_osr f_object_id
    end

  end
end
