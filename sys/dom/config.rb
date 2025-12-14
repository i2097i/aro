=begin
  
  config.rb

  dom config interface.

  by i2097i

=end

module Aro

  # cli entrypoint
  def self.config
    Aro::Config.process_config_command(ARGV)
  end

  class Config
    include Singleton

    attr_accessor :config_path, :display_lines

    ARO_CONFIG_PREFIX = :ARO_CONFIG_
    ARO_ENV_PREFIX = :ARO_ENV_

    CONFIG_FILE = :".config"

    DATE_FORMAT = "%Y:%m:%d:%H:%M:%S"

    # possible envs
    # 
    # example usage:
    # Aro::Config::ENVS[:PRODUCTION]
    ENVS = {
      DEVELOPMENT: :development,
      PRODUCTION: :production,
      TEST: :test,
    }

    # possible formats
    # 
    # example usage:
    # Aro::Config::FORMATS[:TEXT]
    FORMATS = {
      TEXT: :text,
      JSON: :json,
    }

    # possible dimensions
    # 
    # example usage:
    # Aro::Config::DMS[:DEV_TAROT]
    DMS = {
      DEV_TAROT: :dev_tarot,
      RUBY_FACOT: :ruby_facot,
    }

    # ovar and ivar access
    #
    # example usage:
    # Aro::Config::DEF_ACCESS[:READ]
    DEF_ACCESS = {
      READ: :read,
      WRITE: :write
    }

    BOOLS = {
      FALSE: false,
      TRUE: true,
    }

    TYPES = {
      BOOL: :bool,
      INT: :int,
      STRING: :string,
      VALUES: :values
    }

    # types used in definition
    # 
    # example usage:
    # Aro::Config::DEF_TYPES[:INT][:validator].call(unvalid, Aro::Config::DEF[:DIMENSION])
    DEF_TYPES = {
      BOOL: {
        name: Aro::Config::TYPES[:BOOL],
        description: I18n.t("cli.config.type.bool_description"),
        converter: Proc.new{|v|
          if [Aro::Config::BOOLS[:TRUE].to_s, Aro::Mancy::S].include?(v)
            Aro::Config::BOOLS[:TRUE]
          else
            Aro::Config::BOOLS[:FALSE]
          end
        },
        validator: Proc.new{|unvalid, k, v|
          Aro::Config.def_valid?(k, v) &&
          Aro::Config.bool_valid?(unvalid)
        }
      },
      INT: {
        name: :int,
        description: I18n.t("cli.config.type.int_description"),
        converter: Proc.new{|v| v.to_i},
        validator: Proc.new{|unvalid, k, v|
          Aro::V.say("validating #{k} (#{Aro::Config::DEF_TYPES[:INT][:name]})")
          Aro::V.say("unvalid = #{unvalid}")
          Aro::V.say("[min, max] = [#{v[:min]}, #{v[:max]}]")
          int_valid = Aro::Config.def_valid?(k, v) &&
            Aro::Config.int_valid?(unvalid)        &&
            unvalid.to_i >= v[:min]                &&
            unvalid.to_i <= v[:max]
          Aro::V.say("unvalid(#{unvalid}) is#{int_valid ? " " : :" not ".to_s}valid.")
          int_valid
        }
      },
      STRING: {
        name: :string,
        description: I18n.t("cli.config.type.string_description"),
        converter: Proc.new{|v| v.to_s},
        validator: Proc.new{|unvalid, k, v|
          Aro::Config.def_valid?(k, v) &&
          Aro::Config.string_valid?(unvalid)
        }
      },
      VALUES: {
        name: :values,
        description: I18n.t("cli.config.type.values_description"),
        converter: Proc.new{|v| v.to_s},
        validator: Proc.new{|unvalid, k, v|
          Aro::Config.def_valid?(k, v) &&
          v[:possible_values].keys.include?(unvalid&.to_sym)
        }
      },
    }

    def self.bool_valid?(unvalid)
      Aro::Config::BOOLS.values.map{|b| b.to_s.to_sym}.include?(unvalid&.to_s&.to_sym)
    end

    def self.int_valid?(unvalid)
      !unvalid&.to_i.nil?
    end

    def self.string_valid?(unvalid)
      unvalid.is_a?(String)
    end

    def self.def_valid?(key, deff)
      def_valid = deff == Aro::Config::DEF[key]
      unless def_valid
        Aro::V.say("invalid def! #{key} => #{deff}")
      end

      def_valid
    end

    def validate_config
      invalid_vars = []
      Aro::Config::DEF.each{|k, v|
        is_valid = v[:access] == Aro::Config::DEF_ACCESS[:READ]
        unless is_valid
          is_valid = valid_var?(Aro::Config.ivar(k), k, v)
        end
        invalid_vars << k unless is_valid
      }
      invalid_vars
    end

    def valid_var?(var_value, k, v)
      Aro::V.say(v)
      return true if v[:access] == Aro::Config::DEF_ACCESS[:READ]

      Aro::Config::DEF_TYPES[
        v[:type].to_s.upcase.to_sym
      ][:validator].call(var_value, k, v)
    end

    def convert_var_for_def(k)
      Aro::Config::DEF_TYPES[
        Aro::Config::DEF[k][:type].upcase
      ][:converter].call(ENV[Aro::Config.ivar_k(k)])
    end

    # adapts I18n translations to generate bash environment vars.
    # 
    # example usage:
    # Aro::Config::DEF[:Z_MAX]
    DEF = {

      #
      # => ivars
      #
      ENV: {
        type: Aro::Config::TYPES[:VALUES],
        access: Aro::Config::DEF_ACCESS[:WRITE],
        value: Aro::Config::ENVS[:PRODUCTION],
        description: I18n.t("cli.config.env.description"),
        possible_values: {
          development: I18n.t("cli.config.env.development_description"),
          production: I18n.t("cli.config.env.production_description"),
          test: I18n.t("cli.config.env.test_description"),
        }
      },
      VERBOSE: {
        type: Aro::Config::TYPES[:BOOL],
        access: Aro::Config::DEF_ACCESS[:WRITE],
        value: Aro::Config::BOOLS[:FALSE],
        description: I18n.t("cli.config.verbose_description"),
      },
      LOG_AOS_DB: {
        type: Aro::Config::TYPES[:BOOL],
        access: Aro::Config::DEF_ACCESS[:WRITE],
        value: Aro::Config::BOOLS[:FALSE],
        description: I18n.t("cli.config.log_aos_db_description"),
      },
      LOG_ARO_DB: {
        type: Aro::Config::TYPES[:BOOL],
        access: Aro::Config::DEF_ACCESS[:WRITE],
        value: Aro::Config::BOOLS[:FALSE],
        description: I18n.t("cli.config.log_aro_db_description"),
      },
      FORMAT: { # not implemented yet.
        type: Aro::Config::TYPES[:VALUES],
        implemented: false,
        access: Aro::Config::DEF_ACCESS[:WRITE],
        value: Aro::Config::FORMATS[:TEXT],
        description: I18n.t("cli.config.format.description"),
        possible_values: {
          text: I18n.t("cli.config.format.text_description"),
          json: I18n.t("cli.config.format.json_description")
        }
      },
      DIMENSION: {
        type: Aro::Config::TYPES[:VALUES],
        access: Aro::Config::DEF_ACCESS[:WRITE],
        value: Aro::Config::DMS[:DEV_TAROT],
        description: I18n.t("cli.config.dimension.description"),
        possible_values: {
          dev_tarot: I18n.t("cli.config.dimension.dev_tarot_description"),
          ruby_facot: I18n.t("cli.config.dimension.ruby_facot_description"),
        }
      },
      HEIGHT: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:WRITE],
        value: Aro::Mancy::NUMERALS[:XLII],
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:MMXCVII],
        description: I18n.t(
          "cli.config.height_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:VII].pow(Aro::Mancy::OS),
        ),
      },
      WIDTH: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:WRITE],
        value: Aro::Mancy::NUMERALS[:C] + Aro::Mancy::NUMERALS[:XXXVII] - Aro::Mancy::S,
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:MMXCVII],
        description: I18n.t(
          "cli.config.width_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:XI].pow(Aro::Mancy::OS),
        ),
      },
      Z: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:WRITE],
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
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:WRITE],
        value: Aro::Mancy::NUMERALS[:VII],
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:XXII],
        description: I18n.t(
          "cli.config.z_max_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:XXII],
        ),
      },

      #
      # => ovars
      #
      ARO_ENV_O: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::O,
        description: I18n.t("cli.config.aro_env.O_description"),
      },
      ARO_ENV_S: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::S,
        description: I18n.t("cli.config.aro_env.S_description"),
      },
      ARO_ENV_OS: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::OS,
        description: I18n.t("cli.config.aro_env.OS_description"),
      },
      ARO_ENV_E: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::E,
        description: I18n.t("cli.config.aro_env.E_description"),
      },
      ARO_ENV_N: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::N,
        description: I18n.t("cli.config.aro_env.N_description"),
      },
      ARO_ENV_PS1: {
        type: Aro::Config::TYPES[:STRING],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::PS1,
        description: I18n.t("cli.config.aro_env.PS1_description"),
      },
      ARO_ENV_NAME_FILE: {
        type: Aro::Config::TYPES[:STRING],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::NAME_FILE,
        description: I18n.t("cli.config.aro_env.NAME_FILE_description"),
      },
      ARO_ENV_I2097I: {
        type: Aro::Config::TYPES[:STRING],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::I2097I,
        description: I18n.t("cli.config.aro_env.I2097I_description"),
      },
      ARO_ENV_YES: {
        type: Aro::Config::TYPES[:STRING],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::YES,
        description: I18n.t("cli.config.aro_env.YES_description"),
      },
      ARO_ENV_ALL: {
        type: Aro::Config::TYPES[:STRING],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::ALL,
        description: I18n.t("cli.config.aro_env.ALL_description"),
      },
    }

    def load
      unless File.exist?(Aro::Config.config_filepath)
        generate_config
      end

      source_config
      setup_env

      self.display_lines = Aro::Config.base_lines
    end

    def self.base_lines
      # print Aro::Config::DEF
      lines = []
      lines << "loaded config at: #{Aos::Os.osify(Aro::Config.config_filepath)}"
      lines << "<Aro::Config::DEF>"
      lines += Aro::Config.dump_config

      # print config commands
      lines << ""
      lines << I18n.t("aos.constants.commands")
      lines += Aos::Vw::Base.lines_for_cmd(Aos::Os::CMDS[:CONFIG])
      lines
    end

    def self.config_filepath
      if Aro::Mancy.in_aro? && Aro::Mancy.is_initialized?
        self.instance.config_path = File.join(Dir.pwd, Aro::Db.base_aro_dir)
      elsif Aro::Dom.in_arodom? && Aro::Dom.is_initialized?
        self.instance.config_path = File.join(Aro::Dom::dom_root, Aro::Dom.room_path(:config))
      end

      File.join(
        self.instance.config_path,
        Aro::Config::CONFIG_FILE.to_s
      )
    end

    def self.is_test?
      ENV[:ARO_ENV.to_s] == Aro::Config::ENVS[:TEST].to_s
    end

    def self.display_configuration
      height, width = IO.console.winsize
      result = {
        HEIGHT: height, #Aro::Config.ivar(:HEIGHT).to_i,
        WIDTH: width - Aro::Mancy::O,
        DIVIDER: :".".to_s
      }
      # Aro::V.say(result)

      result
    end

    def self.is_format_text?
      Aro::Config.ivar(:FORMAT)&.to_sym == Aro::Config::FORMATS[:TEXT]
    end

    def self.process_config_command(args)
      if [args[2],args[3]].compact.any? && args[1] == Aos::Os::CMDS[:CONFIG][:cmds][:SET][:key].to_s
        Aro::Config.set_ivar(args[2], args[3])
      end
    end

    # out vars
    def self.ovar(suffix)
      Aro::Config::DEF[suffix][:value]
    end
    # out vars
    def self.ovar_k(suffix)
      "#{Aro::Config::ARO_ENV_PREFIX}#{suffix}"
    end

    # in vars
    def self.ivar(suffix)
      ENV[Aro::Config.ivar_k(suffix)]
    end
    # in vars
    def self.ivar_k(suffix)
      "#{Aro::Config::ARO_CONFIG_PREFIX}#{suffix}"
    end

    def self.set_ivar(k, new_value)
      k = k.upcase.to_sym

      current_value = Aro::Config.ivar(k)
      # ensure the var name is valid
      unless current_value.nil?
        Aro::Dom::P.say("validating #{k} with value #{new_value}")
        if Aro::Config.instance.valid_var?(new_value, k, Aro::Config::DEF[k])
          # set ENV value
          ENV[Aro::Config.ivar_k(k)] = new_value
          Aro::Dom::P.say("#{k} set to #{new_value}")
          Aro::V.say(ENV[Aro::Config.ivar_k(k)])

          # flush existing config and regen
          Aro::Config.instance.generate_config(true)
          Aro::Config.instance.source_config
          Aro::Config.instance.setup_env
          Aro::Db.configure_logger
          Aos::Db.configure_logger
        else
          Aro::Dom::P.say("the ivar value you entered is invalid. ignoring.")
        end
      else
        Aro::Dom::P.say("the ivar name you entered is invalid. ignoring.")
      end
    end

    def setup_env
      # do not change - update $ARO_CONFIG_ENV .aro/.config file
      # 
      # default is production
      varenv = Aro::Config.ivar(:ENV)
      is_valid = valid_var?(varenv, :ENV, Aro::Config::DEF[:ENV])
      ENV[:ARO_ENV.to_s] = is_valid ? varenv : Aro::Config::ENVS[:PRODUCTION].to_s
      Aro::D.say("setup_env: #{ENV[:ARO_ENV.to_s]}")
    end

    def self.dump_config
      dump = []
      Aro::Config::DEF.each{|k, v|
        if v[:access] == Aro::Config::DEF_ACCESS[:WRITE]
          dump << "$#{Aro::Config.ivar_k(k).ljust(Aro::Mancy::NUMERALS[:XIV] * Aro::Mancy::OS)}=#{Aro::Config.ivar(k)}"
        else
          dump << "$#{Aro::Config.ovar_k(k).ljust(Aro::Mancy::NUMERALS[:XIV] * Aro::Mancy::OS)}=#{Aro::Config.ovar(k)}"
        end
      }

      dump
    end

    def source_config
      Aro::D.say(I18n.t("cli.config.source", name: Aro::Config.config_filepath))
      File.read(Aro::Config.config_filepath).split("\n").select{|line|
        line.match?(/export #{Aro::Config::ARO_CONFIG_PREFIX}/)
      }.map{|line| 
        line.gsub("export ", "").split("=")
      }.each{|kv|
        Aro::V.say("variable to set: #{kv}")
        ENV[kv[0]] = kv[1] # source
        Aro::V.say("value actually set: #{ENV[kv[0]]}")
      }
      
      # todo: implement
      invalid_defs = validate_config
      Aro::Config.dump_config.each{|l| Aro::V.say(l)}
      invalid_defs.each{|k|
        v = Aro::Config::DEF[k.to_sym]
        if v[:access] == Aro::Config::DEF_ACCESS[:WRITE]
          ENV[Aro::Config.ivar_k(k)] = v[:value]
        else
          ENV[Aro::Config.ovar_k(k)] = v[:value]
        end
      }
    end

    def generate_config(from_memory = false)
      # todo: localize generated config text
      Aro::D.say(I18n.t("cli.config.generate", name: Aro::Config.config_filepath))
      File.open(Aro::Config.config_filepath, "w+") do |file|
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
        Aro::Config::DEF.each{|k, v|
          print_var file.object_id, k, v, (from_memory ? ENV[Aro::Config.ivar_k(k)] : nil)
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
      file.write("# Aro::Config::DEF_TYPES\n")
      file.write("# describes the possible types of variables.\n")
      Aro::Config::DEF_TYPES.each{|k, v|
        file.write("# #{k}: #{v[:description]}\n")
      }
      print_osr f_object_id
      file.write("# Aro::Config::DEF\n")
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

    def print_var f_object_id, k, v, mem_v
      file = ObjectSpace._id2ref f_object_id

      is_ovar = Aro::Config::DEF[k][:access] == Aro::Config::DEF_ACCESS[:READ]
      if is_ovar
        var_name = k
      else
        var_name = Aro::Config.ivar_k(k)
      end
      Aro::V.say("access for #{k} is #{Aro::Config::DEF[k][:access]}")
      Aro::V.say("using var_name: #{var_name}")
      file.write("# [#{var_name}] (#{is_ovar ? :ovar : :ivar})\n")
      file.write("#   => Aro::Config::DEF_TYPES: #{v[:type]}\n")
      case v[:type]
      when Aro::Config::DEF_TYPES[:INT][:name]
        file.write("#   => #{I18n.t("cli.config.type.int_description")}\n")
        file.write("#   => #{I18n.t("cli.config.minimum")}: #{v[:min]}\n")
        file.write("#   => #{I18n.t("cli.config.maximum")}: #{v[:max]}\n")
      when Aro::Config::DEF_TYPES[:STRING][:name]
        file.write("#   => #{I18n.t("cli.config.type.string_description")}\n")
        file.write("#   => use \"double quotes\" if there are any spaces.\n")
      when Aro::Config::DEF_TYPES[:VALUES][:name]
        file.write("#   => #{I18n.t("cli.config.type.values_description")}\n")
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
      if is_ovar && Aro::Config::DEF_TYPES[:STRING][:name] == v[:type]
        file.write("export #{var_name}=\"#{v[:value]}\"\n")
      else
        file.write("export #{var_name}=#{mem_v || v[:value]}\n")
      end
      print_osr f_object_id
    end

  end
end
