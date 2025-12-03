require_relative :rspec_helper.to_s

describe Aro do
  after :each do
    rmrf(TESTING_NAME.to_s)
  end

  context "create" do
    it "should fail if name type is invalid: [0, [], {}, nil, true]" do
      expect{Aro::Create.new}.to raise_error(ArgumentError)
      [0, [], {}, nil, true].each {|i|
        c = Aro::Create.new(i)
        # puts("testing invalid name: #{i.class}")
        expect(c.initialized).to be(false)
      }
    end

    it "should create local .aro directory files" do
      name = TESTING_NAME.to_s
      c = Aro::Create.new(name)
      expect(c.initialized).to be(true)
      expect(Dir.exist?(name)).to be true
      base_path = "#{Aro::Db.base_aro_dir(name)}"
      # puts "base_path: #{base_path}"
      expect(Dir.exist?(base_path)).to be true
      # puts Dir["#{base_path}/*"]
      expect(File.exist?("#{base_path}/#{Aro::Db::CONFIG_FILE}")).to be true
      expect(File.exist?("#{base_path}/#{Aro::Db::SQL_FILE}")).to be true
      expect(File.exist?("#{base_path}/#{Aro::Db::SCHEMA_FILE}")).to be true
    end
  end

  context "database" do
    it "should fail to set up connection if not in an aro directory" do
      expect { Aro::Db.new }.to raise_error(StandardError)
    end

    it "should create new database" do
      name = TESTING_NAME.to_s
      a = Aro::Create.new(name)
      expect(ActiveRecord::Base.connection.database_exists?).to be true
    end
  end
end
