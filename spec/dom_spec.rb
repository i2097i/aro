require_relative :rspec_helper.to_s

describe Aro::Dom do
  # before :all do
  #   Aro::Dom.create(Aro::Dom::ARO_DOM.to_s)
  # end

  # after :all do
  #   Aro::Dom.instance.eg_path = nil
  #   FileUtils.rm_rf(Aro::Dom::ARO_DOM.to_s)
  # end

  # context "new" do

  #   it "should create an empty aro dom" do
  #     expect(Dir.exist?(Aro::Dom::ARO_DOM.to_s)).to be(true)

  #     ether_file_path = File.join(Aro::Dom::ARO_DOM.to_s, Aro::Dom::ETHER_FILE.to_s)
  #     expect(Dir.exist?(ether_file_path)).to be(true)

  #     name_file_path = File.join(ether_file_path, Aro::Mancy::NAME_FILE.to_s)
  #     expect(File.exist?(name_file_path)).to be(true)
  #   end

  #   it "should generate the aro dom" do
  #     Dir.chdir(Aro::Dom::ARO_DOM.to_s) do
  #       # todo: further testing in the aro dom
  #       # Aro::Cor.set_ivar(:ENV, :test.to_s)
  #       expect(Aro::Dom.is_initialized?).to be(false)
  #       Aro::Dom::D::LAYOUT.values.each{|wing|
  #         expect(Dir.exist?(wing[:name].to_s)).to be(false)
  #       }
  #       Aro::Dom.instance.generate
  #       expect(Aro::Dom.is_initialized?).to be(true)
  #       Aro::Dom::D::LAYOUT.values.each{|wing|
  #         expect(Dir.exist?(wing[:name].to_s)).to be(true)
  #       }

  #     end
  #   end

  # end
end
