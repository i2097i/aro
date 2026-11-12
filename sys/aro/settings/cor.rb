# frozen_string_literal: true

=begin
  
  cor.rb

  oss_om cor.

  by i2097i

=end

# require_relative :"./mancy".to_s

module Aro
  class Cor
    include Singleton

    EXEC_METHODS = [
      :print_env,
      :print_cor_def,
      :edit_ivars
    ]

    def self.print_env
      self.instance.source_config
      Aro::P.say(:printing_ivars)
      Aro::P.say("\n")
      puts ivars_dump.join("\n")
      Aro::P.say(:printing_ovars)
      Aro::P.say("\n")
      puts ovars_dump.join("\n")
    end

    def self.print_cor_def
      self.instance.source_config
      Aro::P.say("Aro::Cor::DEF")
      Aro::P.say("\n" + Aro::Cor::DEF.map{|k, v|
        "#{k}: " + JSON.pretty_generate(Aro::Cor::DEF[k])
      }.join("\n"))
    end

    def self.edit_ivars

      Aro::P.say("#{self.name}.#{__method__}")
      selected_def_key = Aro::P.default_select(
        I18n.t("open_menu.edit_ivars_select"),
        [{name: :back, value: :back}] + Aro::Cor::DEF.select{|k, v|
          # do not allow writing to OSS_OM_HOME from oss_om
          v[:access] == Aro::Cor::DEF_ACCESS[:WRITE] && k != :OSS_OM_HOME
        }.map{|k, v|
          {name: "#{k} (#{ivar(k)})", value: k}
        }
      )

      return if selected_def_key == :back
      Aro::P.say("'#{selected_def_key}' selected")

      new_value = nil
      while new_value.nil? || 
        !self.instance.valid_var?(
          new_value,
          selected_def_key,
          Aro::Cor::DEF[selected_def_key]
        )

        case Aro::Cor::DEF[selected_def_key][:type]
        when :bool
          new_value = !(ivar(selected_def_key) == :true.to_s)
        when :int, :string
          new_value = Aro::P.p.ask(
            I18n.t(
              "open_menu.new_ivar_value_prompt",
              def_key: selected_def_key,
              current_value: ivar(selected_def_key),
              value_type: Aro::Cor::DEF[selected_def_key][:type]
            )
          )
        when :values
          new_value = Aro::P.default_select(
            I18n.t("open_menu.edit_ivars_possible_values_select", def_key: selected_def_key),
            [
              {name: :back, value: :back}
            ] + Aro::Cor::DEF[
              selected_def_key
            ][:possible_values].map{|k, v|
              Aro::P.say("#{k}_desc: #{v}") # v is description localized text
              
              {name: k, value: k}
            }
          )

          return if new_value == :back
        end

      end

      set_ivar(selected_def_key, new_value)
     end

    ARO_IVA_PREFIX = :ARO_IVA_
    ARO_OVA_PREFIX = :ARO_OVA_

    COR_FILE = :".om_cor"

    DATE_FORMAT = "%Y:%m:%d:%H:%M:%S"

    DEBUG_MODES = [:development, :test]

    # possible envs
    #
    # example usage:
    # Aro::Cor::ENVS[:PRODUCTION]
    ENVS = {
      DEVELOPMENT: :development,
      PRODUCTION: :production,
      TEST: :test
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
    # Aro::Cor::DEF_TYPES[:INT][:validator].call(unvalid, Aro::Cor::DEF[:])
    DEF_TYPES = {
      BOOL: {
        name: Aro::Cor::TYPES[:BOOL],
        description: I18n.t("cor.types.bool_description"),
        converter: Proc.new{|v| v.kind_of?(TrueClass) ? true : false},
        validator: Proc.new{|unvalid, k, v|
          Aro::Cor.def_valid?(k, v) &&
          Aro::Cor.bool_valid?(unvalid)
        }
      },
      INT: {
        name: Aro::Cor::TYPES[:INT],
        description: I18n.t("cor.types.int_description"),
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
        description: I18n.t("cor.types.string_description"),
        converter: Proc.new{|v| v.to_s},
        validator: Proc.new{|unvalid, k, v|
          Aro::Cor.def_valid?(k, v) &&
          Aro::Cor.string_valid?(unvalid)
        }
      },
      VALUES: {
        name: Aro::Cor::TYPES[:VALUES],
        description: I18n.t("cor.types.values_description"),
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
    # Aro::Cor::DEF[:ENV]
    DEF = {
      #
      # => ivars
      #
      ENV: {
        type: Aro::Cor::TYPES[:VALUES],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: Aro::Cor::ENVS[:PRODUCTION],
        description: I18n.t("cor.ivars.env.description"),
        possible_values: {
          development: I18n.t("cor.ivars.env.development_description"),
          production: I18n.t("cor.ivars.env.production_description"),
          test: I18n.t("cor.ivars.env.test_description"),
        }
      },
      VERBOSE: {
        type: Aro::Cor::TYPES[:BOOL],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: Aro::Cor::BOOLS[:FALSE],
        description: I18n.t("cor.ivars.verbose_description"),
      },
      OSS_OM_HOME: {
        type: Aro::Cor::TYPES[:STRING],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: nil,
        description: I18n.t("cor.ivars.oss_om_home.description"),
        possible_values: {
          path: I18n.t("cor.ivars.oss_om_home.path_description"),
        }
      },
      LOG_DATABASE: {
        type: Aro::Cor::TYPES[:BOOL],
        access: Aro::Cor::DEF_ACCESS[:WRITE],
        value: Aro::Cor::BOOLS[:FALSE],
        description: I18n.t("cor.ivars.log_db_description"),
      },

      #
      # => ovars
      #
      OSS_OM_FILE: {
        type: Aro::Cor::TYPES[:STRING],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::NAME_FILE,
        description: I18n.t("cor.ovars.OSS_OM_FILE_description"),
      },
      O: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::O,
        description: I18n.t("cor.ovars.O_description"),
      },
      S: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::S,
        description: I18n.t("cor.ovars.S_description"),
      },
      OS: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::OS,
        description: I18n.t("cor.ovars.OS_description"),
      },
      E: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::E,
        description: I18n.t("cor.ovars.E_description"),
      },
      N: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::N,
        description: I18n.t("cor.ovars.N_description"),
      },
      N: {
        type: Aro::Cor::TYPES[:INT],
        access: Aro::Cor::DEF_ACCESS[:READ],
        value: Aro::Mancy::V,
        description: I18n.t("cor.ovars.V_description"),
      },
    }

    def self.open!
      cor_menu = Aro::Dom::DataBase.open_menu(:cor)
      generate_cor_menu_items! if Aro::Mancy::S == cor_menu.menu_items.count
      Aro::Dom::Ma_ain.open!(:cor)
    end

    def load_env!
      unless File.exist?(Aro::Cor.cor_filepath)
        generate_config
      end

      source_config
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

    def self.is_development?
      Aro::Cor.ivar(:ENV) == Aro::Cor::ENVS[:DEVELOPMENT].to_s
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
      if k == :OSS_OM_HOME
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
      return unless File.exist?(Aro::Cor.cor_filepath)
      Aro::D.say(I18n.t("cor.source", name: Aro::Cor.cor_filepath))
      File.read(Aro::Cor.cor_filepath).split("\n").select{|line|
        line.match?(/export #{Aro::Cor::ARO_IVA_PREFIX}/)
      }.map{|line|
        line.gsub("export ", "").split("=")
      }.each{|kv|
        Aro::D.say("variable_to_set: #{kv}")
        result = Aro::Cor.instance.cor_set_ruby_env!(kv[0].gsub(Aro::Cor::ARO_IVA_PREFIX.to_s, ""), kv[1])
        Aro::D.say("ENV[#{kv[0]}] set successfully: #{result}")
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

    private

    def self.generate_cor_menu_items!
      cor_menu = Aro::Dom::DataBase.open_menu(:cor)
      return unless Aro::Mancy::S == cor_menu.menu_items.count

      existing_item = cor_menu.menu_items.first
      raise "missing existing item in #{self.name}.#{__method__}!" if existing_item.nil?
      EXEC_METHODS.each{|method_name|
        menu_item = existing_item || cor_menu.generate_new_item(method_name, for_type: :system)

        cor_menu.rename_item(menu_item, method_name) unless existing_item.nil?
        menu_item.aro_file.write!(
          Aro::Dom::Store.build_exec_oss_om_params!(
            self,
            method_name,
            "#{:cor} #{method_name}"
          )
        )
        # clear existing item var
        existing_item = nil unless existing_item.nil?
      }
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
        lines << "#   => #{I18n.t("cor.types.bool_description")}"
      when Aro::Cor::DEF_TYPES[:INT][:name]
        lines << "#   => #{I18n.t("cor.types.int_description")}"
        lines << "#   => #{I18n.t("cor.minimum")}: #{v[:min]}"
        lines << "#   => #{I18n.t("cor.maximum")}: #{v[:max]}"
      when Aro::Cor::DEF_TYPES[:STRING][:name]
        lines << "#   => #{I18n.t("cor.types.string_description")}"
        lines << "#   => use \"double quotes\" if there are any spaces."
      when Aro::Cor::DEF_TYPES[:VALUES][:name]
        lines << "#   => #{I18n.t("cor.types.values_description")}"
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
