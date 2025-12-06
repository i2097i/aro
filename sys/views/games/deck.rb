=begin
  
  views/games/deck.rb

  the deck game view.

  by i2097i

=end

require_relative :"../base".to_s
require_relative :"../../models/deck".to_s

module Aro
  module Vi
    class Deck < Aro::Vi::Base

      PARAMS = [
        :deck,
        :h_logs,
        :count_n,
        :order_o,
      ]

      def self.generate(model)
        self.debug_log(model)
        mk = model.keys
        dp = Aro::Vi::Deck::PARAMS
        return nil unless (mk & dp).count == dp.count
        return nil unless model.values.all?{|v| v != nil}
        
        deck = model[:deck]
        h_logs = model[:h_logs]
        count_n = model[:count_n]
        order_o = model[:order_o]

        dc = CLI::Config.display_config
        width = dc[:WIDTH]
        divider = dc[:DIVIDER] * width
        result = "\n"
        result += divider + "\n\n"
        result += "#{deck.name.upcase.center(width)}\n\n"
        h_logs.each_with_index{|l, i|
          result += divider + "\n"
          result += l.created_at.strftime(CLI::Config::DATE_FORMAT).center(width) + "\n"
          result += "#{order_o.to_sym == Aro::Log::ORDERING[:DESC] ? deck.logs.count - i : 1 + i} of #{deck.logs.count}".rjust(width) + "\n"
          result += divider + "\n\n"
          result += self.get_display_for_cards(
            Base64::decode64(l.card_data).split(Aro::Deck::CARD_DELIM.to_s)
          )
          result += divider + "\n"
          
          drawn_cards = Base64::decode64(l.drawn_data).split(Aro::Deck::CARD_DELIM.to_s)

          if !drawn_cards.nil? && drawn_cards.any?
            result += I18n.t("cli.messages.history_drawn").center(width) + "\n"
            result += divider + "\n\n"
            result += self.get_display_for_cards(
              drawn_cards
            )
            result += "\n"
            result += divider + "\n"
          end

          Aro::Mancy::OS.times do
            result += divider + "\n"
          end
        }

        result
      end

      def self.get_display_for_cards(input = [])
        columns = CLI::Config.display_config[:COLUMNS].to_i
        result = ""
        input.each_with_index{|c, i|
          
          s = (i + Aro::Mancy::S) % [Aro::Mancy::S, columns].max
          o = Aro::Mancy::O == s
          if i == I18n.t("cards.index").count - Aro::Mancy::S
            result += c.ljust(columns)
          else
            result += c.ljust(columns) + (o ? "\n" : "")
          end
        }
        result += "\n"
        result
      end

      def self.draw(model)
        return false unless model.kind_of?(String)

        Aro::P.say(model)
      end
    end
  end
end