=begin
  
  db.rb

  database for aro room.

  by i2097i

=end

require_relative :"./mancy".to_s
require_relative :"../aos/cor".to_s

module Aro
  class Db
    include Singleton

    DATABASE_YML = :"database.yml"
    GEM_DB_PATH = :"sys/aro/db"
    MIGRATIONS_DIR = :"db/migrate"
    SCHEMA_FILE = :"schema.rb"
    SQL_FILE = :"aro.sql"

    def self.load
      Aro::Db.configure_logger
      if Aro::Mancy.in_aro?
        self.instance.setup_local_aro
      end
    end

    def self.configure_logger
      if Aos::Cor.ivar(:LOG_ARO_DB).to_s == Aos::Cor::BOOLS[:TRUE].to_s
        ActiveRecord::Base.logger = Logger.new(STDOUT)
      else
        ActiveRecord::Base.logger = nil
      end
    end

    def self.base_aro_dir
      base_aro_file = Aro::Mancy::ARO_FILE.to_s
      return "#{base_aro_file}_#{Aos::Cor::ENVS[:TEST]}" if Aos::Cor.is_test?

      base_aro_file
    end

    def db_config_filepath
      @db_config_filepath ||= File.join(Aro::Db.base_aro_dir, Aro::Db::DATABASE_YML.to_s)
    end

    def setup_local_aro
      name = Aro::Mancy.in_aro? ? Aro::Mancy.aro_mancy_name : nil
      return if name.nil? || name.to_sym == Aos::Os::CMDS[:ABOT][:key]

      # create local .aro/ directory
      unless File.exist?(Aro::Db.base_aro_dir)
        Aro::P.say("creating #{Aro::Mancy::ARO_FILE.to_s} directory...")
        FileUtils.mkdir(Aro::Db.base_aro_dir)
      end

      unless File.exist?(db_config_filepath)
        # create database config yaml file
        c = {
          adapter: :sqlite3.to_s,
          database: File.join(Aro::Db.base_aro_dir, Aro::Db::SQL_FILE.to_s),
          username: name,
          password: name,
          pool: Aos::Os::DB_POOL
        }.to_yaml
        File.open(db_config_filepath, "w") do |file|
          file.write(c)
        end
      end

      connect
      migrate(name)
    end

    def connect
      ActiveRecord::Base.establish_connection(
        YAML.load_file(db_config_filepath)
      )
    end

    def migrate(name)
      local_migrate_dir = File.join(Aro::Db.base_aro_dir, Aro::Db::MIGRATIONS_DIR.to_s)
      unless Dir.exist?(local_migrate_dir)
        gem_dir = Dir[Reiquire::GEM_PATH || '.'].first
        FileUtils.cp_r(File.join(gem_dir, Aro::Db::GEM_DB_PATH.to_s), Aro::Db.base_aro_dir)
      end

      migration_version = Dir["#{local_migrate_dir}/*.rb"].map{|n|
        Pathname.new(n).basename.to_s.split("_")[0].to_i
      }.max
      ActiveRecord::MigrationContext.new(local_migrate_dir).migrate(migration_version)

      filename = File.join(Aro::Db.base_aro_dir, Aro::Db::SCHEMA_FILE.to_s)
      File.open(filename, "w+") do |f|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection_pool, f)
      end
    end
  end
end
