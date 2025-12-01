require :base64.to_s
require_relative :"./log".to_s

class Deck < ActiveRecord::Base
  has_many :logs

  DECK_FILE = ".deck"
  CARD_DELIM = ","
  DEV_TAROT_FILE = "/dev/tarot"

  CARD_WIDTH = 7
  DISPLAY_WIDTH = Deck::CARD_WIDTH*Deck::CARD_WIDTH
  HISTORY_SEPARATOR = "#{"-" * Deck::DISPLAY_WIDTH}"
  DATE_FORMAT = "%Y:%m:%d:%H:%M:%S"

  before_create :populate_cards
  after_commit :generate_log

  def self.fresh_cards
    I18n.t("cards.index").map{|c| "+#{c}"}.join(Deck::CARD_DELIM)
  end

  def populate_cards
    self.cards = Deck.fresh_cards
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
    unless Deck.any?
      Aro::P.p.say(I18n.t("cli.messages.no_decks"))
      exit(CLI::EXIT_CODES[:SUCCESS])
    end

    selection = Aro::P.p.select("choose a deck:") do |menu|
      Deck.all.each{|d|
        if d.id == Deck.current_deck&.id
          menu.default d.id
        end
        menu.choice(d.name, d.id)
      }
    end
    File.open(Deck::DECK_FILE, "w") do |file|
      file.write(selection)
    end
  end

  def self.current_deck
    if File.exist?(DECK_FILE)
      current_deck_id = File.read(DECK_FILE)
      return Deck.find_by(id: current_deck_id)
    end
  end

  def self.read_dev_tarot
    dt = nil
    return dt unless File.exist?(Deck::DEV_TAROT_FILE)

    File.open(Deck::DEV_TAROT_FILE, "r"){|dtf| dt = dtf.read(4)}
  end

  def self.card_strip(card)
    card.gsub(/[+-]/, "").strip
  end

  def history
    h_text = I18n.t("cli.messages.history_title", deck: name)
    h_text += "\n"
    h_text += Deck::HISTORY_SEPARATOR + "\n\n"
    h_text += "#{name.upcase.center(Deck::DISPLAY_WIDTH)}\n\n"
    logs.reverse.each_with_index{|l, i|
      h_text += Deck::HISTORY_SEPARATOR + "\n"
      h_text += l.created_at.strftime(Deck::DATE_FORMAT).center(Deck::DISPLAY_WIDTH) + "\n"
      h_text += "#{logs.count - i} of #{logs.count}".rjust(Deck::DISPLAY_WIDTH) + "\n"
      h_text += Deck::HISTORY_SEPARATOR + "\n\n"
      h_text += get_display_for_cards(
        Base64::decode64(l.card_data).split(Deck::CARD_DELIM)
      )
      h_text += Deck::HISTORY_SEPARATOR + "\n"
      
      drawn_cards = Base64::decode64(l.drawn_data).split(Deck::CARD_DELIM)

      if !drawn_cards.nil? && drawn_cards.any?
        h_text += I18n.t("cli.messages.history_drawn").center(Deck::DISPLAY_WIDTH) + "\n"
        h_text += Deck::HISTORY_SEPARATOR + "\n\n"
        h_text += get_display_for_cards(
          drawn_cards
        )
        h_text += "\n"
      end
    }
    Aro::P.less(h_text)
  end

  def get_display_for_cards(input = []) # todo:, print_nums: false)
    result = ""
    input.each_with_index{|c, i|
      if i == I18n.t("cards.index").count - 1
        result += c.ljust(Deck::DISPLAY_WIDTH)
      else
        result += c.ljust(Deck::CARD_WIDTH) + ((i + 1) % Deck::CARD_WIDTH == 0 ? "\n" : "")
      end
    }
    result += "\n"
    result
  end

  def explore
    answer = Aro::P.p.select(
      I18n.t("cli.messages.choose_card"),
      # formatted for tty-prompt gem
      cards.split(Deck::CARD_DELIM).map{|c| [I18n.t("cards.#{Deck.card_strip(c)}.name"), c]}.to_h,
      per_page: 7,
      cycle: true,
      default: 1
    )

    # TODO: display this nicer
    Aro::P.p.say(I18n.t("cards.#{Deck.card_strip(answer)}"))
  end

  def shuffle
    update(cards: cards.split(Deck::CARD_DELIM).shuffle.join(Deck::CARD_DELIM))
  end

  def reset
    update(cards: Deck.fresh_cards, drawn: "")
  end

  def draw
    dev_tarot = nil

    # find a card that is not already drawn
    while dev_tarot.nil? do
      dev_tarot = Deck.read_dev_tarot.strip.split("")
      cards_arr = cards.split(Deck::CARD_DELIM)
      cards_arr_stripped = cards_arr.map{|c| Deck.card_strip(c)}
      dev_tarot_converted = dev_tarot[1] + Aro::NUMERALS.key(
        dev_tarot.select{|c| !dev_tarot.first(2).include?(c)}.join("").to_i
      ).to_s
      if cards_arr_stripped.include?(dev_tarot_converted)
        # dev_tarot is valid
        drawn_arr = drawn&.split(Deck::CARD_DELIM) || []
        dev_tarot = dev_tarot[0] + dev_tarot_converted
        drawn_arr << dev_tarot
        cards_arr.delete_at(cards_arr_stripped.index(dev_tarot_converted))
        update(
          cards: cards_arr.join(Deck::CARD_DELIM),
          drawn: drawn_arr.join(Deck::CARD_DELIM)
        )
      else
        # dev_tarot is invalid
        dev_tarot = nil
      end

      sleep(1)
    end
  end
end