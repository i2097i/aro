=begin

  vws/games/game.rb

  the game view.

  by i2097i

=end

require_relative :"../../../aro/models/teck".to_s
require_relative :"../base".to_s

module Aos
  module Vw
    class Teck < Aos::Vw::Base

      TECK_PARAMS = [
        :teck,
        :tlog_records,
        :count_n,
        :order_o,
      ]

      DIV_CHAR = :"."

      def self.show
        unless Aro::Mancy.teck.nil?
          Aro::Mancy.teck.show
          return
        end

        lines = []
        lines << I18n.t("aos.views.game.title").center(Aos::Vw::Base.viewport_width)
        lines << I18n.t("aos.views.game.description").center(Aos::Vw::Base.viewport_width)

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
        dp = Aos::Vw::Teck::TECK_PARAMS
        return nil unless (mk & dp).count == dp.count
        return nil unless model.values.all?{|v| v != nil}

        teck = model[:teck]
        tlog_records = model[:tlog_records]
        teck_tlog_count = teck.tlogs.count
        count_n = model[:count_n]
        order_o = model[:order_o]

        divider = Aos::Vw::Teck::DIV_CHAR.to_s * Aos::Vw::Base.viewport_width
        lines = []
        lines << divider
        lines << "#{teck.name.upcase.center(Aos::Vw::Base.viewport_width)}"
        tlog_records.each_with_index{|l, i|
          lines << divider
          lines << ""
          timestamp = l.created_at.strftime(Aos::Cor::DATE_FORMAT)
          of_text = "#{order_o.to_sym == Aro::Tlog::ORDERING[:DESC] ? teck_tlog_count - i : 1 + i} of #{teck_tlog_count}"
          lines << Aos::Vw::Base.get_body_line(
            of_text.ljust(Aos::Vw::Base.viewport_width - timestamp.length - Aro::Mancy::OS) + timestamp
          )
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
            lines << I18n.t("cli.messages.history_drawn").center(Aos::Vw::Base.viewport_width)
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
          Aos::Cor.display_configuration[:WIDTH].to_i
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