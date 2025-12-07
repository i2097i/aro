=begin
  
  d.rb

  dom definition.

  by i2097i

=end

require_relative :dom.to_s

module Aro
  class Dom::D
    # definition of rooms in each layout section
    WINGS = {
      WELCOME: {
        WAITE: {
          name: Aro::Dom::WAITE,
          description: "sign up."
        },
        WINNER: {
          name: Aro::Dom::WINNER,
          description: "win."
        },
      },
      GAMES: {
        ABPPS: {
          name: Aro::Dom::ABPPS,
          description: "artificial beings."
        },
        HBPPS: {
          name: Aro::Dom::HBPPS,
          description: "human beings."
        },
        SHPPS: {
          name: Aro::Dom::SHPPS,
          description: "human and artificial beings."
        },
        VIPPS: {
          name: Aro::Dom::VIPPS,
          description: "very important - 100% /dev/tarot users."
        },
      },
      KNOW: { 
        LIBRARY: {
          name: Aro::Dom::LIBRARY,
          description: "definition management."
        },
        TEMPLE: {
          name: Aro::Dom::TEMPLE,
          description: "mindfulness management."
        },
      },
      SETUP: {
        SETTINGS: {
          name: Aro::Dom::SETTINGS,
          description: "user settings and configuration."
        },
      },
    }

    # overall layout
    LAYOUT = {
      WELCOME: {
        name: Aro::Dom::WELCOME,
        description: "sign up process.",
        rooms: [
          Aro::Dom::D::WINGS[:WELCOME][:WAITE],
          Aro::Dom::D::WINGS[:WELCOME][:WINNER],
        ]
      },
      GAMES: {
        name: Aro::Dom::GAMES,
        description: "aroflie game rooms.",
        rooms: [
          Aro::Dom::D::WINGS[:GAMES][:ABPPS],
          Aro::Dom::D::WINGS[:GAMES][:HBPPS],
          Aro::Dom::D::WINGS[:GAMES][:SHPPS],
          Aro::Dom::D::WINGS[:GAMES][:VIPPS],
        ],
      },
      KNOW: {
        name: Aro::Dom::KNOW,
        description: "information space.",
        rooms: [
          Aro::Dom::D::WINGS[:KNOW][:LIBRARY],
          Aro::Dom::D::WINGS[:KNOW][:TEMPLE]
        ],
      },
      SETUP: {
        name: Aro::Dom::SETUP,
        description: "user configuration space.",
        rooms: [
          Aro::Dom::D::WINGS[:SETUP][:SETTINGS]
        ],
      }
    }

  end
end