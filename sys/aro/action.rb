# frozen_string_literal: true

=begin

  action.rb

  aro dom action

  by i2097i

=end

module Aro
  module Dom
    class Action

      TYPES = {
        OSS_OM: {
          key: :exec_oss_om,
          params: {
            aro_class_name: {
              default_value: Aro::Dom::Action.name,
              required: true
            },
            aro_class_method: {
              default_value: :inspect,
              required: false
            },
            oss_om_ssh_key: {
              default_value: nil,
              required: true,
              unique: true
            }
          }
        },
        SYSTEM: {
          key: :exec_system,
          params: {
            command_string: {
              default_value: nil,
              required: true
            },
            oss_om_ssh_key: {
              default_value: nil,
              required: true,
              unique: true
            }
          }
        },
        CREATE_DATA_BASE: {
          key: :exec_data_base,
          params: {
            data_base_name: {
              default_value: nil,
              required: true,
              unique: true
            },
            oss_om_ssh_key: {
              default_value: nil,
              required: true,
              unique: true
            }
          },
        }
      }

      def self.valid_param_values!(action_key, params)
        params.keys.each{|k|
          v = params[k]
          params_action_def = Aro::Dom::Action::TYPES[action_key][:params][k.to_sym]
          v = params_action_def[:default_value] if v.nil?
          required = false
          required = params_action_def[:required] unless params_action_def[:required].nil?

          raise "required value missing! params[#{k}] = '#{v}'" if required && (v.nil? || v.empty?)
        }
      end

      def self.valid_param_keys!(action_key, params)
        (
          Aro::Dom::Action::TYPES[action_key][:params].keys & # assert one ampersand(&) here!
          params.keys.map{|k|
            k.to_s&.strip.to_sym
          }
        ).count == params.keys.count
      end

      def self.validate_params!(action_key, params)
        Aro::P.say("validating #{action_key} action")
        Aro::V.say("params: #{JSON.pretty_generate(params)}")

        raise "invalid params! (#{params})" unless params.kind_of?(Hash) &&
          valid_param_keys!(action_key, params) && valid_param_values!(action_key, params)
      end

      def self.validate_action_key!(action_key)
        action_key = action_key&.upcase.to_sym
        raise "invalid action! (#{action_key})" unless Aro::Dom::Action::TYPES.keys.include?(action_key)
        return action_key
      end

      def self.create(action_key, menu_item)
        Aro::P.say(__method__)
        action_key = validate_action_key!(action_key)

        aro_action_type_def = Aro::Dom::Action::TYPES[action_key]
        case aro_action_type_def[:key]
        when :exec_oss_om
          Aro::Dom::Oss_OpenMenu.create_exec_oss_om_entry_for(menu_item)
        when :exec_system
          Aro::Dom::Oss_OpenMenu.create_exec_system_entry_for(menu_item)
        when :exec_data_base
          Aro::Dom::Oss_OpenMenu.create_exec_data_base_entry_for(menu_item)
        end
      end

      def self.perform(action_key, params = {})
        Aro::P.say(__method__)
        action_key = validate_action_key!(action_key)
        validate_params!(action_key, params)

        params = params.symbolize_keys
        aro_action_type_def = Aro::Dom::Action::TYPES[action_key]
        case aro_action_type_def[:key]
        when :exec_oss_om
          Aro::P.say("#{params[:aro_class_name]}.#{params[:aro_class_method]}")
          begin
            params[:aro_class_name].constantize.send(params[:aro_class_method])
          rescue NoMethodError => e
            Aro::P.say("exec_oss_om error! #{e}")
          end
        when :exec_system
          Aro::P.say("todo: implement!")
          Aro::P.say("when :exec_system")
          Aro::Dom::Ma_ain.sane_backtrace!
          command_string = params[:command_string]
          if command_string.nil?
            raise "invalid command_string! #{command_string}"
          end
          Aro::P.say("#{self.name} performing #{action_key} action: [system(#{command_string})]")
          result = system("#{command_string}")
          Aro::P.say("=> #{result}")
          Aro::P.say("\n")
        when :exec_data_base
          Aro::P.say("todo: implement!")
          Aro::P.say("when :exec_data_base")
          Aro::Dom::Ma_ain.sane_backtrace!
        end
      end

    end
  end
end