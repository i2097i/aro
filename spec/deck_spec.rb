require_relative :rspec_helper.to_s

describe Aro::Deck do
  before :all do
    name = TESTING_NAME.to_s
    Aro::Create.new(name)
    Dir.chdir(name) do
      Aro::Deck.make(TESTING_DECK.to_s)
    end
  end

  after :all do
    rmrf(TESTING_NAME.to_s)
  end

  context "deck" do

    it "should :CREATE" do
      Dir.chdir(TESTING_NAME.to_s) do
        expect(Aro::Deck.count).to eq 1
        expect(Aro::Deck.current_deck&.name).to eq TESTING_DECK.to_s
      end
    end

    it "should :SHOW" do
      Dir.chdir(TESTING_NAME.to_s) do
        deck = Aro::Deck.current_deck
        log_count = 1

        # new seck should only have 1 record
        expect(deck.show.count).to eq(log_count)
        # should only return 1 record since this is newly created deck
        expect(deck.show(count_n: 2).count).to eq(log_count)
        
        deck.shuffle # generate another log record
        log_count += 1
        
        # should return both
        expect(deck.show(count_n: log_count).count).to eq(log_count)
        # should still default to 1
        expect(deck.show.count).to eq(1)
        # should return all
        expect(deck.show(count_n: Aro::Log::ALL).count).to eq(log_count)

        deck.shuffle # generate another log record
        log_count += 1

        # should return all
        expect(deck.show(count_n: Aro::Log::ALL).count).to eq(log_count)

        # should return default if count_n is invalid
        [:invalid_count,-1,[],{},true].each {|i|
          expect(deck.show(count_n: i).count).to eq(1)
        }

        # should display in desc order (default)
        desc = deck.show(count_n: Aro::Log::ALL)
        expect(desc.first.created_at > desc.last.created_at)

        # should display in asc order
        desc = deck.show(count_n: Aro::Log::ALL, order_o: Aro::Log::ORDERING[:ASC])
        expect(desc.first.created_at < desc.last.created_at)
      end
    end

    it "should :DRAW" do
      Dir.chdir(TESTING_NAME.to_s) do
        deck = Aro::Deck.current_deck
        expect(deck.drawn).to be nil
        deck.draw
        expect(deck.drawn.split(Aro::Deck::CARD_DELIM).count).to be 1
      end
    end

    # it "should :EXPLORE" do
    #   todo: after different formats are complete
    # end

    it "should :REPLACE" do
      Dir.chdir(TESTING_NAME.to_s) do
        deck = Aro::Deck.current_deck
        expect(deck.drawn.split(Aro::Deck::CARD_DELIM).count).to be 1
        deck.replace
        expect(deck.drawn).to eq ""
      end
    end

    it "should :RESET" do
      Dir.chdir(TESTING_NAME.to_s) do
        deck = Aro::Deck.current_deck
        deck.reset
        expect(
          deck.cards
        ).to eq Aro::Deck.fresh_cards
        expect(deck.drawn).to eq ""
      end
    end

    it "should :SHUFFLE" do
      Dir.chdir(TESTING_NAME.to_s) do
        deck = Aro::Deck.current_deck
        cards_before = deck.cards
        deck.shuffle
        expect(
          deck.reload.cards
        ).not_to eq cards_before
      end
    end

  end
end