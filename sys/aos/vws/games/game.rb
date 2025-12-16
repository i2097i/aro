=begin

  vws/games/game.rb

  the game view.

  by i2097i

=end

require_relative :"../../../aro/models/teck".to_s
require_relative :"../base".to_s

module Aos
  module Vw
    class Game < Aos::Vw::Base

      DECK_PARAMS = [
        :teck,
        :tlog_records,
        :count_n,
        :order_o,
      ]

      def self.show
        unless Aro::Mancy.game.nil?
          Aro::Mancy.game.show
          return
        end

        lines = []
        lines << I18n.t("aos.views.game.title").center(viewport_width)
        lines << I18n.t("aos.views.game.description").center(viewport_width)

        room_def = Aro::Dom::D::WINGS[:GAMES].values.filter{|gr|
          "#{Aos::Vw.name}::#{gr[:name].to_s.downcase.capitalize}" == self.name
        }.first
        unless room_def.nil?
          lines << I18n.t("aos.views.game.is_the", name: room_def[:name].to_s)
          lines << I18n.t("aos.views.game.designed_for", description: room_def[:description])
        end

        draw(lines)
      end

      def self.show_game(model)
        mk = model.keys
        dp = Aos::Vw::Game::DECK_PARAMS
        return nil unless (mk & dp).count == dp.count
        return nil unless model.values.all?{|v| v != nil}

        teck = model[:teck]
        tlog_records = model[:tlog_records]
        count_n = model[:count_n]
        order_o = model[:order_o]

        dc = Aro::Config.display_configuration
        width = count_n == Aro::Mancy::S ? viewport_width : dc[:WIDTH]
        divider = dc[:DIVIDER] * width
        lines = []
        lines << divider
        lines << "#{teck.name.upcase.center(width)}"
        tlog_records.each_with_index{|l, i|
          lines << divider
          lines << ""
          timestamp = l.created_at.strftime(Aro::Config::DATE_FORMAT)
          of_text = "#{order_o.to_sym == Aro::Tlog::ORDERING[:DESC] ? teck.tlogs.count - i : 1 + i} of #{teck.tlogs.count}"
          lines << of_text.ljust(width - timestamp.length) + timestamp
          lines << divider
          cards = Base64::decode64(l.card_data).split(Aro::Teck::CARD_DELIM.to_s)
          if !cards.nil? && cards.any?
            # lines << ""
            lines += self.get_display_for_cards(cards)
            # lines << divider
          end

          drawn_cards = Base64::decode64(l.drawn_data).split(Aro::Teck::CARD_DELIM.to_s)
          if !drawn_cards.nil? && drawn_cards.any?
            lines << ""
            lines << I18n.t("cli.messages.history_drawn").center(width)
            lines << divider
            lines << ""
            lines += self.get_display_for_cards(
              drawn_cards
            )
            # lines << ""
            # lines << divider
          end
        }
        if count_n == Aro::Mancy::S
          draw(lines)
        else
          Aro::P.less(lines.join("\n"))
        end
      end

      def self.get_display_for_cards(input = [])
        columns = Aos::Vw::Base::COL_POW.call(
          Aro::Config.display_configuration[:WIDTH].to_i
        )
        lines = []
        return lines unless input.any?
        card_line = ""
        input.each_with_index{|c, i|
          s = (i + Aro::Mancy::S) % [Aro::Mancy::S, columns].max
          card_line += c.ljust(columns)
          if Aro::Mancy::O == s || i == input.count - Aro::Mancy::S
            lines << card_line
            card_line = ""
          end
        }
        lines << ""
        lines
      end
    end
  end
end