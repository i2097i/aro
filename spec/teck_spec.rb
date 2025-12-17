require_relative :rspec_helper.to_s

describe Aro::Teck do
  before :all do
    name = TESTING_NAME.to_s
    Aro::Mancy.create(name)
    Dir.chdir(name)
    Aro::Teck.make(TESTING_TECK.to_s)
  end

  after :all do
    Dir.chdir("..")
    FileUtils.rm_rf(TESTING_NAME.to_s)
  end

  context "teck" do

    it "should :CREATE" do
      expect(Aro::Teck.count).to eq Aro::Mancy::S
      expect(Aro::Teck.current_teck&.name).to eq TESTING_TECK.to_s
    end

    it "should :SHOW" do
      teck = Aro::Teck.current_teck
      tlog_count = Aro::Mancy::S

      # new teck should only have 1 record
      expect(teck.show.count).to eq(tlog_count)
      # should only return 1 record since this is newly created teck
      expect(teck.show(count_n: Aro::Mancy::OS).count).to eq(tlog_count)

      teck.shuffle # generate another log record
      tlog_count += Aro::Mancy::S

      # should return both
      expect(teck.show(count_n: tlog_count).count).to eq(tlog_count)
      # should still default to 1

      expect(teck.show.count).to eq(Aro::Mancy::S)
      # should return all
      expect(teck.show(count_n: Aro::Mancy::ALL).count).to eq(tlog_count)

      teck.shuffle # generate another log record
      tlog_count += Aro::Mancy::S

      # should return all
      expect(teck.show(count_n: Aro::Mancy::ALL).count).to eq(tlog_count)

      # should return default if count_n is invalid
      [:invalid_count,-Aro::Mancy::S,[],{},true].each {|i|
        expect(teck.show(count_n: i).count).to eq(Aro::Mancy::S)
      }

      # should display in desc order (default)
      desc = teck.show(count_n: Aro::Mancy::ALL)
      expect(desc.first.created_at > desc.last.created_at)

      # should display in asc order
      desc = teck.show(count_n: Aro::Mancy::ALL, order_o: Aro::Tlog::ORDERING[:ASC])

      expect(desc.first.created_at < desc.last.created_at)
    end

    it "should :DRAW" do
      teck = Aro::Teck.current_teck
      expect(teck.drawn).to eq("")
      teck.draw(
        is_dt_dimension: true,
        z_max: Aro::Mancy::NUMERALS[:VII],
        z: Aro::Mancy::S
      )
      expect(teck.drawn.split(Aro::Teck::CARD_DELIM.to_s).count).to be Aro::Mancy::S
    end

    # it "should :EXPLORE" do
    #   todo: after different formats are complete
    # end

    it "should :REPLACE" do
      teck = Aro::Teck.current_teck
      expect(teck.drawn.split(Aro::Teck::CARD_DELIM.to_s).count).to be Aro::Mancy::S
      teck.replace
      expect(teck.drawn).to eq ""
    end

    it "should :RESET" do
      teck = Aro::Teck.current_teck
      teck.reset
      expect(
        teck.cards
      ).to eq Aro::Teck.fresh_cards
      expect(teck.drawn).to eq ""
    end

    it "should :SHUFFLE" do
      teck = Aro::Teck.current_teck
      cards_before = teck.cards
      teck.shuffle
      expect(
        teck.reload.cards
      ).not_to eq cards_before
    end

  end
end