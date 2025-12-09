=begin

  deck.rb

  deck object.

  by i2097i

=end

require :base64.to_s
require_relative :"../shr/t".to_s

class Aro::Deck < ActiveRecord::Base
  has_many :logs

  DECK_FILE = :".deck"
  CARD_DELIM = :","

  before_create :populate_cards
  after_commit :generate_log

  def self.make(new_name)
    return nil unless Aro::Mancy.is_initialized?
    Aro::Db.new
    new_deck = Aro::Deck.create(name: new_name)
    if Aro::Deck.current_deck.nil?
      File.open(Aro::Deck::DECK_FILE.to_s, "w") do |file|
        file.write(new_deck.id)
      end
    end
    new_deck
  end

  def self.fresh_cards
    I18n.t("cards.index").map{|c| "+#{c}"}.join(Aro::Deck::CARD_DELIM.to_s)
  end

  def populate_cards
    self.cards = Aro::Deck.fresh_cards
  end

  def generate_log
    prev_cards = Base64::decode64(logs.last.card_data) if logs.any?
    if (prev_cards.present? && prev_cards != cards) || (prev_cards.nil? || prev_cards.empty?)
      logs.create(
        card_data: Base64::encode64(cards || ""),
        drawn_data: Base64::encode64(drawn || "")
      )
    end
  end

  def self.display_selection_menu
    unless Aro::Deck.any?
      Aro::P.say(I18n.t("cli.messages.no_decks"))
      exit(CLI::EXIT_CODES[:SUCCESS])
    end

    selection = Aro::P.p.select("choose a deck:") do |menu|
      Aro::Deck.all.each{|d|
        if d.id == Aro::Deck.current_deck&.id
          menu.default d.id
        end
        menu.choice(d.name, d.id)
      }
    end
    File.open(Aro::Deck::DECK_FILE.to_s, "w") do |file|
      file.write(selection)
    end
  end

  def self.current_deck
    if File.exist?(DECK_FILE.to_s)
      current_deck_id = File.read(DECK_FILE.to_s)
      return Aro::Deck.find_by(id: current_deck_id)
    end
  end

  def self.card_strip(card)
    card.gsub(/[+-]/, "").strip
  end

  def show(count_n: Aro::Mancy::S, order_o: Aro::Log::ORDERING[:DESC])
    unless count_n.kind_of?(Numeric) && count_n.to_i > Aro::Mancy::O
      if count_n&.to_s&.to_sym == Aro::Mancy::ALL
        count_n = logs.count
      else
        count_n = Aro::Mancy::S
      end
    end
    count_n = [[Aro::Mancy::S, count_n.to_i].max, logs.count].min
    Aro::V.say("count_n: #{count_n}")
    Aro::V.say("order_o: #{order_o}")

    unless Aro::Log::ORDERING.values.include?(order_o)
      Aro::P.say(I18n.t("cli.warnings.invalid_order"))
      order_o = Aro::Log::ORDERING[:DESC]
    end

    # perform query
    h_logs = logs.order(created_at: order_o).first(count_n)

    # todo: this is doing more work than it needs to. needs debugging.
    # Aro::V.say("h_logs.count: #{h_logs.count}")

    # for now tests just expect text output
    return h_logs if CLI::Config.is_test?

    Aro::D.say(I18n.t("cli.messages.showing", name: name, count: count_n, order: order_o))

    Aos::Vi::Game.show_game({
      deck: self,
      h_logs: h_logs,
      count_n: count_n,
      order_o: order_o
    })
  end

  def explore
    # allows user to browse each card in the current deck.
    answer = Aro::P.p.select(
      I18n.t("cli.messages.choose_card"),
      # formatted for tty-prompt gem
      cards.split(Aro::Deck::CARD_DELIM.to_s).map{|c| [I18n.t("cards.#{Aro::Deck.card_strip(c)}.name"), c]}.to_h,
      per_page: Aro::Mancy::NUMERALS[:VII],
      cycle: true,
      default: Aro::Mancy::S
    )

    Aro::P.say(I18n.t("cards.#{Aro::Deck.card_strip(answer)}"))
  end

  def shuffle
    # shuffles the current deck and generates a log record.
    update(cards: cards.split(Aro::Deck::CARD_DELIM.to_s).shuffle.join(Aro::Deck::CARD_DELIM.to_s))
  end

  def reset
    # completely reset the deck. replace all drawn and reset order.
    # all orientations will be set to upright.
    update(cards: Aro::Deck.fresh_cards, drawn: "")
  end

  def replace
    # replaces all drawn cards FIFO and puts them on the bottom of
    # the deck. this will preserve all card orientations.
    cards_arr = cards.split(Aro::Deck::CARD_DELIM.to_s) || []
    drawn_arr = drawn&.split(Aro::Deck::CARD_DELIM.to_s) || []

    # append each drawn card to cards
    drawn_arr.each{|dc| cards_arr << dc }

    # clear drawn
    update(drawn: "", cards: cards_arr.join(Aro::Deck::CARD_DELIM.to_s))
  end

  def draw(is_dt_dimension: true, z_max: 7, z: 1)
    # the true card
    abs_dev_tarot = nil

    # oriented card
    dev_tarot = nil

    # get cards
    cards_arr = cards.split(Aro::Deck::CARD_DELIM.to_s) || []
    # get abs_cards
    abs_cards_arr = cards_arr.map{|c| Aro::Deck.card_strip(c)}
    # get drawn
    drawn_arr = drawn&.split(Aro::Deck::CARD_DELIM.to_s) || []

    if cards_arr.empty?
      Aro::P.say("there are no cards left to draw.")
      return
    end
    sleeps = 0
    sleeps_max = z_max

    # find a card that is not already drawn
    while sleeps <= sleeps_max && dev_tarot.nil? do
      # use fallback randomness if /dev/tarot unavailable
      if !is_dt_dimension || !File.exist?(Aro::T::DEV_TAROT_FILE.to_s)
        dev_tarot = Aro::T.summon_ruby_facot.split("")
      else
        # preferred randomness
        read_value = Aro::T.read_dev_tarot&.strip&.split("")
        if read_value.count >= Aro::Mancy::N - 1
          dev_tarot = read_value
        end
      end
      
      unless dev_tarot.nil?
        abs_dev_tarot = dev_tarot[Aro::Mancy::S] + Aro::Mancy::NUMERALS.key(
          dev_tarot.join("")[Aro::Mancy::OS..].to_i
        ).to_s
        if abs_cards_arr.include?(abs_dev_tarot)
          # dev_tarot is valid
          dev_tarot = dev_tarot[Aro::Mancy::O] + abs_dev_tarot
        else
          dev_tarot = nil
        end
      end

      if dev_tarot.nil?
        # dev_tarot is invalid
        sleeps += 1
        sleep(z.to_i)
      end
    end

    # remove from cards
    cards_arr.delete(cards_arr.select{|c| c.include?(abs_dev_tarot)}.first)

    # insert dev_tarot to drawn
    drawn_arr << dev_tarot

    # update database 
    update(
      cards: cards_arr.join(Aro::Deck::CARD_DELIM.to_s),
      drawn: drawn_arr.join(Aro::Deck::CARD_DELIM.to_s)
    )
  end
end
