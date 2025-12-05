=begin
  
  db.rb

  database for aro room.

  by i2097i

=end

require :active_record.to_s
require :base64.to_s
require :fileutils.to_s
require :yaml.to_s

module Aro
  class Db
    CONFIG_FILE = "database.yml"
    SQL_FILE = "database.sql"
    SCHEMA_FILE = "schema.rb"
    MIGRATIONS_DIR = "db/migrate"
    DIRS = {
      ARO: Proc.new{Aro::IS_TEST.call ? ".aro_test" : ".aro"},
    }

    def initialize
      raise "not in aro space" unless Aro::Mancy.is_aro_space?

      setup_local_aro
    end

    def connect(name)
      ActiveRecord::Base.establish_connection(config)
    end

    def config
      @config ||= YAML.load_file(db_config_filepath)
    end

    def self.base_aro_dir
      DIRS[:ARO].call
    end

    def db_config_filepath
      File.join(Aro::Db.base_aro_dir, Aro::Db::CONFIG_FILE)
    end

    def self.get_name_from_namefile
      Aro::Mancy.is_aro_space? ? File.read(Aro::Mancy::NAME_FILE.to_s).strip : nil
    end

    def setup_local_aro
      name = Aro::Db.get_name_from_namefile
      return if name.nil?

      # create local .aro/ directory
      FileUtils.mkdir(Aro::Db.base_aro_dir) unless File.exist?(Aro::Db.base_aro_dir)

      # create database config yaml file
      c = {
        adapter: :sqlite3.to_s,
        database: File.join(Aro::Db.base_aro_dir, Aro::Db::SQL_FILE),
        username: name,
        password: name
      }.to_yaml
      File.open(db_config_filepath, "w") do |file|
        file.write(c)
      end

      connect(name)
      migrate(name)
    end

    def migrate(name)
      local_migrate_dir = File.join(Aro::Db.base_aro_dir, Aro::Db::MIGRATIONS_DIR)
      unless Dir.exist?(local_migrate_dir)
        gem_dir = Dir[Gem.loaded_specs[:aro.to_s]&.full_gem_path || '.'].first
        FileUtils.cp_r(File.join(gem_dir, "db"), Aro::Db::base_aro_dir)
      end

      migration_version = Dir["#{local_migrate_dir}/*.rb"].map{|n|
        Pathname.new(n).basename.to_s.split("_")[0].to_i
      }.max
      ActiveRecord::MigrationContext.new(local_migrate_dir).migrate(migration_version)
      require 'active_record/schema_dumper'
      filename = File.join(Aro::Db.base_aro_dir, Aro::Db::SCHEMA_FILE)
      File.open(filename, "w+") do |f|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection_pool, f)
      end
    end
  end
end
