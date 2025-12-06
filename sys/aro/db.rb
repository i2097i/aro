=begin
  
  db.rb

  database for aro room.

  by i2097i

=end

module Aro
  class Db
    DATABASE_YML = :"database.yml"
    SQL_FILE = :"database.sql"
    SCHEMA_FILE = :"schema.rb"
    MIGRATIONS_DIR = :"db/migrate"

    def initialize
      unless Aro::Mancy.is_aro_space?
        Aro::P.say(I18n.t("cli.errors.not_in_aro" , cmd: Aro::Mancy::I2097I))
        return
      end

      if Aro::Mancy.is_initialized?
        setup_local_aro
      else
        Aro::P.say(I18n.t("cli.warnings.not_initialized"))
      end
    end

    def connect(name)
      ActiveRecord::Base.establish_connection(config)
    end

    def config
      @config ||= YAML.load_file(db_config_filepath)
    end

    def self.base_aro_dir
      base_aro_file = Aro::Mancy::ARO_FILE.to_s
      CLI::Config.is_test? ? "#{base_aro_file}_test" : base_aro_file
    end

    def db_config_filepath
      File.join(Aro::Db.base_aro_dir, Aro::Db::DATABASE_YML.to_s)
    end

    def self.get_name_from_namefile
      Aro::Mancy.is_aro_space? ? File.read(Aro::Mancy::NAME_FILE.to_s).strip : nil
    end

    def setup_local_aro
      name = Aro::Db.get_name_from_namefile
      return if name.nil?

      # create local .aro/ directory
      unless File.exist?(Aro::Db.base_aro_dir)
        FileUtils.mkdir(Aro::Db.base_aro_dir)
      end

      unless File.exist?(db_config_filepath)
        # create database config yaml file
        c = {
          adapter: :sqlite3.to_s,
          database: File.join(Aro::Db.base_aro_dir, Aro::Db::SQL_FILE.to_s),
          username: name,
          password: name
        }.to_yaml
        File.open(db_config_filepath, "w") do |file|
          file.write(c)
        end
      end

      connect(name)
      migrate(name)
    end

    def migrate(name)
      local_migrate_dir = File.join(Aro::Db.base_aro_dir, Aro::Db::MIGRATIONS_DIR.to_s)
      unless Dir.exist?(local_migrate_dir)
        gem_dir = Dir[Gem.loaded_specs[:aro.to_s]&.full_gem_path || '.'].first
        FileUtils.cp_r(File.join(gem_dir, "db"), Aro::Db::base_aro_dir)
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
