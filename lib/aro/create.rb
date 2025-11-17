module Aro
  class Create
    def initialize(name = nil)
      name = name&.strip

      error_msg = nil

      # is a non-empty string
      error_msg = "aborting - missing or invalid name" if name.nil? || !name.kind_of?(String) || name.empty?

      # display error and abort
      unless error_msg.nil?
        Aro::P.p.say(I18n.t("messages.usage"))
        raise error_msg
      end

      # create the new aro directory and database
      if Aro::Database.get_name_from_namefile.nil? && !Dir.exist?(name)
        Aro::P.p.say("creating #{name}...")
        create_cmd = "mkdir #{name}"
        Aro::P.p.say(create_cmd)
        system(create_cmd)
      end

      # create database
      Aro::Database.new(name)
    end

  end
end
