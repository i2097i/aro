=begin
  
  cor.rb

  aos cor interface.

  by i2097i

=end

module Aos
  # cli entrypoint
  def self.cor
    Aos::Cor.instance.load
    Aos::Cor.process_command(ARGV)
  end

  class Cor
    include Singleton

    attr_accessor :base_lines_def, :cor_path, :display_lines

    ARO_IVA_PREFIX = :ARO_IVA_
    ARO_OVA_PREFIX = :ARO_OVA_

    COR_FILE = :".cor"

    DATE_FORMAT = "%Y:%m:%d:%H:%M:%S"

    DBG_MODES = [:development, :test]

    # possible envs
    #
    # example usage:
    # Aos::Cor::ENVS[:PRODUCTION]
    ENVS = {
      DEVELOPMENT: :development,
      PRODUCTION: :production,
      TEST: :test
    }

    # possible formats
    #
    # example usage:
    # Aos::Cor::FORMATS[:TEXT]
    FORMATS = {
      TEXT: :text,
      JSON: :json,
    }

    # possible interfaces
    #
    # example usage:
    # Aos::Cor::INTERFACES[:TERMINAL]
    INTERFACES = {
      TERMINAL: :terminal,
      LANIMRET: :lanimret,
    }

    # possible dimensions
    #
    # example usage:
    # Aos::Cor::DMS[:DEV_TAROT]
    DMS = {
      DEV_TAROT: :dev_tarot,
      RUBY_FACOT: :ruby_facot
    }

    # ovar and ivar access
    #
    # example usage:
    # Aos::Cor::DEF_ACCESS[:READ]
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
    # Aos::Cor::DEF_TYPES[:INT][:validator].call(unvalid, Aos::Cor::DEF[:DIMENSION])
    DEF_TYPES = {
      BOOL: {
        name: Aos::Cor::TYPES[:BOOL],
        description: I18n.t("cor.type.bool_description"),
        converter: Proc.new{|v|
          if [Aos::Cor::BOOLS[:TRUE].to_s, Aro::Mancy::S].include?(v)
            Aos::Cor::BOOLS[:TRUE]
          else
            Aos::Cor::BOOLS[:FALSE]
          end
        },
        validator: Proc.new{|unvalid, k, v|
          Aos::Cor.def_valid?(k, v) &&
          Aos::Cor.bool_valid?(unvalid)
        }
      },
      INT: {
        name: Aos::Cor::TYPES[:INT],
        description: I18n.t("cor.type.int_description"),
        converter: Proc.new{|v| v.to_i},
        validator: Proc.new{|unvalid, k, v|
          Aro::V.say("validating #{k} (#{Aos::Cor::DEF_TYPES[:INT][:name]})")
          Aro::V.say("unvalid = #{unvalid}")
          Aro::V.say("[min, max] = [#{v[:min]}, #{v[:max]}]")
          int_valid = Aos::Cor.def_valid?(k, v) &&
            Aos::Cor.int_valid?(unvalid)        &&
            unvalid.to_i >= v[:min]                &&
            unvalid.to_i <= v[:max]
          Aro::V.say("unvalid(#{unvalid}) is#{int_valid ? " " : :" not ".to_s}valid.")
          int_valid
        }
      },
      STRING: {
        name: Aos::Cor::TYPES[:STRING],
        description: I18n.t("cor.type.string_description"),
        converter: Proc.new{|v| v.to_s},
        validator: Proc.new{|unvalid, k, v|
          Aos::Cor.def_valid?(k, v) &&
          Aos::Cor.string_valid?(unvalid)
        }
      },
      VALUES: {
        name: Aos::Cor::TYPES[:VALUES],
        description: I18n.t("cor.type.values_description"),
        converter: Proc.new{|v| v.to_s},
        validator: Proc.new{|unvalid, k, v|
          Aos::Cor.def_valid?(k, v) &&
          v[:possible_values].keys.include?(unvalid&.to_sym)
        }
      },
    }

    def self.bool_valid?(unvalid)
      Aos::Cor::BOOLS.values.map{|b| b.to_s.to_sym}.include?(unvalid&.to_s&.to_sym)
    end

    def self.int_valid?(unvalid)
      !unvalid&.to_i.nil?
    end

    def self.string_valid?(unvalid)
      unvalid.is_a?(String)
    end

    def self.def_valid?(key, deff)
      def_valid = deff == Aos::Cor::DEF[key]
      unless def_valid
        Aro::V.say("invalid def! #{key} => #{deff}")
      end

      def_valid
    end

    def validate_config
      invalid_vars = []
      Aos::Cor::DEF.each{|k, v|
        is_valid = v[:access] == Aos::Cor::DEF_ACCESS[:READ]
        unless is_valid
          is_valid = valid_var?(Aos::Cor.ivar(k), k, v)
        end
        invalid_vars << k unless is_valid
      }
      invalid_vars
    end

    def valid_var?(var_value, k, v)
      Aro::V.say(v)
      return true if v[:access] == Aos::Cor::DEF_ACCESS[:READ]

      Aos::Cor::DEF_TYPES[
        v[:type].to_s.upcase.to_sym
      ][:validator].call(var_value, k, v)
    end

    def convert_var_for_def(k)
      Aos::Cor::DEF_TYPES[
        Aos::Cor::DEF[k][:type].upcase
      ][:converter].call(ENV[Aos::Cor.ivar_k(k)])
    end

    # adapts I18n translations to generate bash environment vars.
    #
    # example usage:
    # Aos::Cor::DEF[:Z_MAX]
    DEF = {

      #
      # => ivars
      #
      ENV: {
        type: Aos::Cor::TYPES[:VALUES],
        access: Aos::Cor::DEF_ACCESS[:WRITE],
        value: Aos::Cor::ENVS[:PRODUCTION],
        description: I18n.t("cor.env.description"),
        possible_values: {
          development: I18n.t("cor.env.development_description"),
          production: I18n.t("cor.env.production_description"),
          test: I18n.t("cor.env.test_description"),
        }
      },
      VERBOSE: {
        type: Aos::Cor::TYPES[:BOOL],
        access: Aos::Cor::DEF_ACCESS[:WRITE],
        value: Aos::Cor::BOOLS[:FALSE],
        description: I18n.t("cor.verbose_description"),
      },
      LOG_AOS_DB: {
        type: Aos::Cor::TYPES[:BOOL],
        access: Aos::Cor::DEF_ACCESS[:WRITE],
        value: Aos::Cor::BOOLS[:FALSE],
        description: I18n.t("cor.log_aos_db_description"),
      },
      LOG_ARO_DB: {
        type: Aos::Cor::TYPES[:BOOL],
        access: Aos::Cor::DEF_ACCESS[:WRITE],
        value: Aos::Cor::BOOLS[:FALSE],
        description: I18n.t("cor.log_aro_db_description"),
      },
      FORMAT: {
        type: Aos::Cor::TYPES[:VALUES],
        implemented: false,
        access: Aos::Cor::DEF_ACCESS[:WRITE],
        value: Aos::Cor::FORMATS[:TEXT],
        description: I18n.t("cor.format.description"),
        possible_values: {
          text: I18n.t("cor.format.text_description"),
          json: I18n.t("cor.format.json_description")
        }
      },
      INTERFACE: {
        type: Aos::Cor::TYPES[:VALUES],
        implemented: false,
        access: Aos::Cor::DEF_ACCESS[:WRITE],
        value: Aos::Cor::INTERFACES[:TERMINAL],
        description: I18n.t("cor.interface.description"),
        possible_values: {
          terminal: I18n.t("cor.interface.terminal_description"),
          lanimret: I18n.t("cor.interface.lanimret_description")
        }
      },
      DIMENSION: {
        type: Aos::Cor::TYPES[:VALUES],
        access: Aos::Cor::DEF_ACCESS[:WRITE],
        value: Aos::Cor::DMS[:DEV_TAROT],
        description: I18n.t("cor.dimension.description"),
        possible_values: {
          dev_tarot: I18n.t("cor.dimension.dev_tarot_description"),
          ruby_facot: I18n.t("cor.dimension.ruby_facot_description"),
        }
      },
      HEIGHT: {
        type: Aos::Cor::TYPES[:INT],
        access: Aos::Cor::DEF_ACCESS[:WRITE],
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
        type: Aos::Cor::TYPES[:INT],
        access: Aos::Cor::DEF_ACCESS[:WRITE],
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
        type: Aos::Cor::TYPES[:INT],
        access: Aos::Cor::DEF_ACCESS[:WRITE],
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
        type: Aos::Cor::TYPES[:INT],
        access: Aos::Cor::DEF_ACCESS[:WRITE],
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
        type: Aos::Cor::TYPES[:INT],
        access: Aos::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::O,
        description: I18n.t("cor.aro_env.O_description"),
      },
      S: {
        type: Aos::Cor::TYPES[:INT],
        access: Aos::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::S,
        description: I18n.t("cor.aro_env.S_description"),
      },
      OS: {
        type: Aos::Cor::TYPES[:INT],
        access: Aos::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::OS,
        description: I18n.t("cor.aro_env.OS_description"),
      },
      E: {
        type: Aos::Cor::TYPES[:INT],
        access: Aos::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::E,
        description: I18n.t("cor.aro_env.E_description"),
      },
      N: {
        type: Aos::Cor::TYPES[:INT],
        access: Aos::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::N,
        description: I18n.t("cor.aro_env.N_description"),
      },
      PS1: {
        type: Aos::Cor::TYPES[:STRING],
        access: Aos::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::PS1,
        description: I18n.t("cor.aro_env.PS1_description"),
      },
      NAME_FILE: {
        type: Aos::Cor::TYPES[:STRING],
        access: Aos::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::NAME_FILE,
        description: I18n.t("cor.aro_env.NAME_FILE_description"),
      },
      I2097I: {
        type: Aos::Cor::TYPES[:STRING],
        access: Aos::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::I2097I,
        description: I18n.t("cor.aro_env.I2097I_description"),
      },
      YES: {
        type: Aos::Cor::TYPES[:STRING],
        access: Aos::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::YES,
        description: I18n.t("cor.aro_env.YES_description"),
      },
      ALL: {
        type: Aos::Cor::TYPES[:STRING],
        access: Aos::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::ALL,
        description: I18n.t("cor.aro_env.ALL_description"),
      },
    }

    def load
      self.cor_path = nil
      self.base_lines_def = nil
      Aro::Dom.instance.eg_path = nil
      return if Aos::Cor.get_cor_path.nil?
      unless File.exist?(Aos::Cor.cor_filepath)
        generate_config
      end

      source_config
      Aro::D.say("running in #{Aos::Cor.ivar(:ENV)} env.")

      self.display_lines = Aos::Cor.base_lines
    end

    def self.base_lines(args = nil)
      if self.instance.base_lines_def.nil? || args.present?
        args = [] if args.nil?
        # print Aos::Cor::DEF
        lines = []
        lines << "loaded config at: #{Aos::Os.osify(Aos::Cor.cor_filepath)}"
        lines << "<Aos::Cor::DEF>"
        case args[Aro::Mancy::S]&.to_sym
        when :ivars
          lines += Aos::Cor.ivars_dump
        when :ovars
          lines += Aos::Cor.ovars_dump
        else
          lines += Aos::Cor.ivars_dump
        end
        # print config commands
        lines << ""
        lines << I18n.t("aos.constants.commands")
        lines << ""
        lines += Aos::Vw::Base.lines_for_cmd(Aos::Os::CMDS[:COR])
        lines

        self.instance.base_lines_def = lines
      end

      return self.instance.base_lines_def
    end

    Mutex.new.synchronize do
      def self.get_cor_path
        if self.instance.cor_path.nil?
          if Aro::Dom.in_arodom?
            Aos::Os.instance.load_you!
            if Aos::Os.instance.you.root? ||
              Aos::Os.instance.you.agodo?
              self.instance.cor_path = Aos::Cor.dom_cor_path
            else
              self.instance.cor_path = Aos::Os.instance.you_flag.home
            end
          elsif Aro::Mancy.in_aro?
            self.instance.cor_path = Aos::Cor.aro_cor_path
          end
        end

        return self.instance.cor_path
      end
    end

    def self.aro_cor_path
      File.join(Dir.pwd, Aro::Db.base_aro_dir)
    end

    def self.dom_cor_path
      File.join(Aro::Dom::dom_root, Aro::Dom.room_path(:cor))
    end

    def self.cor_filepath
      File.join(
        Aos::Cor.get_cor_path,
        Aos::Cor::COR_FILE.to_s
      )
    end

    def self.is_test?
      Aos::Cor.ivar(:ENV) == Aos::Cor::ENVS[:TEST].to_s
    end

    def self.display_configuration
      height = Aos::Cor.ivar(:HEIGHT).to_i
      width = Aos::Cor.ivar(:WIDTH).to_i
      if !Aro::Dom.in_arodom? ||
        Aos::Cor.ivar(:INTERFACE) == Aos::Cor::INTERFACES[:TERMINAL].to_s
        # use console for terminal always
        h_con, w_con = IO.console.winsize
        height = h_con if h_con > 0
        width = w_con if w_con > 0
      end

      result = {
        HEIGHT: height,
        WIDTH: width,
        DIVIDER: :".".to_s
      }
      # Aro::V.say(result)

      result
    end

    def self.is_format_text?
      Aos::Cor.ivar(:FORMAT)&.to_sym == Aos::Cor::FORMATS[:TEXT]
    end

    def self.process_command(args)
      args = Aos::Os.sanitize_you(args)
      k = Aos::Cor::DEF.keys.filter{|k| k == args[Aro::Mancy::S]&.upcase&.to_sym}&.first
      unless k.nil?
        unless args[Aro::Mancy::OS].nil?
          # config <var_name> <var_value>
          Aos::Cor.set_ivar(args[Aro::Mancy::S], args[Aro::Mancy::OS])
        end

        # basic show var description and value
        self.instance.display_lines = self.instance.lines_var(k, Aos::Cor::DEF[k], ENV[Aos::Cor.ivar_k(k)])
      else
        self.instance.display_lines = Aos::Cor.base_lines(args)
      end

      if Aro::Mancy.in_aro? && !Aro::Dom.in_arodom?
        Aro::P.say(self.instance.display_lines.join("\n"))
      end
    end

    # out vars
    def self.ovar(suffix)
      Aos::Cor::DEF[suffix][:value]
    end
    # out vars
    def self.ovar_k(suffix)
      "#{Aos::Cor::ARO_OVA_PREFIX}#{suffix}"
    end

    # in vars
    def self.ivar(suffix)
      ENV[Aos::Cor.ivar_k(suffix)]
    end
    # in vars
    def self.ivar_k(suffix)
      "#{Aos::Cor::ARO_IVA_PREFIX}#{suffix}"
    end

    def self.set_ivar(k, new_value)
      k = k.upcase.to_sym

      current_value = Aos::Cor.ivar(k)
      if k == :DIMENSION &&
        new_value == Aos::Cor::DMS[:DEV_TAROT].to_s &&
        !Aro::T.is_dev_tarot_avail?
        Aro::Dom::P.say("unable to set dimension dev_tarot. device not present.")
        return
      end

      # ensure the var name is valid
      unless current_value.nil?
        Aro::Dom::P.say("validating #{k} with value #{new_value}")
        if Aos::Cor.instance.valid_var?(new_value, k, Aos::Cor::DEF[k])
          # set ENV value
          ENV[Aos::Cor.ivar_k(k)] = new_value
          Aro::Dom::P.say("#{k} set to #{new_value}")
          Aro::V.say(ENV[Aos::Cor.ivar_k(k)])

          # flush existing config and regen
          Aos::Cor.instance.generate_config(true)
          Aos::Cor.instance.source_config
          Aro::Db.configure_logger
          Aos::Db.configure_logger
        else
          Aro::Dom::P.say("the ivar value you entered is invalid. ignoring.")
        end
      else
        Aro::Dom::P.say("the ivar name you entered is invalid. ignoring.")
      end
    end

    def self.ivars_dump
      dump = []
      Aos::Cor::DEF.select{|k, v|
        v[:access] == Aos::Cor::DEF_ACCESS[:WRITE]
      }.each{|k, v|
          dump << "#{Aos::Cor.ivar_k(k).ljust(Aro::Mancy::NUMERALS[:XIV] * Aro::Mancy::OS)}=#{Aos::Cor.ivar(k)}"
      }

      dump
    end

    def self.ovars_dump
      dump = []
      Aos::Cor::DEF.select{|k, v|
        v[:access] == Aos::Cor::DEF_ACCESS[:READ]
      }.each{|k, v|
        dump << "#{Aos::Cor.ovar_k(k).ljust(Aro::Mancy::NUMERALS[:XIV] * Aro::Mancy::OS)}=#{Aos::Cor.ovar(k)}"
      }

      dump
    end

    def source_config
      Aro::D.say(I18n.t("cor.source", name: Aos::Cor.cor_filepath))
      File.read(Aos::Cor.cor_filepath).split("\n").select{|line|
        line.match?(/export #{Aos::Cor::ARO_IVA_PREFIX}/)
      }.map{|line|
        line.gsub("export ", "").split("=")
      }.each{|kv|
        Aro::V.say("variable to set: #{kv}")
        ENV[kv[0]] = kv[1] # source
        Aro::V.say("value actually set: #{ENV[kv[0]]}")
      }

      invalid_defs = validate_config
      Aos::Cor.ivars_dump.each{|l| Aro::V.say(l)}
      Aos::Cor.ovars_dump.each{|l| Aro::V.say(l)}
      invalid_defs.each{|k|
        v = Aos::Cor::DEF[k.to_sym]
        if v[:access] == Aos::Cor::DEF_ACCESS[:WRITE]
          ENV[Aos::Cor.ivar_k(k)] = v[:value]
        else
          ENV[Aos::Cor.ovar_k(k)] = v[:value]
        end
      }
    end

    # from_memory true means write current config to file
    def generate_config(from_memory = false)
      # todo: localize generated config text
      Aro::D.say(I18n.t("cor.generate", name: Aos::Cor.cor_filepath))

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
      Aos::Cor::DEF.each{|k, v|
        lines += lines_var(k, v, (from_memory ? ENV[Aos::Cor.ivar_k(k)] : nil))
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
      to_write = Aos::Cor.cor_filepath
      File.open(to_write, "w") do |file|
        file.write(lines.join("\n"))
        file.write("\n")
      end

      # unless (to_write == Aos::Cor.aro_cor_path) && Aro::Mancy.in_aro?
      #   File.open(Aos::Cor.aro_cor_path, "w") do |file|
      #     file.write(lines.join("\n"))
      #     file.write("\n")
      #   end
      # end
    end

    def lines_div
      ["#" * Aro::Mancy::NUMERALS[:XXI].pow(Aro::Mancy::OS)]
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
        "# this #{Aos::Os} cor configuration file",
        "# was auto generated by the #{Aos::Cor.name}."
      ]
    end

    def lines_var_section_div
      ["# VARIABLE SECTION!"]
    end

    def lines_def_type_description
      lines = []
      lines << "# Aos::Cor::DEF_TYPES"
      lines << "# describes the possible types of variables."
      Aos::Cor::DEF_TYPES.each{|k, v|
        lines << "# #{k}: #{v[:description]}"
      }
      lines += lines_newline_comment_os
      lines << "# Aos::Cor::DEF"
      lines << "# define & expose an aos cor bash api via ENV variables."
      lines << "# there are two types of bash vars in aos."
      lines << "# 1) in vars (ivars). "
      lines << "#     => ivars enter aos from this file during aos init."
      lines << "#     => cor validates them and uses them unless unvalid."
      lines << "#     => otherwise aos will use the defaults listed below."
      lines << "# 2) out vars (ovars)."
      lines << "#     => ovars are read-only vars that aos cor exposes to bash."
      lines << "#     => this is useful because it provides a bash interface"
      lines << "#     => which can be used to write programs on top of aos."
    end

    def lines_var(k, v, mem_v = nil)
      lines = []
      is_ovar = Aos::Cor::DEF[k][:access] == Aos::Cor::DEF_ACCESS[:READ]
      if is_ovar
        var_name = Aos::Cor.ovar_k(k)
      else
        var_name = Aos::Cor.ivar_k(k)
      end
      Aro::V.say("access for #{k} is #{Aos::Cor::DEF[k][:access]}")
      Aro::V.say("using var_name: #{var_name}")
      lines << "# [#{var_name}] (#{is_ovar ? :ovar : :ivar})"
      lines << "#   => Aos::Cor::DEF_TYPES: #{v[:type]}"
      case v[:type]
      when Aos::Cor::DEF_TYPES[:BOOL][:name]
        lines << "#   => #{I18n.t("cor.type.bool_description")}"
      when Aos::Cor::DEF_TYPES[:INT][:name]
        lines << "#   => #{I18n.t("cor.type.int_description")}"
        lines << "#   => #{I18n.t("cor.minimum")}: #{v[:min]}"
        lines << "#   => #{I18n.t("cor.maximum")}: #{v[:max]}"
      when Aos::Cor::DEF_TYPES[:STRING][:name]
        lines << "#   => #{I18n.t("cor.type.string_description")}"
        lines << "#   => use \"double quotes\" if there are any spaces."
      when Aos::Cor::DEF_TYPES[:VALUES][:name]
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
      if is_ovar && Aos::Cor::DEF_TYPES[:STRING][:name] == v[:type]
        lines << "export #{var_name}=\"#{v[:value]}\""
      else
        lines << "export #{var_name}=#{mem_v || v[:value]}"
      end
      lines += lines_newline_comment_os
      lines
    end

  end
end
