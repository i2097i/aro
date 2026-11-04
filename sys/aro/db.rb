=begin
  
  db.rb

  database for aro room.

  by i2097i

=end

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
      if Aro::Cor.ivar(:LOG_DATABASE).to_s == Aro::Cor::BOOLS[:TRUE].to_s
        ActiveRecord::Base.logger = Logger.new(STDOUT)
      else
        ActiveRecord::Base.logger = nil
      end
    end

    def self.base_aro_dir
      base_aro_file = Aro::Mancy::ARO_FILE.to_s
      return "#{base_aro_file}_#{Aro::Cor::ENVS[:TEST]}" if Aro::Cor.is_test?

      base_aro_file
    end

    def db_config_filepath
      @db_config_filepath ||= File.join(Aro::Db.base_aro_dir, Aro::Db::DATABASE_YML.to_s)
    end

    def setup_local_aro
      aro_name = Aro::Mancy.in_aro? ? Aro::Mancy.aro_mancy_name : nil
      # todo: exit here if error
      return if aro_name.nil? || Aro::Dom::D.reserved_words.include?(aro_name.to_sym)

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
          username: aro_name,
          password: aro_name,
          pool: 11
        }.to_yaml
        File.open(db_config_filepath, "w") do |file|
          file.write(c)
        end
      end

      connect
      migrate(aro_name)
    end

    def connect
      ActiveRecord::Base.establish_connection(
        YAML.load_file(db_config_filepath)
      )
    end

    def migrate(aro_name)
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
