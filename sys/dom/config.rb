=begin
  
  config.rb

  dom config interface.

  by i2097i

=end

module Aro

  # cli entrypoint
  def self.config
    Aro::Config.instance.load
    Aro::Config.process_config_command(ARGV)
  end

  class Config
    include Singleton

    attr_accessor :config_path, :display_lines

    ARO_IVA_PREFIX = :ARO_IVA_
    ARO_OVA_PREFIX = :ARO_OVA_

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

    # possible interfaces
    #
    # example usage:
    # Aro::Config::INTERFACES[:TERMINAL]
    INTERFACES = {
      TERMINAL: :terminal,
      LANIMRET: :lanimret,
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
        name: Aro::Config::TYPES[:INT],
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
        name: Aro::Config::TYPES[:STRING],
        description: I18n.t("cli.config.type.string_description"),
        converter: Proc.new{|v| v.to_s},
        validator: Proc.new{|unvalid, k, v|
          Aro::Config.def_valid?(k, v) &&
          Aro::Config.string_valid?(unvalid)
        }
      },
      VALUES: {
        name: Aro::Config::TYPES[:VALUES],
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
      FORMAT: {
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
      INTERFACE: {
        type: Aro::Config::TYPES[:VALUES],
        implemented: false,
        access: Aro::Config::DEF_ACCESS[:WRITE],
        value: Aro::Config::INTERFACES[:TERMINAL],
        description: I18n.t("cli.config.interface.description"),
        possible_values: {
          terminal: I18n.t("cli.config.interface.terminal_description"),
          lanimret: I18n.t("cli.config.interface.lanimret_description")
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
      O: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::O,
        description: I18n.t("cli.config.aro_env.O_description"),
      },
      S: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::S,
        description: I18n.t("cli.config.aro_env.S_description"),
      },
      OS: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::OS,
        description: I18n.t("cli.config.aro_env.OS_description"),
      },
      E: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::E,
        description: I18n.t("cli.config.aro_env.E_description"),
      },
      N: {
        type: Aro::Config::TYPES[:INT],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::N,
        description: I18n.t("cli.config.aro_env.N_description"),
      },
      PS1: {
        type: Aro::Config::TYPES[:STRING],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::PS1,
        description: I18n.t("cli.config.aro_env.PS1_description"),
      },
      NAME_FILE: {
        type: Aro::Config::TYPES[:STRING],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::NAME_FILE,
        description: I18n.t("cli.config.aro_env.NAME_FILE_description"),
      },
      I2097I: {
        type: Aro::Config::TYPES[:STRING],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::I2097I,
        description: I18n.t("cli.config.aro_env.I2097I_description"),
      },
      YES: {
        type: Aro::Config::TYPES[:STRING],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::YES,
        description: I18n.t("cli.config.aro_env.YES_description"),
      },
      ALL: {
        type: Aro::Config::TYPES[:STRING],
        access: Aro::Config::DEF_ACCESS[:READ],
        value: Aro::Mancy::ALL,
        description: I18n.t("cli.config.aro_env.ALL_description"),
      },
    }

    def load
      self.config_path = ""
      if Aro::Mancy.in_aro? && Aro::Mancy.is_initialized?
        self.config_path = Aro::Config.aro_config_path
      elsif Aro::Dom.in_arodom?
        self.config_path = Aro::Config.dom_config_path
      end

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
      lines << ""
      lines += Aos::Vw::Base.lines_for_cmd(Aos::Os::CMDS[:CONFIG])
      lines
    end

    def self.aro_config_path
      File.join(Dir.pwd, Aro::Db.base_aro_dir)
    end

    def self.dom_config_path
      File.join(Aro::Dom::dom_root, Aro::Dom.room_path(:config))
    end

    def self.config_filepath
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
      k = Aro::Config::DEF.keys.filter{|k| k == args[Aro::Mancy::S]&.upcase&.to_sym}&.first
      unless k.nil?
        unless args[Aro::Mancy::OS].nil?
          # config <var_name> <var_value>
          Aro::Config.set_ivar(args[Aro::Mancy::S], args[Aro::Mancy::OS])
        end

        # basic show var description and value
        self.instance.display_lines = self.instance.lines_var(k, Aro::Config::DEF[k], ENV[Aro::Config.ivar_k(k)])
      else
        self.instance.display_lines = Aro::Config.base_lines
      end

      if Aro::Mancy.in_aro? && !Aro::Dom.in_arodom?
        Aro::P.say(self.instance.display_lines.join("\n"))
      end
    end

    # out vars
    def self.ovar(suffix)
      Aro::Config::DEF[suffix][:value]
    end
    # out vars
    def self.ovar_k(suffix)
      "#{Aro::Config::ARO_OVA_PREFIX}#{suffix}"
    end

    # in vars
    def self.ivar(suffix)
      ENV[Aro::Config.ivar_k(suffix)]
    end
    # in vars
    def self.ivar_k(suffix)
      "#{Aro::Config::ARO_IVA_PREFIX}#{suffix}"
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
      Aro::D.say("running in #{ENV[:ARO_ENV.to_s]} env.")
    end

    def self.dump_config
      dump = []
      Aro::Config::DEF.each{|k, v|
        if v[:access] == Aro::Config::DEF_ACCESS[:WRITE]
          dump << "#{Aro::Config.ivar_k(k).ljust(Aro::Mancy::NUMERALS[:XIV] * Aro::Mancy::OS)}=#{Aro::Config.ivar(k)}"
        else
          dump << "#{Aro::Config.ovar_k(k).ljust(Aro::Mancy::NUMERALS[:XIV] * Aro::Mancy::OS)}=#{Aro::Config.ovar(k)}"
        end
      }

      dump
    end

    def source_config
      Aro::D.say(I18n.t("cli.config.source", name: Aro::Config.config_filepath))
      File.read(Aro::Config.config_filepath).split("\n").select{|line|
        line.match?(/export #{Aro::Config::ARO_IVA_PREFIX}/)
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

    # from_memory true means write current config to file
    def generate_config(from_memory = false)
      # todo: localize generated config text
      Aro::D.say(I18n.t("cli.config.generate", name: Aro::Config.config_filepath))

      lines = []

      # intro
      Aro::Mancy::OS.times do
        lines += lines_div
      end

      # header
      lines += lines_div
      lines += lines_newline_comment
      lines += lines_config_header
      lines += lines_newline_comment
      lines += lines_div

      lines += lines_newline_comment_os

      # def_types
      lines += lines_div
      lines += lines_newline_comment
      lines += lines_def_type_description
      lines += lines_newline_comment
      lines += lines_div

      lines += lines_newline_comment_os

      # var section
      lines += lines_div
      lines += lines_newline_comment
      lines += lines_var_section_div
      lines += lines_newline_comment
      lines += lines_div

      lines += lines_newline_comment_os

      # vars
      Aro::Config::DEF.each{|k, v|
        lines += lines_var(k, v, (from_memory ? ENV[Aro::Config.ivar_k(k)] : nil))
      }

      lines += lines_newline_comment_os

      # var section
      lines += lines_div
      lines += lines_newline_comment
      lines += lines_var_section_div
      lines += lines_newline_comment
      lines += lines_div

      lines += lines_newline_comment_os
      # outro
      Aro::Mancy::OS.times do
        lines += lines_div
      end
      write_config(lines)
    end

    def write_config(lines)
      File.open(Aro::Config.config_filepath, "w+") do |file|
        file.write(lines.join("\n"))
        file.write("\n")
      end
    end

    def lines_div
      ["#" * Aro::Mancy::NUMERALS[:VIII].pow(Aro::Mancy::OS)]
    end

    def lines_newline_comment
      ["#"]
    end

    def lines_newline_comment_os
      lines = []
      Aro::Mancy::OS.times do
        lines += lines_newline_comment
      end
      lines
    end

    def lines_config_header
      [
        "# #{Aro::Mancy::PS1} configuration file.",
        "# this file was auto generated by the aro cli."
      ]
    end

    def lines_var_section_div
      ["# VARIABLE SECTION!"]
    end

    def lines_def_type_description
      lines = []
      lines << "# Aro::Config::DEF_TYPES"
      lines << "# describes the possible types of variables."
      Aro::Config::DEF_TYPES.each{|k, v|
        lines << "# #{k}: #{v[:description]}"
      }
      lines += lines_newline_comment_os
      lines << "# Aro::Config::DEF"
      lines << "# define & expose an aro bash api via ENV variables."
      lines << "# there are two types of bash vars in aro."
      lines << "# 1) in vars (ivars). "
      lines << "#     => ivars enter aro from this file during aro init."
      lines << "#     => aro validates them and uses them unless unvalid."
      lines << "#     => otherwise aro will use the defaults listed below."
      lines << "# 2) out vars (ovars)."
      lines << "#     => ovars are read-only vars that aro exposes to bash."
      lines << "#     => this is useful because it provides a bash interface"
      lines << "#     => which can be used to write programs on top of aro."
    end

    def lines_var(k, v, mem_v = nil)
      lines = []
      is_ovar = Aro::Config::DEF[k][:access] == Aro::Config::DEF_ACCESS[:READ]
      if is_ovar
        var_name = Aro::Config.ovar_k(k)
      else
        var_name = Aro::Config.ivar_k(k)
      end
      Aro::V.say("access for #{k} is #{Aro::Config::DEF[k][:access]}")
      Aro::V.say("using var_name: #{var_name}")
      lines << "# [#{var_name}] (#{is_ovar ? :ovar : :ivar})"
      lines << "#   => Aro::Config::DEF_TYPES: #{v[:type]}"
      case v[:type]
      when Aro::Config::DEF_TYPES[:BOOL][:name]
        lines << "#   => #{I18n.t("cli.config.type.bool_description")}"
      when Aro::Config::DEF_TYPES[:INT][:name]
        lines << "#   => #{I18n.t("cli.config.type.int_description")}"
        lines << "#   => #{I18n.t("cli.config.minimum")}: #{v[:min]}"
        lines << "#   => #{I18n.t("cli.config.maximum")}: #{v[:max]}"
      when Aro::Config::DEF_TYPES[:STRING][:name]
        lines << "#   => #{I18n.t("cli.config.type.string_description")}"
        lines << "#   => use \"double quotes\" if there are any spaces."
      when Aro::Config::DEF_TYPES[:VALUES][:name]
        lines << "#   => #{I18n.t("cli.config.type.values_description")}"
        lines << "#   => #{I18n.t("cli.config.possible_values")}:"
        lines += lines_newline_comment
        v[:possible_values].each{|name, description|
          lines << "#     => #{name}"
          lines += lines_newline_comment
          lines << "#           =>#{description}"
          lines += lines_newline_comment
        }
      end
      lines += lines_newline_comment_os
      lines << "#   => description:"
      lines << "#   => #{v[:description]}"
      if is_ovar && Aro::Config::DEF_TYPES[:STRING][:name] == v[:type]
        lines << "export #{var_name}=\"#{v[:value]}\""
      else
        lines << "export #{var_name}=#{mem_v || v[:value]}"
      end
      lines += lines_newline_comment_os
    end

  end
end
