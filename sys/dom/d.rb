=begin
  
  d.rb

  dom definition.

  by i2097i

=end

require_relative :dom.to_s
require_relative :"../shr/prompt".to_s

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
          # todo: make a wai/wait/wae learning tool for practicing
          # command usage in a sandbox.
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
        BODY: {
          name: Aro::Dom::BODY,
          description: I18n.t("dom.rooms.body.description"),
        },
        MIND: {
          name: Aro::Dom::MIND,
          description: I18n.t("dom.rooms.mind.description"),
        },
        SPIRIT: {
          name: Aro::Dom::SPIRIT,
          description: I18n.t("dom.rooms.spirit.description"),
        },
      },
      ROOT: {
        AMG: {
          name: Aro::Dom::AMG,
          description: I18n.t("dom.rooms.amg.description"),
        },
        CONFIG: {
          name: Aro::Dom::CONFIG,
          description: I18n.t("dom.rooms.config.description"),
        },
        DATA: {
          name: Aro::Dom::DATA,
          description: I18n.t("dom.rooms.data.description"),
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
          Aro::Dom::D::WINGS[:KNOW][:BODY],
          Aro::Dom::D::WINGS[:KNOW][:MIND],
          Aro::Dom::D::WINGS[:KNOW][:SPIRIT],
        ],
      },
      ROOT: {
        name: Aro::Dom::ROOT,
        description: I18n.t("dom.wings.root.description"),
        rooms: [
          Aro::Dom::D::WINGS[:ROOT][:AMG],
          Aro::Dom::D::WINGS[:ROOT][:CONFIG],
          Aro::Dom::D::WINGS[:ROOT][:DATA],
        ],
      }
    }

  end
end
