=begin
  
  db.rb

  database for aro room.

  by i2097i

=end

module Aro
  class Db
    include Singleton

    attr_accessor :active_record_connection_instance
    HEARTBEAT_DURATION = 11
    DATABASE_YML = :"database.yml"
    SCHEMA_FILE = :"schema.rb"
    SQL_FILE = :"base.sql"

    def self.ensure_connected!
      return if self.instance.connected?

      Aro::Db.configure_logger
      if Aro::Mancy.in_aro?
        self.instance.setup_local_aro
      end
    end

    def connected?
      !self.active_record_connection_instance.nil? &&
        self.active_record_connection_instance.connected?
    end

    def self.configure_logger
      if Aro::Cor.ivar(:LOG_DATABASE).to_s == Aro::Cor::BOOLS[:TRUE].to_s
        ActiveRecord::Base.logger = Logger.new(STDOUT)
      else
        ActiveRecord::Base.logger = nil
      end
    end

    def self.base_db_dir
      db_dir = File.join(Aro::Mancy.root_dir, :db.to_s)
      return "#{db_dir}_#{Aro::Cor::ENVS[:TEST]}" if Aro::Cor.is_test?
      db_dir
    end

    def self.local_migrate_dir
      File.join(Aro::Db.base_db_dir, :migrate.to_s)
    end

    def self.sql_filepath
      File.join(Aro::Db.base_db_dir, Aro::Db::SQL_FILE.to_s)
    end

    def db_config_filepath
      @db_config_filepath ||= File.join(Aro::Db.base_db_dir, Aro::Db::DATABASE_YML.to_s)
    end

    def setup_local_aro
      aro_name = Aro::Mancy.in_aro? ? Aro::Mancy.aro_mancy_name : nil
      # todo: exit here if error
      return if aro_name.nil?

      # create local .aro/ directory
      unless File.exist?(Aro::Db.base_db_dir)
        Aro::P.say("creating #{Aro::Db.base_db_dir} directory...")
        FileUtils.mkdir_p(Aro::Db.base_db_dir)
      end

      unless File.exist?(db_config_filepath)
        pw = Aro::P.p.ask(I18n.t("messages.base_db_password_prompt", aro_name: aro_name, sql_filepath: self.class.sql_filepath))
        pw = aro_name unless pw.present?
        # create database config yaml file
        c = {
          adapter: :sqlite3.to_s,
          database: self.class.sql_filepath,
          username: aro_name,
          password: pw,
          pool: 11
        }.to_yaml
        File.open(db_config_filepath, "w") do |file|
          file.write(c)
        end
        Aro::P.say("set #{self.class.sql_filepath} password to #{pw}")
        Aro::P.say(Psych.load(db_config_filepath))
      end

      connect
      migrate
    end

    def connect
      self.active_record_connection_instance = ActiveRecord::Base.establish_connection(
        YAML.load_file(db_config_filepath)
      )
      Aro::P.say("#{self}#{__method__}#{self.active_record_connection_instance.inspect}")
    end

    def migrate
      Reiquire.copy_db_migrations_from_gem! unless Dir.exist?(Aro::Db.local_migrate_dir)
      migration_version = Dir["#{Aro::Db.local_migrate_dir}/*.rb"].map{|n|
        Pathname.new(n).basename.to_s.split("_")[0].to_i
      }.max
      ActiveRecord::MigrationContext.new(Aro::Db.local_migrate_dir).migrate(migration_version)
      dump_schema
    end

    def dump_schema
      filename = File.join(Aro::Db.base_db_dir, Aro::Db::SCHEMA_FILE.to_s)
      File.open(filename, "w+") do |f|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection_pool, f)
      end
    end
  end
end
