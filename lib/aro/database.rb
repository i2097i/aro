require :active_record.to_s
require :base64.to_s
require :yaml.to_s

module Aro
  class Database
    CONFIG_FILE = "database.yml"
    SQL_FILE = "database.sql"
    SCHEMA_FILE = "schema.rb"
    MIGRATIONS_DIR = "db/migrate"
    NAME_FILE = ".name"

    def initialize(name = nil)
      # show queries in stout
      ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV[:ARO_ENV.to_s] != :production.to_s

      # generate .name file
      if name.nil? && is_aro_dir?
        # pwd is in aro directory, use name file
        name = get_name_from_namefile
      elsif !name.nil? && !Database.is_aro_dir?
        # first use, pwd is not in aro directory yet
        echo_cmd = "echo #{name} >> #{name}/#{NAME_FILE}"
        Aro::P.p.say(echo_cmd)
        system(echo_cmd)
      end

      if name.nil?
        # if name is still nil, need to use create to generate aro directory
        raise "invalid aro directory. use `aro create` to generate one"
      end

      setup_local_aro(name)
    end

    def connect(name)
      ActiveRecord::Base.establish_connection(config(name))
    end

    def config(name = nil)
      @config ||= YAML.load_file(db_config_filepath(name))
    end

    def base_aro_dir(name)
      "#{Database.is_aro_dir? ? "." : name}/#{Aro::DIRS[:ARO].call}"
    end

    def db_config_filepath(name)
      "#{base_aro_dir(name)}/#{CONFIG_FILE}"
    end

    def db_filepath(name)
      "#{base_aro_dir(name)}/#{SQL_FILE}"
    end

    def self.is_aro_dir?
      File.exist?(NAME_FILE)
    end

    def self.get_name_from_namefile
      Database.is_aro_dir? ? File.read(NAME_FILE).strip : nil
    end

    def setup_local_aro(name = nil, force = false)
      # create local .aro/ directory
      unless File.exist?(base_aro_dir(name)) || force
        if File.exist?(base_aro_dir(name)) && force
          rm_cmd = "rm -rf #{base_aro_dir(name)}"
          Aro::P.p.say(rm_cmd)
          system(rm_cmd)
        end

        mk_cmd = "mkdir #{base_aro_dir(name)}"
        Aro::P.p.say(mk_cmd)
        system(mk_cmd)
      end

      # create database config yaml file
      c = {
        adapter: :sqlite3.to_s,
        database: "#{Database.is_aro_dir? ? "." : name}/#{Aro::DIRS[:ARO].call}/#{SQL_FILE}",
        username: name,
        password: name
      }.to_yaml
      File.open(db_config_filepath(name), "w") do |file|
        file.write(c)
      end

      connect(name)
      setup(name)
    end

    def setup(name)
      local_migrate_dir = "#{base_aro_dir(name)}/#{MIGRATIONS_DIR}"
      unless Dir.exist?(local_migrate_dir)
        gem_dir = Dir[Gem.loaded_specs[:aro.to_s]&.full_gem_path || '.'].first
        cp_cmd = "cp -R #{gem_dir}/db #{base_aro_dir(name)}"
        Aro::P.p.say(cp_cmd)
        system(cp_cmd)
      end

      migration_version = Dir["#{local_migrate_dir}/*.rb"].map{|n|
        Pathname.new(n).basename.to_s.split("_")[0].to_i
      }.max
      ActiveRecord::MigrationContext.new(local_migrate_dir).migrate(migration_version)
      require 'active_record/schema_dumper'
      filename = "#{base_aro_dir(name)}/#{SCHEMA_FILE}"
      File.open(filename, "w+") do |f|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection_pool, f)
      end
    end
  end
end
