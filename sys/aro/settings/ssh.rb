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

      def self.encrypt!(decrypted_json)
        Aro::Dom::Ma_ain.sane_backtrace!
        puts __method__
        puts :expects_decrypted_json

        return decrypted_json
      end

      def self.decrypt!(encrypted_json)
        Aro::Dom::Ma_ain.sane_backtrace!
        puts __method__
        puts :expects_encrypted_json

        return encrypted_json
      end

    end
  end
end
