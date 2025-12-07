=begin
  
  views/games/deck.rb

  the deck game view.

  by i2097i

=end

require_relative :"../base".to_s
require_relative :"../../../models/deck".to_s

module Aos
  module Vi
    class Deck < Aos::Vi::Base

      PARAMS = [
        :deck,
        :h_logs,
        :count_n,
        :order_o,
      ]

      def self.show(model)
        self.debug_log(model)
        mk = model.keys
        dp = Aos::Vi::Deck::PARAMS
        return nil unless (mk & dp).count == dp.count
        return nil unless model.values.all?{|v| v != nil}
        
        deck = model[:deck]
        h_logs = model[:h_logs]
        count_n = model[:count_n]
        order_o = model[:order_o]

        dc = CLI::Config.display_config
        width = dc[:WIDTH] = viewport_width
        divider = dc[:DIVIDER] * viewport_width
        lines = []
        lines << divider
        lines << ""
        lines << "#{deck.name.upcase.center(width)}"
        lines << ""
        h_logs.each_with_index{|l, i|
          lines << divider
          lines << l.created_at.strftime(CLI::Config::DATE_FORMAT).center(width)
          lines << "#{order_o.to_sym == Aro::Log::ORDERING[:DESC] ? deck.logs.count - i : 1 + i} of #{deck.logs.count}".rjust(width)
          lines << divider
          lines << ""
          lines << ""
          lines += self.get_display_for_cards(
            Base64::decode64(l.card_data).split(Aro::Deck::CARD_DELIM.to_s)
          )
          lines << divider
          
          drawn_cards = Base64::decode64(l.drawn_data).split(Aro::Deck::CARD_DELIM.to_s)

          if !drawn_cards.nil? && drawn_cards.any?
            lines << I18n.t("cli.messages.history_drawn").center(width)
            lines << divider
            lines << ""
            lines += self.get_display_for_cards(
              drawn_cards
            )
            lines << ""
            lines << divider
          end
        }
        if count_n == Aro::Mancy::S
          draw(lines)
        else
          Aro::P.less(lines.join("\n"))
        end
      end

      def self.get_display_for_cards(input = [])
        columns = CLI::Config.display_config[:COLUMNS].to_i
        lines = []
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