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

  def self.list
    unless Deck.any?
      Aro::P.p.say("no decks created yet.")
      exit(1)
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

  def show
    Aro::P.p.say(Deck.current_deck.name.center(7*7) + "\n")
    show_str = ""
    cards.split(",").each_with_index{|c, i|
      if i == 77
        show_str += c.center(7*7)
      else
        show_str += c.center(7) + ((i + 1) % 7 == 0 ? "\n" : "")
      end
    }
    Aro::P.p.say show_str
  end

  def shuffle
    update(cards: cards.split(",").shuffle.join(","))
  end
end