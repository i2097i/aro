=begin
  
  cor.rb

  cor interface.

  by i2097i

=end

require_relative :"./mancy".to_s

module Aro
  # cli entrypoint
  def self.cor
    if CLI::FLAGS[:HELP].include?(CLI::ARGV1)
      CLI.usage_cor
      exit(CLI::EXIT_CODES[:SUCCESS])
    end

    Aro::Cor.instance.load_env!
    Aro::Cor.process_command(ARGV)
  end

  class Cor
    include Singleton

    attr_accessor :base_lines_def, :display_lines, :use_less

    def self.process_command(args)
      k = Aro::Cor::DEF.keys.filter{|k| k == args[Aro::Mancy::S]&.upcase&.to_sym}&.first
      unless k.nil?
        unless args[Aro::Mancy::OS].nil?
          # config var_name var_value
          Aro::Cor.set_ivar(args[Aro::Mancy::S], args[Aro::Mancy::OS])
        end

        # basic show var description and value
        self.instance.display_lines = self.instance.lines_var(k, Aro::Cor::DEF[k], ENV[Aro::Cor.ivar_k(k)])
      else
        self.instance.display_lines = Aro::Cor.base_lines(args)
      end

      if Aro::Mancy.in_aro?
        if self.instance.use_less
          Aro::P.less(self.instance.display_lines.join("\n"))
        else
          Aro::P.say(self.instance.display_lines)
        end
      end

      self.instance.use_less = false
    end

    ARO_IVA_PREFIX = :ARO_IVA_
    ARO_OVA_PREFIX = :ARO_OVA_

    COR_FILE = :".cor"

    DATE_FORMAT = "%Y:%m:%d:%H:%M:%S"

    DBG_MODES = [:development, :test]

    # possible envs
    #
    # example usage:
    # Aro::Cor::ENVS[:PRODUCTION]
    ENVS = {
      DEVELOPMENT: :development,
      PRODUCTION: :production,
      TEST: :test
    }

    # possible interfaces
    #
    # example usage:
    # Aro::Cor::INTERFACES[:TERMINAL]
    INTERFACES = {
      TERMINAL: :terminal,
      LANIMRET: :lanimret,
    }

    # possible dimensions
    #
    # example usage:
    # Aro::Cor::DMS[:DEV_TAROT]
    DMS = {
      DEV_TAROT: :dev_tarot,
      RUBY_FACOT: :ruby_facot
    }

    # ovar and ivar access
    #
    # example usage:
    # Aro::Cor::DEF_ACCESS[:READ]
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
    # Aro::Cor::DEF_TYPES[:INT][:validator].call(unvalid, Aro::Cor::DEF[:DIMENSION])
    DEF_TYPES = {
      BOOL: {
        name: Aro::Cor::TYPES[:BOOL],
        description: I18n.t("cor.type.bool_description"),
        converter: Proc.new{|v| v.kind_of?(TrueClass) ? true : false},
        validator: Proc.new{|unvalid, k, v|
          Aro::Cor.def_valid?(k, v) &&
          Aro::Cor.bool_valid?(unvalid)
        }
      },
      INT: {
        name: Aro::Cor::TYPES[:INT],
        description: I18n.t("cor.type.int_description"),
        converter: Proc.new{|v| v.to_i},
        validator: Proc.new{|unvalid, k, v|
          Aro::V.say("validating #{k} (#{Aro::Cor::DEF_TYPES[:INT][:name]})")
          Aro::V.say("unvalid = #{unvalid}")
          Aro::V.say("[min, max] => [#{v[:min]}, #{v[:max]}]")
          int_valid = Aro::Cor.def_valid?(k, v) &&
            Aro::Cor.int_valid?(unvalid)        &&
            unvalid.to_i >= v[:min]             &&
            unvalid.to_i <= v[:max]
          Aro::V.say("unvalid(#{unvalid}) is#{int_valid ? " " : :" not ".to_s}valid.")
          int_valid
        }
      },
      STRING: {
        name: Aro::Cor::TYPES[:STRING],
        description: I18n.t("cor.type.string_description"),
        converter: Proc.new{|v| v.to_s},
        validator: Proc.new{|unvalid, k, v|
          Aro::Cor.def_valid?(k, v) &&
          Aro::Cor.string_valid?(unvalid)
        }
      },
      VALUES: {
        name: Aro::Cor::TYPES[:VALUES],
        description: I18n.t("cor.type.values_description"),
        converter: Proc.new{|v| v.to_s},
        validator: Proc.new{|unvalid, k, v|
          Aro::Cor.def_valid?(k, v) &&
          v[:possible_values].keys.include?(unvalid&.to_sym)
        }
      },
    }

    def self.bool_valid?(unvalid)
      Aro::Cor::BOOLS.values.map{|b| b.to_s.to_sym}.include?(unvalid&.to_s&.to_sym)
    end

    def self.int_valid?(unvalid)
      !unvalid&.to_i.nil?
    end

    def self.string_valid?(unvalid)
      unvalid.is_a?(String)
    end

    def self.def_valid?(key, deff)
      def_valid = deff == Aro::Cor::DEF[key]
      unless def_valid
        Aro::P.say("invalid def! #{key} => #{deff}")
      end

      def_valid
    end

    def validate_config
      invalid_vars = []
      Aro::Cor::DEF.each{|k, v|
        is_valid = v[:access] == Aro::Cor::DEF_ACCESS[:READ]
        unless is_valid
          is_valid = valid_var?(Aro::Cor.ivar(k), k, v)
        end
        invalid_vars << k unless is_valid
      }
      invalid_vars
    end

    def valid_var?(var_value, k, v)
      Aro::V.say(v)
      return true if v[:access] == Aro::Cor::DEF_ACCESS[:READ]

      Aro::Cor::DEF_TYPES[
        v[:type].to_s.upcase.to_sym
      ][:validator].call(var_value, k, v)
    end

    def convert_var_for_def(k)
      Aro::Cor::DEF_TYPES[
        Aro::Cor::DEF[k][:type].upcase
      ][:converter].call(ENV[Aro::Cor.ivar_k(k)])
    end

    # adapts I18n translations to generate bash environment vars.
    #
    # example usage:
    # Aro::Cor::DEF[:Z_MAX]
    DEF = {
      #
      # => ivars
      #
      ENV: {
        type: Aro::Cor::TYPES[:VALUES],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: Aro::Cor::ENVS[:PRODUCTION],
        description: I18n.t("cor.env.description"),
        possible_values: {
          development: I18n.t("cor.env.development_description"),
          production: I18n.t("cor.env.production_description"),
          test: I18n.t("cor.env.test_description"),
        }
      },
      VERBOSE: {
        type: Aro::Cor::TYPES[:BOOL],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: Aro::Cor::BOOLS[:FALSE],
        description: I18n.t("cor.verbose_description"),
      },
      LOG_DATABASE: {
        type: Aro::Cor::TYPES[:BOOL],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: Aro::Cor::BOOLS[:FALSE],
        description: I18n.t("cor.log_aro_db_description"),
      },
      OSS_OM_HOME: {
        type: Aro::Cor::TYPES[:STRING],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: nil,
        description: I18n.t("cor.oss_om_home.description"),
        possible_values: {
          path: I18n.t("cor.oss_om_home.path_description"),
        }
      },
      OSS_OM_PKEY_PATH: {
        type: Aro::Cor::TYPES[:STRING],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: nil,
        description: I18n.t("cor.oss_om_pkey_path.description"),
        possible_values: {
          path: I18n.t("cor.oss_om_pkey_path.path_description"),
        }
      },
      INTERFACE: {
        type: Aro::Cor::TYPES[:VALUES],
        implemented: false,
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: Aro::Cor::INTERFACES[:TERMINAL],
        description: I18n.t("cor.interface.description"),
        possible_values: {
          terminal: I18n.t("cor.interface.terminal_description"),
          lanimret: I18n.t("cor.interface.lanimret_description")
        }
      },
      DIMENSION: {
        type: Aro::Cor::TYPES[:VALUES],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: Aro::Cor::DMS[:DEV_TAROT],
        description: I18n.t("cor.dimension.description"),
        possible_values: {
          dev_tarot: I18n.t("cor.dimension.dev_tarot_description"),
          ruby_facot: I18n.t("cor.dimension.ruby_facot_description"),
        }
      },
      HEIGHT: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: Aro::Mancy::NUMERALS[:XLII],
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:MMXCVII],
        description: I18n.t(
          "cor.height_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:MMXCVII],
        ),
      },
      WIDTH: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: Aro::Mancy::NUMERALS[:C] + Aro::Mancy::NUMERALS[:XXXVII] - Aro::Mancy::S,
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:MMXCVII],
        description: I18n.t(
          "cor.width_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:MMXCVII],
        ),
      },
      Z: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: Aro::Mancy::NUMERALS[:I],
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:MMXCVII],
        description: I18n.t(
          "cor.z_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:MMXCVII],
        ),
      },
      Z_MAX: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: Aro::Mancy::NUMERALS[:VII],
        min: Aro::Mancy::NUMERALS[:I],
        max: Aro::Mancy::NUMERALS[:XXII],
        description: I18n.t(
          "cor.z_max_description",
          min: Aro::Mancy::NUMERALS[:I],
          max: Aro::Mancy::NUMERALS[:XXII],
        ),
      },

      #
      # => ovars
      #
      O: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::O,
        description: I18n.t("cor.aro_env.O_description"),
      },
      S: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::S,
        description: I18n.t("cor.aro_env.S_description"),
      },
      OS: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::OS,
        description: I18n.t("cor.aro_env.OS_description"),
      },
      E: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::E,
        description: I18n.t("cor.aro_env.E_description"),
      },
      N: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::N,
        description: I18n.t("cor.aro_env.N_description"),
      },
      NAME_FILE: {
        type: Aro::Cor::TYPES[:STRING],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::NAME_FILE,
        description: I18n.t("cor.aro_env.NAME_FILE_description"),
      },
      I2097I: {
        type: Aro::Cor::TYPES[:STRING],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::I2097I,
        description: I18n.t("cor.aro_env.I2097I_description"),
      },
      YES: {
        type: Aro::Cor::TYPES[:STRING],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::YES,
        description: I18n.t("cor.aro_env.YES_description"),
      },
      ALL: {
        type: Aro::Cor::TYPES[:STRING],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::ALL,
        description: I18n.t("cor.aro_env.ALL_description"),
      },
    }

    def load_env
      self.base_lines_def = nil
      return unless File.exist?(Aro::Cor.cor_filepath)

      source_config
      Aro::P.say("running in #{Aro::Cor.ivar(:ENV)} env.")

      self.display_lines = Aro::Cor.base_lines
    end

    def load_env!
      unless File.exist?(Aro::Cor.cor_filepath)
        generate_config
      end

      load_env
    end

    def self.base_lines(args = nil)
      if self.instance.base_lines_def.nil? || args.present?
        args = [] if args.nil?
        # print Aro::Cor::DEF
        lines = []
        lines << "loaded config at: #{Aro::Cor.cor_filepath}"
        lines << "<Aro::Cor::DEF>"
        self.instance.use_less = false
        case args[Aro::Mancy::S]&.to_sym
        when :ivars
          lines += Aro::Cor.ivars_dump
        when :ovars
          lines += Aro::Cor.ovars_dump
        else
          # print cor commands
          self.instance.use_less = true
          lines << ""
          lines << I18n.t("constants.commands")
          lines << ""
          lines += Aro::Cmd.display_lines
        end

        self.instance.base_lines_def = lines
      end

      return self.instance.base_lines_def
    end

    def self.cor_filepath
      File.join(
        Aro::Mancy.root_dir,
        Aro::Cor::COR_FILE.to_s
      )
    end

    def self.is_test?
      Aro::Cor.ivar(:ENV) == Aro::Cor::ENVS[:TEST].to_s
    end

    def self.discon
      height = Aro::Cor.ivar(:HEIGHT).to_i
      width = Aro::Cor.ivar(:WIDTH).to_i

      result = {
        HEIGHT: height,
        WIDTH: width,
        DIVIDER: :".".to_s
      }

      result
    end

    # out vars
    def self.ovar(suffix)
      Aro::Cor::DEF[suffix][:value]
    end
    # out vars
    def self.ovar_k(suffix)
      "#{Aro::Cor::ARO_OVA_PREFIX}#{suffix}"
    end

    # in vars
    def self.ivar(suffix)
      ENV[Aro::Cor.ivar_k(suffix)]
    end
    # in vars
    def self.ivar_k(suffix)
      "#{Aro::Cor::ARO_IVA_PREFIX}#{suffix}"
    end

    def cor_set_ruby_env!(k, v)
      k = k.strip.to_sym unless k.kind_of?(Symbol)
      raise "attempt to set invalid def: #{k}=#{v}" if Aro::Cor::DEF[k].nil?
      converted = v
      converted = v.to_s if v.kind_of?(Symbol) ||
        Aro::Cor::DEF[k][:type] == Aro::Cor::TYPES[:BOOL] ||
        Aro::Cor::DEF[k][:type] == Aro::Cor::TYPES[:INT]
      # set ruby ENV key value
      # only write to ruby ENV from here
      ENV[Aro::Cor.ivar_k(k.to_s)] = converted
      Aro::D.say("#{k} set to #{converted}") unless converted.nil? || converted.empty?
      return true
    end

    def self.set_ivar(k, new_value)
      k = k.upcase.to_sym

      current_value = Aro::Cor.ivar(k)
      if k == :DIMENSION &&
        new_value == Aro::Cor::DMS[:DEV_TAROT].to_s &&
        !Aro::T.is_dev_tarot_avail?
        Aro::P.say("unable to set dimension dev_tarot. device not present.")
        return
      elsif k == :OSS_OM_HOME
        unless Dir.exist?(new_value)
          Aro::P.say("cannot set #{k} to #{new_value}. the directory does not exist.")
        end

        if Aro::Cor.instance.valid_var?(new_value, k, Aro::Cor::DEF[k])
          Aro::Cor.instance.cor_set_ruby_env!(k, new_value)
          # flush existing config and regen
          Aro::Cor.instance.generate_config(true)
          Aro::Cor.instance.source_config
          Aro::Db.configure_logger
          return
        end
      end

      # ensure the var name is valid
      unless current_value.nil?
        Aro::P.say("validating #{k} with value #{new_value}")
        if Aro::Cor.instance.valid_var?(new_value, k, Aro::Cor::DEF[k])
          Aro::Cor.instance.cor_set_ruby_env!(k, new_value)
          # flush existing config and regen
          Aro::Cor.instance.generate_config(true)
          Aro::Cor.instance.source_config
          Aro::Db.configure_logger
        else
          Aro::P.say("the ivar value you entered is invalid. ignoring.")
        end
      else
        Aro::P.say("the ivar name you entered is invalid. ignoring.")
      end
    end

    # todo: add_to_docs
    def self.ivars_dump
      dump = []
      Aro::Cor::DEF.select{|k, v|
        v[:access] == Aro::Cor::DEF_ACCESS[:WRITE]
      }.each{|k, v|
          dump << "#{Aro::Cor.ivar_k(k).ljust(Aro::Mancy::NUMERALS[:XIV] * Aro::Mancy::OS)}=#{Aro::Cor.ivar(k)}"
      }

      dump
    end

    # todo: add_to_docs
    def self.ovars_dump
      dump = []
      Aro::Cor::DEF.select{|k, v|
        v[:access] == Aro::Cor::DEF_ACCESS[:READ]
      }.each{|k, v|
        dump << "#{Aro::Cor.ovar_k(k).ljust(Aro::Mancy::NUMERALS[:XIV] * Aro::Mancy::OS)}=#{Aro::Cor.ovar(k)}"
      }

      dump
    end

    def source_config
      Aro::D.say(I18n.t("cor.source", name: Aro::Cor.cor_filepath))
      File.read(Aro::Cor.cor_filepath).split("\n").select{|line|
        line.match?(/export #{Aro::Cor::ARO_IVA_PREFIX}/)
      }.map{|line|
        line.gsub("export ", "").split("=")
      }.each{|kv|
        Aro::D.say("variable_to_set: #{kv}")
        result = Aro::Cor.instance.cor_set_ruby_env!(kv[0].gsub(Aro::Cor::ARO_IVA_PREFIX.to_s, ""), kv[1])
        Aro::D.say("value_was_set: #{result}")
      }

      invalid_defs = validate_config
      Aro::Cor.ivars_dump.each{|l| Aro::V.say(l)}
      Aro::Cor.ovars_dump.each{|l| Aro::V.say(l)}
      invalid_defs.each{|k|
        v = Aro::Cor::DEF[k.to_sym]
        if v[:access] == Aro::Cor::DEF_ACCESS[:WRITE]
          result = Aro::Cor.instance.cor_set_ruby_env!(k, v[:value])
          Aro::D.say("invalid_def_defaulting_#{k}: #{result}")
        else
          result = Aro::Cor.instance.cor_set_ruby_env!(k, v[:value])
          Aro::D.say("invalid_def_defaulting_#{k}: #{result}")
        end
      }
    end

    # from_memory true means write current config to file
    def generate_config(from_memory = false)
      # todo: localize generated config text
      Aro::D.say(I18n.t("cor.generate", name: Aro::Cor.cor_filepath))

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
      Aro::Cor::DEF.each{|k, v|
        lines += lines_var(k, v, (from_memory ? ENV[Aro::Cor.ivar_k(k)] : nil))
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
      File.open(Aro::Cor.cor_filepath, "w+") do |file|
        file.write(lines.join("\n"))
        file.write("\n")
      end
    end

    def lines_div
      ["".ljust(Aro::Mancy::NUMERALS[:XLII] * Aro::Mancy::OS, "#")]
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
        "# #{Aro::Mancy} cor configuration file generated by #{Aro::Cor.name}."
      ]
    end

    def lines_var_section_div
      ["# Aro::Cor::DEF"]
    end

    def lines_def_type_description
      lines = []
      lines << "# Aro::Cor::DEF_TYPES"
      lines << "# describes the possible types of variables."
      Aro::Cor::DEF_TYPES.each{|k, v|
        lines << "# #{k}: #{v[:description]}"
      }
      lines += lines_newline_comment_os
      lines << "# Aro::Cor::DEF"
      lines << "# define and expose an aro cor bash api via ENV variables."
      lines << "# there are two types of cor vars in aro."
      lines << "# 1) in vars (ivars). "
      lines << "#     => write variables from this file."
      lines << "#     => they are validated and used unless unvalid."
      lines << "# 2) out vars (ovars)."
      lines << "#     => read-only variables that aro cor exposes to bash."
    end

    def lines_var(k, v, mem_v = nil)
      lines = ["\n"]
      is_ovar = Aro::Cor::DEF[k][:access] == Aro::Cor::DEF_ACCESS[:READ]
      if is_ovar
        var_name = Aro::Cor.ovar_k(k)
      else
        var_name = Aro::Cor.ivar_k(k)
      end
      Aro::V.say("access for #{k} is #{Aro::Cor::DEF[k][:access]}")
      Aro::V.say("using var_name: #{var_name}")
      lines << "# [#{var_name}] (#{is_ovar ? :ovar : :ivar})"
      lines << "#   => Aro::Cor::DEF_TYPES: #{v[:type]}"
      case v[:type]
      when Aro::Cor::DEF_TYPES[:BOOL][:name]
        lines << "#   => #{I18n.t("cor.type.bool_description")}"
      when Aro::Cor::DEF_TYPES[:INT][:name]
        lines << "#   => #{I18n.t("cor.type.int_description")}"
        lines << "#   => #{I18n.t("cor.minimum")}: #{v[:min]}"
        lines << "#   => #{I18n.t("cor.maximum")}: #{v[:max]}"
      when Aro::Cor::DEF_TYPES[:STRING][:name]
        lines << "#   => #{I18n.t("cor.type.string_description")}"
        lines << "#   => use \"double quotes\" if there are any spaces."
      when Aro::Cor::DEF_TYPES[:VALUES][:name]
        lines << "#   => #{I18n.t("cor.type.values_description")}"
        lines << "#   => #{I18n.t("cor.possible_values")}:"
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
      if is_ovar && Aro::Cor::DEF_TYPES[:STRING][:name] == v[:type]
        lines << "export #{var_name}=\"#{v[:value]}\""
      else
        lines << "export #{var_name}=#{mem_v || v[:value]}"
      end
      lines += lines_newline_comment_os
      lines
    end

  end
end
