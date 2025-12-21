=begin

  teck.rb

  teck object.

  by i2097i

=end

require :base64.to_s
require_relative :"./base_model".to_s

class Aro::Teck < ActiveRecord::Base
  has_many :tlogs

  TECK_FILE = :".aro_teck"
  CARD_DELIM = :","

  before_create :populate_cards
  after_commit :generate_log

  def self.make(new_name)
    Aro::Db.load
    return nil unless Aro::Mancy.is_initialized?
    new_teck = Aro::Teck.create(name: new_name)
    Aro::Teck.select_teck(new_teck) if Aro::Teck.current_teck.nil?
    new_teck
  end

  def self.fresh_cards
    I18n.t("cards.index").map{|c| "+#{c}"}.join(Aro::Teck::CARD_DELIM.to_s)
  end

  def populate_cards
    Aro::Db.load
    self.cards = Aro::Teck.fresh_cards
  end

  def generate_log
    prev_cards = Base64::decode64(tlogs.last.card_data) if tlogs.any?
    if (prev_cards.present? && prev_cards != cards) || (prev_cards.nil? || prev_cards.empty?)
      tlogs.create(
        card_data: Base64::encode64(cards || ""),
        drawn_data: Base64::encode64(drawn || "")
      )
    end
  end

  def self.display_selection_menu
    unless Aro::Teck.any?
      Aro::P.say(I18n.t("cli.messages.no_tecks"))
      exit(CLI::EXIT_CODES[:SUCCESS])
    end
    c_d = Aro::Teck.current_teck
    Aro::Teck.all.each do |d|
      Aro::P.say("#{d.id == c_d.id ? :*.to_s : " "}#{d.id}): #{d.name}")
    end
  end

  def self.select_teck(teck)
    return unless teck.present?
    Aro::P.say(I18n.t("cli.messages.teck_selected", name: teck.name, room: Aro::Mancy::aro_mancy_name))
    File.open(File.join(Aro::Db.base_aro_dir, Aro::Teck::TECK_FILE.to_s), "w") do |file|
      file.write(teck.id)
    end
  end

  def self.current_teck
    Aro::Db.load
    if File.exist?(File.join(Aro::Db.base_aro_dir, TECK_FILE.to_s))
      current_teck_id = File.read(File.join(Aro::Db.base_aro_dir, TECK_FILE.to_s))
      return Aro::Teck.find_by(id: current_teck_id)
    end
  end

  def self.card_strip(card)
    card.gsub(/[+-]/, "").strip
  end

  def show(count_n: Aro::Mancy::S, order_o: Aro::Tlog::ORDERING[:DESC])
    tlogs_count = tlogs.count
    unless count_n.kind_of?(Numeric) && count_n.to_i > Aro::Mancy::O
      if count_n&.to_s&.to_sym == Aro::Mancy::ALL
        count_n = tlogs_count
      else
        count_n = Aro::Mancy::S
      end
    end
    count_n = [[Aro::Mancy::S, count_n.to_i].max, tlogs_count].min
    Aro::V.say("count_n: #{count_n}")
    Aro::V.say("order_o: #{order_o}")

    unless Aro::Tlog::ORDERING.values.include?(order_o)
      Aro::P.say(I18n.t("cli.warnings.invalid_order"))
      order_o = Aro::Tlog::ORDERING[:DESC]
    end

    # perform query
    tlog_records = tlogs.order(created_at: order_o).first(count_n)

    # todo: this is doing more work than it needs to. needs debugging.
    # Aro::V.say("tlog_records.count: #{tlog_records.count}")

    # for now tests just expect count
    return tlog_records if Aos::Cor.is_test?

    Aro::D.say(I18n.t("cli.messages.showing", name: name, count: count_n, order: order_o))

    Aos::Vw::Teck.show_game({
      teck: self,
      tlog_records: tlog_records,
      count_n: count_n,
      order_o: order_o
    })
  end

  def explore
    # allows user to browse each card in the current teck.
    answer = Aos::S.p.select(
      Aro::Mancy::PS1.to_s + I18n.t("cli.messages.choose_card"),
      # formatted for tty-prompt gem
      cards.split(Aro::Teck::CARD_DELIM.to_s).map{|c| [I18n.t("cards.#{Aro::Teck.card_strip(c)}.name"), c]}.to_h,
      per_page: Aos::Cor.display_configuration[:HEIGHT] - Aro::Mancy::S,
      cycle: true,
      default: Aro::Mancy::S
    )
    # {name: "four of swords", tag_list: ["lord of rest from strife", "libra", "jupiter", "introspection", "recuperation", "regain strength", "rest", "solitude", "stability"], reversed_tag_list: ["lord of rest from strife", "libra", "jupiter", "burnt out", "inundated", "need a break", "overwhelmed"], summary: "", reversed_summary: ""}
    definition = I18n.t("cards.#{Aro::Teck.card_strip(answer)}")
    indent = Aro::Mancy::N
    Aro::P.say(definition[:name])
    Aro::P.say(definition[:summary])
    Aro::P.say("tags:")
    definition[:tag_list].sort.each{|tl| Aro::P.say("".rjust(indent) + tl)}
    Aro::P.say(definition[:reversed_summary])
    Aro::P.say("reverse tags:")
    definition[:reversed_tag_list].sort.each{|tl| Aro::P.say("".rjust(indent) + tl)}
  end

  def shuffle
    # shuffles the current teck and generates a log record.
    update(cards: cards.split(Aro::Teck::CARD_DELIM.to_s).shuffle.join(Aro::Teck::CARD_DELIM.to_s))
  end

  def reset
    # completely reset the teck. replace all drawn and reset order.
    # all orientations will be set to upright.
    update(cards: Aro::Teck.fresh_cards, drawn: "")
  end

  def replace
    # replaces all drawn cards FIFO and puts them on the bottom of
    # the teck. this will preserve all card orientations.
    cards_arr = cards.split(Aro::Teck::CARD_DELIM.to_s) || []
    drawn_arr = drawn&.split(Aro::Teck::CARD_DELIM.to_s) || []

    # append each drawn card to cards
    drawn_arr.each{|dc| cards_arr << dc }

    # clear drawn
    update(drawn: "", cards: cards_arr.join(Aro::Teck::CARD_DELIM.to_s))
  end

  def draw(is_dt_dimension: true, z_max: 7, z: 1)
    # the true card
    abs_dev_tarot = nil

    # oriented card
    dev_tarot = nil

    # get cards
    cards_arr = cards.split(Aro::Teck::CARD_DELIM.to_s) || []
    # get abs_cards
    abs_cards_arr = cards_arr.map{|c| Aro::Teck.card_strip(c)}
    # get drawn
    drawn_arr = drawn&.split(Aro::Teck::CARD_DELIM.to_s) || []

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
      cards: cards_arr.join(Aro::Teck::CARD_DELIM.to_s),
      drawn: drawn_arr.join(Aro::Teck::CARD_DELIM.to_s)
    )
  end
end
