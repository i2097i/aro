require_relative :rspec_helper.to_s

describe Aro::Deck do
  before :all do
    name = TESTING_NAME.to_s
    Aro::Mancy.create(name)
    Dir.chdir(name)
    Aro::Deck.make(TESTING_DECK.to_s)
  end

  after :all do
    Dir.chdir("..")
    FileUtils.rm_rf(TESTING_NAME.to_s)
  end

  context "deck" do

    it "should :CREATE" do
      expect(Aro::Deck.count).to eq Aro::Mancy::S
      expect(Aro::Deck.current_deck&.name).to eq TESTING_DECK.to_s
    end

    it "should :SHOW" do
      deck = Aro::Deck.current_deck
      log_count = Aro::Mancy::S

      # new deck should only have 1 record
      expect(deck.show.count).to eq(log_count)
      # should only return 1 record since this is newly created deck
      expect(deck.show(count_n: Aro::Mancy::OS).count).to eq(log_count)

      deck.shuffle # generate another log record
      log_count += Aro::Mancy::S

      # should return both
      expect(deck.show(count_n: log_count).count).to eq(log_count)
      # should still default to 1

      expect(deck.show.count).to eq(Aro::Mancy::S)
      # should return all
      expect(deck.show(count_n: Aro::Mancy::ALL).count).to eq(log_count)

      deck.shuffle # generate another log record
      log_count += Aro::Mancy::S

      # should return all
      expect(deck.show(count_n: Aro::Mancy::ALL).count).to eq(log_count)

      # should return default if count_n is invalid
      [:invalid_count,-Aro::Mancy::S,[],{},true].each {|i|
        expect(deck.show(count_n: i).count).to eq(Aro::Mancy::S)
      }

      # should display in desc order (default)
      desc = deck.show(count_n: Aro::Mancy::ALL)
      expect(desc.first.created_at > desc.last.created_at)

      # should display in asc order
      desc = deck.show(count_n: Aro::Mancy::ALL, order_o: Aro::Log::ORDERING[:ASC])

      expect(desc.first.created_at < desc.last.created_at)
    end

    it "should :DRAW" do
      deck = Aro::Deck.current_deck
      expect(deck.drawn).to eq("")
      deck.draw(
        is_dt_dimension: true,
        z_max: Aro::Mancy::NUMERALS[:VII],
        z: Aro::Mancy::S
      )
      expect(deck.drawn.split(Aro::Deck::CARD_DELIM.to_s).count).to be Aro::Mancy::S
    end

    # it "should :EXPLORE" do
    #   todo: after different formats are complete
    # end

    it "should :REPLACE" do
      deck = Aro::Deck.current_deck
      expect(deck.drawn.split(Aro::Deck::CARD_DELIM.to_s).count).to be Aro::Mancy::S
      deck.replace
      expect(deck.drawn).to eq ""
    end

    it "should :RESET" do
      deck = Aro::Deck.current_deck
      deck.reset
      expect(
        deck.cards
      ).to eq Aro::Deck.fresh_cards
      expect(deck.drawn).to eq ""
    end

    it "should :SHUFFLE" do
      deck = Aro::Deck.current_deck
      cards_before = deck.cards
      deck.shuffle
      expect(
        deck.reload.cards
      ).not_to eq cards_before
    end

  end
end