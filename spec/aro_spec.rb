require_relative :rspec_helper.to_s

describe Aro do
  after :each do
    FileUtils.rm_rf(TESTING_NAME.to_s)
  end

  context "create" do
    it "should fail if name type is invalid: [{}, nil, true]" do
      [{}, nil, true].each {|i|
        expect(Aro::Mancy.create(i)).to be(false)
      }
    end

    it "should create local .aro directory files" do
      Aro::Mancy.create(TESTING_NAME.to_s)
      Dir.chdir(TESTING_NAME.to_s) do
        Aos::Cor.set_ivar(:ENV, Aos::Cor::ENVS[:TEST].to_s)
        base_path = Aro::Db.base_aro_dir
        expect(Dir.exist?(base_path)).to be true
        expect(File.exist?(File.join(Aro::Db.base_aro_dir, Aro::Db::DATABASE_YML.to_s))).to be true
        expect(File.exist?(File.join(Aro::Db.base_aro_dir, Aro::Db::SQL_FILE.to_s))).to be true
        expect(File.exist?(File.join(Aro::Db.base_aro_dir, Aro::Db::SCHEMA_FILE.to_s))).to be true
      end
    end
  end

  context "database" do
    it "should create new database" do
      if Aro::Mancy.create(TESTING_NAME.to_s)
        Dir.chdir(TESTING_NAME.to_s) do
          Aos::Cor.set_ivar(:ENV, Aos::Cor::ENVS[:TEST].to_s)
          expect(ActiveRecord::Base.connection.database_exists?).to be true
        end
      end
    end
  end
end
