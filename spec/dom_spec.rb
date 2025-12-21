require_relative :rspec_helper.to_s

describe Aro::Dom do
  before :all do
    Aro::Dom.create(Aro::Dom::ARODOME.to_s)
  end

  after :all do
    Aro::Dom.instance.eg_path = nil
    FileUtils.rm_rf(Aro::Dom::ARODOME.to_s)
  end

  context "new" do

    # it "should fail if Aro::Dom.in_arodom?" do

    # end

    it "should create an empty arodome" do
      expect(Dir.exist?(Aro::Dom::ARODOME.to_s)).to be(true)

      ether_file_path = File.join(Aro::Dom::ARODOME.to_s, Aro::Dom::ETHER_FILE.to_s)
      expect(Dir.exist?(ether_file_path)).to be(true)

      name_file_path = File.join(ether_file_path, Aro::Mancy::NAME_FILE.to_s)
      expect(File.exist?(name_file_path)).to be(true)
    end

    it "should generate the arodome" do
      Dir.chdir(Aro::Dom::ARODOME.to_s) do
        # todo: further testing in the arodome
        # Aos::Cor.set_ivar(:ENV, :test.to_s)
        expect(Aro::Dom.is_initialized?).to be(false)
        Aro::Dom::D::LAYOUT.values.each{|wing|
          expect(Dir.exist?(wing[:name].to_s)).to be(false)
        }
        Aro::Dom.instance.generate(:test, :user)
        expect(Aro::Dom.is_initialized?).to be(true)
        Aro::Dom::D::LAYOUT.values.each{|wing|
          expect(Dir.exist?(wing[:name].to_s)).to be(true)
        }

      end
    end

  end
end
