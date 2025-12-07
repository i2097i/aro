=begin

  db.rb

  database for aos room.

  by i2097i

=end

module Aos
  class Db < Aro::Db
    DATABASE_YML = :"database.yml"
    SQL_FILE = :"database.sql"
    SCHEMA_FILE = :"schema.rb"
    MIGRATIONS_DIR = :"db/migrate"

    def initialize
      # ActiveRecord::Base.logger = Logger.new(STDOUT)
      unless Aro::Dom.in_arodom?
        Aro::P.say(I18n.t("cli.errors.not_in_aro" , cmd: Aro::Dom.name))
        return
      end

      set_up_aos
    end

    def self.base_aro_dir
      Aro::Dom.ethergeist_path
    end

    def db_config_filepath
      File.join(Aos::Db.base_aro_dir, Aos::Db::DATABASE_YML.to_s)
    end

    def set_up_aos
      name = Aro::Dom.ethergeist_name
      return if name.nil?

      # create local /.ethergeist directory
      unless File.exist?(Aos::Db.base_aro_dir)
        FileUtils.mkdir(Aos::Db.base_aro_dir)
      end

      Aro::D.say("creating database: #{db_config_filepath}")
      unless File.exist?(db_config_filepath)
        # create database config yaml file
        c = {
          adapter: :sqlite3.to_s,
          database: File.join(Aos::Db.base_aro_dir, Aos::Db::SQL_FILE.to_s),
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
      local_migrate_dir = File.join(Aos::Db.base_aro_dir, Aos::Db::MIGRATIONS_DIR.to_s)
      unless Dir.exist?(local_migrate_dir)
        gem_dir = Dir[Gem.loaded_specs[:aro.to_s]&.full_gem_path || '.'].first
        FileUtils.cp_r(File.join(gem_dir, "db"), Aos::Db::base_aro_dir)
      end

      migration_version = Dir["#{local_migrate_dir}/*.rb"].map{|n|
        Pathname.new(n).basename.to_s.split("_")[0].to_i
      }.max
      ActiveRecord::MigrationContext.new(local_migrate_dir).migrate(migration_version)

      filename = File.join(Aos::Db.base_aro_dir, Aos::Db::SCHEMA_FILE.to_s)
      File.open(filename, "w+") do |f|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection_pool, f)
      end
    end
  end
end
