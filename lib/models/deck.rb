require :base64.to_s
require_relative :"./log".to_s

class Aro::Deck < ActiveRecord::Base
  has_many :logs

  DECK_FILE = ".deck"
  CARD_DELIM = ","
  DEV_TAROT_FILE = "/dev/tarot"

  # update this for # of cards you will draw
  DRAW_COUNT = 7
  
  # do not modify
  DISPLAY_WIDTH = Aro::Deck::DRAW_COUNT*Aro::Deck::DRAW_COUNT
  HISTORY_SEPARATOR = "#{"-" * Aro::Deck::DISPLAY_WIDTH}"
  
  # change to update how timestamps appear
  DATE_FORMAT = "%Y:%m:%d:%H:%M:%S"

  before_create :populate_cards
  after_commit :generate_log

  def self.make(new_name)
    Aro::Create.new(new_name)
    new_deck = Aro::Deck.create(name: new_name)
    if Aro::Deck.current_deck.nil?
      File.open(Aro::Deck::DECK_FILE, "w") do |file|
        file.write(new_deck.id)
      end
    end
    new_deck
  end

  def self.fresh_cards
    I18n.t("cards.index").map{|c| "+#{c}"}.join(Aro::Deck::CARD_DELIM)
  end

  def populate_cards
    self.cards = Aro::Deck.fresh_cards
  end

  def generate_log
    prev_cards = Base64::decode64(logs.last.card_data) if logs.any?
    if prev_cards.present? && prev_cards != cards || prev_cards.nil?
      logs.create(
        card_data: Base64::encode64(cards),
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
    File.open(Aro::Deck::DECK_FILE, "w") do |file|
      file.write(selection)
    end
  end

  def self.current_deck
    if File.exist?(DECK_FILE)
      current_deck_id = File.read(DECK_FILE)
      return Aro::Deck.find_by(id: current_deck_id)
    end
  end

  def self.read_dev_tarot
    dt = nil
    return dt unless File.exist?(Aro::Deck::DEV_TAROT_FILE)

    File.open(Aro::Deck::DEV_TAROT_FILE, "r"){|dtf| dt = dtf.read(4)}
  end

  def self.card_strip(card)
    card.gsub(/[+-]/, "").strip
  end

  def show(count_n: Aro::Log::DEFAULT_COUNT, order_o: Aro::Log::ORDERING[:DESC])
    unless count_n.kind_of?(Numeric) && count_n > 0
      if count_n&.to_s&.downcase&.to_sym == Aro::Log::ALL
        count_n = logs.count
      else
        count_n = Aro::Log::DEFAULT_COUNT
      end
    end
    count_n = [count_n.to_i, logs.count].min

    unless Aro::Log::ORDERING.include?(order_o&.to_s&.upcase&.to_sym)
      Aro::P.say(I18n.t("cli.warnings.invalid_order"))
      order_o = Aro::Log::ORDERING[:DESC]
    end

    # perform query
    h_logs = logs.order(created_at: order_o.to_s.downcase).first(count_n)

    # for now tests just expect text output
    return h_logs if Aro::IS_TEST.call

    Aro::P.say(I18n.t("cli.messages.showing", name: name, count: count_n, order: order_o))
    
    h_text = "\n"
    h_text += Aro::Deck::HISTORY_SEPARATOR + "\n\n"
    h_text += "#{name.upcase.center(Aro::Deck::DISPLAY_WIDTH)}\n\n"
    h_logs.each_with_index{|l, i|
      h_text += Aro::Deck::HISTORY_SEPARATOR + "\n"
      h_text += l.created_at.strftime(Aro::Deck::DATE_FORMAT).center(Aro::Deck::DISPLAY_WIDTH) + "\n"
      h_text += "#{order_o.to_sym == Aro::Log::ORDERING[:DESC] ? logs.count - i : 1 + i} of #{logs.count}".rjust(Aro::Deck::DISPLAY_WIDTH) + "\n"
      h_text += Aro::Deck::HISTORY_SEPARATOR + "\n\n"
      h_text += get_display_for_cards(
        Base64::decode64(l.card_data).split(Aro::Deck::CARD_DELIM)
      )
      h_text += Aro::Deck::HISTORY_SEPARATOR + "\n"
      
      drawn_cards = Base64::decode64(l.drawn_data).split(Aro::Deck::CARD_DELIM)

      if !drawn_cards.nil? && drawn_cards.any?
        h_text += I18n.t("cli.messages.history_drawn").center(Aro::Deck::DISPLAY_WIDTH) + "\n"
        h_text += Aro::Deck::HISTORY_SEPARATOR + "\n\n"
        h_text += get_display_for_cards(
          drawn_cards
        )
        h_text += "\n"
        h_text += Aro::Deck::HISTORY_SEPARATOR + "\n"
      end

      3.times do
        h_text += Aro::Deck::HISTORY_SEPARATOR + "\n"
      end
    }

    if count_n == Aro::Log::DEFAULT_COUNT
      Aro::P.say(h_text)
    else
      Aro::P.less(h_text)
    end
  end

  def get_display_for_cards(input = []) # todo:, print_nums: false)
    result = ""
    input.each_with_index{|c, i|
      if i == I18n.t("cards.index").count - 1
        result += c.ljust(Aro::Deck::DISPLAY_WIDTH)
      else
        result += c.ljust(Aro::Deck::DRAW_COUNT) + ((i + 1) % Aro::Deck::DRAW_COUNT == 0 ? "\n" : "")
      end
    }
    result += "\n"
    result
  end

  def explore
    # allows user to browse each card in the current deck.
    answer = Aro::P.p.select(
      I18n.t("cli.messages.choose_card"),
      # formatted for tty-prompt gem
      cards.split(Aro::Deck::CARD_DELIM).map{|c| [I18n.t("cards.#{Aro::Deck.card_strip(c)}.name"), c]}.to_h,
      per_page: 7,
      cycle: true,
      default: 1
    )

    # TODO: display this nicer
    Aro::P.say(I18n.t("cards.#{Aro::Deck.card_strip(answer)}"))
  end

  def shuffle
    # shuffles the current deck and generates a log record.
    update(cards: cards.split(Aro::Deck::CARD_DELIM).shuffle.join(Aro::Deck::CARD_DELIM))
  end

  def reset
    # completely reset the deck. replace all drawn and reset order.
    # all orientations will be set to upright.
    update(cards: Aro::Deck.fresh_cards, drawn: "")
  end

  def replace
    # replaces all drawn cards FIFO and puts them on the bottom of
    # the deck. this will preserve all card orientations.
    cards_arr = cards.split(Aro::Deck::CARD_DELIM) || []
    drawn_arr = drawn&.split(Aro::Deck::CARD_DELIM) || []
    
    # append each drawn card to cards
    drawn_arr.each{|dc| cards_arr << dc }

    # clear drawn
    update(drawn: "", cards: cards_arr.join(Aro::Deck::CARD_DELIM))
  end

  def draw
    # draw a random card from the current deck.
    dev_tarot = nil

    # find a card that is not already drawn
    while dev_tarot.nil? do
      # preferred randomness
      dev_tarot = nil # Aro::Deck.read_dev_tarot&.strip&.split("")
      
      cards_arr = cards.split(Aro::Deck::CARD_DELIM) || []
      cards_arr_stripped = cards_arr.map{|c| Aro::Deck.card_strip(c)}

      if dev_tarot.nil?
        # assume user does not have /dev/tarot device.
        # generate random facade
        facade = cards_arr.sample.split("")
        dev_tarot = (
          facade.first(2).join("") + 
          Aro::NUMERALS[
            facade.select{|c| !facade.first(2).include?(c)}.join("").to_sym
          ].to_s
        ).split("")
      end

      dev_tarot_converted = dev_tarot[1] + Aro::NUMERALS.key(
        dev_tarot.select{|c| !dev_tarot.first(2).include?(c)}.join("").to_i
      ).to_s
      if cards_arr_stripped.include?(dev_tarot_converted)
        # dev_tarot is valid
        drawn_arr = drawn&.split(Aro::Deck::CARD_DELIM) || []
        dev_tarot = dev_tarot[0] + dev_tarot_converted
        drawn_arr << dev_tarot
        cards_arr.delete_at(cards_arr_stripped.index(dev_tarot_converted))
        update(
          cards: cards_arr.join(Aro::Deck::CARD_DELIM),
          drawn: drawn_arr.join(Aro::Deck::CARD_DELIM)
        )
      else
        # dev_tarot is invalid
        dev_tarot = nil
        sleep(1)
      end
    end
  end
end