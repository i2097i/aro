# frozen_string_literal: true

=begin

  ssh.rb

  aro dom ssh.

  by i2097i

=end

module Aro
  module Dom
    class Ssh
      EXEC_METHODS = [
        :print_public_key,
      ]

      ID_KEY_BASE = :id_oss_om

      def self.open!
        generate_ssh_menu_items!
        Aro::Dom::Ma_ain.open!(:ssh)
      end

      def self.print_public_key
        Aro::P.less(::File.read("#{id_key_path}.pub"))
      end

      def self.write_encrypted_file!(file_path, decrypted_json)
        # todo: validations
        #
        # 1) encrypt decrypted_json
        # 2) write encrypted contents
        # 3) return success/failure
        begin
          # open and write
          ::File.open(file_path, "w+") do |f|
            f.write(
              encrypt!(decrypted_json)
            )
          end
        rescue StandardError => e
          Aro::P.say("#{self.name}:#{__method__}")
          Aro::P.say(e.inspect)
          return e
        end

        return true
      end

      def self.decrypt_file!(file_path)
        # 1) open file
        # 2) decrypt contents
        # 3) return decrypted contents
        begin
          # read and decrypt
          decrypted_json = decrypt!(
            JSON.parse(
              ::File.read(file_path, encoding: "UTF-8")
            )
          )
        rescue JSON::ParserError => e
          Aro::P.say("#{self.name}:#{__method__}")
          Aro::P.say(e.inspect)
          return e
        rescue StandardError => e
          Aro::P.say("#{self.name}:#{__method__}")
          Aro::P.say(e.inspect)
          return e
        end

        decrypted_json
      end

      def self.id_key_path
        ::File.join(Aro::Cor.ivar(:OSS_OM_HOME), ID_KEY_BASE.to_s)
      end

      private

      def self.generate_ssh_menu_items!
        ssh_menu = Aro::Dom::DataBase.open_menu(:ssh)
        return unless Aro::Mancy::S == ssh_menu.menu_items.count
        # todo: generate ssh menu items if needed here
        existing_item = ssh_menu.menu_items.first
        raise "missing existing item in #{self.name}.#{__method__}!" if existing_item.nil?
        EXEC_METHODS.each{|method_name|
          menu_item = existing_item || ssh_menu.generate_new_item(method_name, for_type: :system)

          ssh_menu.rename_item(menu_item, method_name) unless existing_item.nil?
          menu_item.aro_file.write!(
            Aro::Dom::Store.build_exec_oss_om_params!(
              self,
              method_name,
              "#{:ssh} #{method_name}"
            )
          )
          # clear existing item var
          existing_item = nil unless existing_item.nil?
        }
      end

      def self.encrypt!(decrypted_json)
        Aro::Dom::Ma_ain.i2097i_bookmark
        puts __method__
        puts :expects_decrypted_json

        return decrypted_json
      end

      def self.decrypt!(encrypted_json)
        Aro::Dom::Ma_ain.i2097i_bookmark
        puts __method__
        puts :expects_encrypted_json

        return encrypted_json
      end

    end
  end
end
