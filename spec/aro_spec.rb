require_relative :rspec_helper.to_s

describe Aro do
  NAME = :success

  after :each do
    rmrf(NAME.to_s)
  end

  context "create" do
    it 'should fail if name is empty' do
      expect { Aro::Create.new }.to raise_error(StandardError)
    end

    it 'should fail if name is not a string' do
      expect { Aro::Create.new(0) }.to raise_error(StandardError)
    end

    it 'should create local .aro directory files' do
      name = NAME.to_s
      Aro::Create.new(name)
      expect(File.exist?(name)).to be true

      base_path = "#{Aro::Database.is_aro_dir? ? "." : name}/#{Aro::DIRS[:ARO].call}"
      expect(File.exist?(base_path)).to be true
      expect(File.exist?("#{base_path}/#{Aro::Database::CONFIG_FILE}")).to be true
      expect(File.exist?("#{base_path}/#{Aro::Database::SQL_FILE}")).to be true
      expect(File.exist?("#{base_path}/#{Aro::Database::SCHEMA_FILE}")).to be true
    end
  end

  context "database" do
    it 'should fail to set up connection if not in an aro directory' do
      expect { Aro::Database.new }.to raise_error(StandardError)
    end

    it 'should create new database' do
      name = NAME.to_s
      a = Aro::Create.new(name)
      expect(ActiveRecord::Base.connection.database_exists?).to be true
    end
  end
end
