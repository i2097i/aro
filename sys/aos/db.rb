=begin

  db.rb

  database for aos.

  by i2097i

=end

module Aos
  class Db
    include Singleton

    DATABASE_YML = :"database.yml"
    GEM_DB_PATH = :"sys/aos/db"
    MIGRATIONS_DIR = :"db/migrate"
    SCHEMA_FILE = :"schema.rb"
    SQL_FILE = :"aos.sql"

    def self.load(password = nil)
      Aos::Db.configure_logger
      Mutex.new.synchronize do
        if Aro::Dom.in_arodom?
          self.instance.set_up_aos(password)
        else
          Aro::P.say(I18n.t("cli.errors.not_in_aro" , cmd: Aro::Dom.name))
        end
      end
    end

    def self.configure_logger
      if Aos::Cor.ivar(:LOG_AOS_DB).to_s == Aos::Cor::BOOLS[:TRUE].to_s
        ActiveRecord::Base.logger = Logger.new(STDOUT)
      else
        ActiveRecord::Base.logger = nil
      end
    end

    def self.base_aro_dir
      File.join(Aro::Dom.dom_root, Aro::Dom.room_path(:data))
    end

    def db_config_filepath
      # intentionally using Aro::Db::DATABASE_YML here
      @db_config_filepath = File.join(Aos::Db.base_aro_dir, Aro::Db::DATABASE_YML.to_s)
    end

    def set_up_aos(password)
      ActiveRecord::Base.connection_pool.flush! unless password.nil?
      # create local /.ethergeist directory
      unless File.exist?(Aos::Db.base_aro_dir)
        FileUtils.mkdir(Aos::Db.base_aro_dir)
      end

      unless File.exist?(db_config_filepath)
        unless password.nil?
          Aro::D.say("creating database: #{db_config_filepath}")
          # create database config yaml file
          db_file_path = File.join(Aos::Db.base_aro_dir, Aos::Db::SQL_FILE.to_s)
          File.open(db_config_filepath, "w") do |file|
            file.write({
              adapter: :sqlite3.to_s,
              database: db_file_path,
              username: Aro::Dom.ethergeist_name,
              password: password,
              pool: Aos::Os::DB_POOL
            }.to_yaml)
          end
        else
          Aro::D.say("unable to create database without root password.")
        end
      end

      if File.exist?(db_config_filepath)
        connect
        migrate
      else
        Aro::D.say("unable to set up database without root password.")
      end
    end

    def connect
      ActiveRecord::Base.establish_connection(
        YAML.load_file(db_config_filepath)
      )
    end

    def migrate
      local_migrate_dir = File.join(Aos::Db.base_aro_dir, Aro::Db::MIGRATIONS_DIR.to_s)
      unless Dir.exist?(local_migrate_dir)
        gem_dir = Dir[Reiquire::GEM_PATH || '.'].first
        FileUtils.cp_r(File.join(gem_dir, Aos::Db::GEM_DB_PATH.to_s), Aos::Db::base_aro_dir)
      end

      migration_version = Dir["#{local_migrate_dir}/*.rb"].map{|n|
        Pathname.new(n).basename.to_s.split("_")[0].to_i
      }.max
      ActiveRecord::MigrationContext.new(local_migrate_dir).migrate(migration_version)

      filename = File.join(Aos::Db.base_aro_dir, Aro::Db::SCHEMA_FILE.to_s)
      File.open(filename, "w+") do |f|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection_pool, f)
      end
    end
  end
end
