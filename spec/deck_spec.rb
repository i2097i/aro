require_relative :rspec_helper.to_s

describe Aro::Deck do
  NAME = :success
  DECK = :test

  before :all do
    name = NAME.to_s
    Aro::Create.new(name)
    Dir.chdir(name) do
      Aro::Deck.make(DECK.to_s)
    end
  end

  after :all do
    rmrf(NAME.to_s)
  end

  context "deck" do

    it "should :CREATE" do
      Dir.chdir(NAME.to_s) do
        expect(Aro::Deck.count).to eq 1
        expect(Aro::Deck.current_deck&.name).to eq DECK.to_s
      end
    end

    it "should :SHOW" do
      Dir.chdir(NAME.to_s) do
        expect(Aro::Deck.current_deck.show.length).to be > 0
      end
    end

    it "should :DRAW" do
      Dir.chdir(NAME.to_s) do
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
      Dir.chdir(NAME.to_s) do
        deck = Aro::Deck.current_deck
        expect(deck.drawn.split(Aro::Deck::CARD_DELIM).count).to be 1
        deck.replace
        expect(deck.drawn).to eq ""
      end
    end

    it "should :RESET" do
      Dir.chdir(NAME.to_s) do
        deck = Aro::Deck.current_deck
        deck.reset
        expect(
          deck.cards
        ).to eq Aro::Deck.fresh_cards
        expect(deck.drawn).to eq ""
      end
    end

    it "should :SHUFFLE" do
      Dir.chdir(NAME.to_s) do
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