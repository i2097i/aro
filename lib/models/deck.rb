require :base64.to_s
require_relative './log'

class Deck < ActiveRecord::Base
  has_many :logs

  DECK_FILE = ".deck"

  before_create :populate_cards
  after_commit :generate_log

  def populate_cards
    self.cards = I18n.t("cards.index").join(",")
  end

  def generate_log
    prev_cards = Base64::decode64(logs.last.data) if logs.any?

    if prev_cards.present? && prev_cards != cards || prev_cards.nil?
      logs.create(data: Base64::encode64(cards))
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

  def history
    history_text = I18n.t("cli.messages.history_title", deck: name)
    history_text += "\n"
    logs.reverse.each_with_index{|l, i|
      n_of_text = "#{logs.count - i} of #{logs.count}"
      timestamp = "#{l.created_at.strftime("[%Y:%m:%d:%H:%M:%S]")}"
      history_text += display_cards(
        "(#{n_of_text})\t#{timestamp}",
        Base64::decode64(l.data)
      )
    }

    IO.popen("less -X", "w") { |f| f.puts history_text }
  end

  def shuffle
    update(cards: cards.split(",").shuffle.join(","))
  end

  def display_cards(_title = nil, _cards = nil)
    # default to showing this deck instance's cards
    _title = name if _title.nil?
    _cards = cards if _cards.nil?

    show_str = _title.ljust(7*7) + "\n"
    _cards.split(",").each_with_index{|c, i|
      if i == 77
        show_str += c.center(7*7)
      else
        show_str += c.center(7) + ((i + 1) % 7 == 0 ? "\n" : "")
      end
    }
    show_str += "\n"
    show_str
  end
end