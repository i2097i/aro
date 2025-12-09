=begin
  
  d.rb

  dom definition.

  by i2097i

=end

require_relative :dom.to_s

module Aro
  class Dom::D
    def self.reserved_words
      reserved = []
      Aro::Dom::D::LAYOUT.values.each{|wing|
        reserved << wing[:name].to_s
        wing[:rooms].each{|room| reserved << room[:name].to_s}
      }

      reserved.sort
    end

    # definition of rooms in each layout wing
    WINGS = {
      WELCOME: {
        WAITE: {
          name: Aro::Dom::WAITE,
          description: I18n.t("dom.rooms.waite.description"),
        },
        WINNER: {
          name: Aro::Dom::WINNER,
          description: I18n.t("dom.rooms.winner.description"),
        },
      },
      GAMES: {
        ABPPS: {
          name: Aro::Dom::ABPPS,
          description: I18n.t("dom.rooms.abpps.description"),
        },
        HBPPS: {
          name: Aro::Dom::HBPPS,
          description: I18n.t("dom.rooms.hbpps.description"),
        },
        SHPPS: {
          name: Aro::Dom::SHPPS,
          description: I18n.t("dom.rooms.shpps.description"),
        },
        VIPPS: {
          name: Aro::Dom::VIPPS,
          description: I18n.t("dom.rooms.vipps.description"),
        },
      },
      KNOW: { 
        LIBRARY: {
          name: Aro::Dom::LIBRARY,
          description: I18n.t("dom.rooms.library.description"),
        },
        TEMPLE: {
          name: Aro::Dom::TEMPLE,
          description: I18n.t("dom.rooms.temple.description"),
        },
      },
      SETUP: {
        SETTINGS: {
          name: Aro::Dom::SETTINGS,
          description: I18n.t("dom.rooms.settings.description"),
        },
      },
    }

    # overall layout
    LAYOUT = {
      WELCOME: {
        name: Aro::Dom::WELCOME,
        description: I18n.t("dom.wings.welcome.description"),
        rooms: [
          Aro::Dom::D::WINGS[:WELCOME][:WAITE],
          Aro::Dom::D::WINGS[:WELCOME][:WINNER],
        ]
      },
      GAMES: {
        name: Aro::Dom::GAMES,
        description: I18n.t("dom.wings.games.description"),
        rooms: [
          Aro::Dom::D::WINGS[:GAMES][:ABPPS],
          Aro::Dom::D::WINGS[:GAMES][:HBPPS],
          Aro::Dom::D::WINGS[:GAMES][:SHPPS],
          Aro::Dom::D::WINGS[:GAMES][:VIPPS],
        ],
      },
      KNOW: {
        name: Aro::Dom::KNOW,
        description: I18n.t("dom.wings.know.description"),
        rooms: [
          Aro::Dom::D::WINGS[:KNOW][:LIBRARY],
          Aro::Dom::D::WINGS[:KNOW][:TEMPLE]
        ],
      },
      SETUP: {
        name: Aro::Dom::SETUP,
        description: I18n.t("dom.wings.setup.description"),
        rooms: [
          Aro::Dom::D::WINGS[:SETUP][:SETTINGS]
        ],
      }
    }

  end
end