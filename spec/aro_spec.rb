require_relative :rspec_helper.to_s

describe Aro do
  after :each do
    FileUtils.rm_rf(TESTING_NAME.to_s)
  end

  context "create" do
    it "should fail if name type is invalid: [0, [], {}, nil, true]" do
      [0, [], {}, nil, true].each {|i|
        expect(Aro::Mancy::create(i)).to be(false)
      }
    end

    it "should create local .aro directory files" do
      name = TESTING_NAME.to_s
      Aro::Mancy::create(name)
      Dir.chdir(name) do
        Aro::Db.new
        base_path = Aro::Db.base_aro_dir
        expect(Dir.exist?(base_path)).to be true
        expect(File.exist?(File.join(Aro::Db.base_aro_dir, Aro::Db::CONFIG_FILE))).to be true
        expect(File.exist?(File.join(Aro::Db.base_aro_dir, Aro::Db::SQL_FILE))).to be true
        expect(File.exist?(File.join(Aro::Db.base_aro_dir, Aro::Db::SCHEMA_FILE))).to be true
      end
    end
  end

  context "database" do
    it "should fail to set up connection if not in an aro directory" do
      expect { Aro::Db.new }.to raise_error(StandardError)
    end

    it "should create new database" do
      name = TESTING_NAME.to_s
      Aro::Mancy::create(name)
      Dir.chdir(TESTING_NAME.to_s) do
        Aro::Db.new
        expect(ActiveRecord::Base.connection.database_exists?).to be true
      end
    end
  end
end
