require_relative :rspec_helper.to_s

describe Aro::Dom do
  before :all do
    Aro::Dom.create(TESTING_NAME.to_s)
  end

  after :all do
    FileUtils.rm_rf(TESTING_NAME.to_s)
  end

  context "new" do

    # it "should fail if Aro::Dom.in_arodom?" do

    # end

    it "should create an empty arodome" do
      expect(Dir.exist?(TESTING_NAME.to_s)).to be(true)

      ether_file_path = File.join(TESTING_NAME.to_s, Aro::Dom::ETHER_FILE.to_s)
      expect(Dir.exist?(ether_file_path)).to be(true)

      name_file_path = File.join(ether_file_path, Aro::Mancy::NAME_FILE.to_s)
      expect(File.exist?(name_file_path)).to be(true)
    end

    it "should generate the arodome" do
      Dir.chdir(TESTING_NAME.to_s) do
        Aro::Dom::D::LAYOUT.values.each{|wing|
          expect(Dir.exist?(wing[:name].to_s)).to be(false)
        }
        Aro::Dom.new.generate(:test, :user)
        Aro::Dom::D::LAYOUT.values.each{|wing|
          expect(Dir.exist?(wing[:name].to_s)).to be(true)
        }
      end
    end

  end
end
