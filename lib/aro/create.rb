module Aro
  class Create
    attr_accessor :initialized

    def initialize(name)
      self.initialized = false

      if !name.nil? && (
        name.kind_of?(String) ||
        name.kind_of?(Symbol)
      )
        # explicitly only allow String/Symbol types for name
        name = name.to_s.strip

        # create the new aro directory and database
        if Aro::Db.get_name_from_namefile.nil? && !Dir.exist?(name)
          Aro::P.say(I18n.t("cli.messages.no_decks"))
          create_cmd = "mkdir #{name}"
          Aro::P.say("#{create_cmd} (result: #{system(create_cmd)})")
        end

        # create database
        Aro::Db.new(name) 
        self.initialized = true       
      end
    end

  end
end
