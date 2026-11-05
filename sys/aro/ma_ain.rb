=begin

  ma_ain.rb

  aro mancy ma_ain.

  by i2097i

=end

module Aro
  module Dom
    class Ma_ain < Aro::Mancy
      # inherits Singleton

      attr_accessor :ma_ain_menu, :data_mutex

      def initialize
        self.data_mutex = Mutex.new
      end

      def self.domain
        Aro::Dom::Ma_ain.instance.ma_ain_menu.nil? ? super : "#{Aro::Mancy.aro_mancy_name}#{Aro::Mancy::A}#{Aro::Dom::Ma_ain}"
      end

      def self.ps1_display(cls_name = nil)
        super(domain)
      end

      def self.run
        Aro::Db.load
        Aro::Dom::Ma_ain.instance.ma_ain_menu = Aro::Dom::DataBase.open_menu(:ma_ain)

        begin
          current_menu = Aro::Dom::Ma_ain.instance.ma_ain_menu
          loop do
            Aro::P.say([
              "loaded menu: #{current_menu.title}"
            ] + JSON.pretty_generate(current_menu.as_json).split("\n"))

            Aro::Cmd.render(current_menu, Aro::P.p.select(
              "#{self.domain} #{current_menu.to_s}",
              current_menu.menu_items.map{|mi|mi.as_tty},
              show_help: :always,
              cycle: true,
              per_page: 11
            ))
          end
        rescue NoMethodError => e
          ["#{__method__} => rescue"] +
            [e.class.to_s, e.to_s] +
            Thread.current.backtrace.last(11)
        rescue StandardError => e
          ["#{__method__} => rescue"] +
            [e.class.to_s, e.to_s] +
            Thread.current.backtrace.last(11)
        end

        return ["#{self.name} complete."]
      end
    end
  end
end