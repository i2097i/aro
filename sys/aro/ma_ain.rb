=begin

  ma_ain.rb

  aro dom ma_ain.

  by i2097i

=end

module Aro
  module Dom
    class Ma_ain < Aro::Mancy
      # inherits Singleton

      attr_accessor :ma_ain_menu, :data_mutex, :store_mutex, :stores

      def initialize
        self.data_mutex = Mutex.new
        self.store_mutex = Mutex.new
        @stores = {}
      end

      def self.domain
        self.instance.ma_ain_menu.nil? ? super : "#{Aro::Mancy.aro_mancy_name}#{Aro::Mancy::A}#{Aro::Dom::Ma_ain}"
      end

      def self.ps1_display(cls_name = nil)
        super(domain)
      end

      def self.run
        return unless Aro::Dom::Ma_ain.instance.ma_ain_menu.nil?
        Aro::Db.ensure_connected!
        Aro::Dom::Ma_ain.instance.ma_ain_menu = Aro::Dom::DataBase.open_menu(:ma_ain)
        begin
          loop do
            current_menu = Aro::Dom::Ma_ain.instance.ma_ain_menu
            selected_menu_item_uuid = Aro::P.p.select(
              "#{current_menu.localized_name}",
              current_menu.menu_items.map{|mi| mi.as_tty},
              show_help: :always,
              cycle: true,
              per_page: 11
            )

            if current_menu.menu_items.count == 1 &&
              current_menu.menu_items.first.tty_name.to_sym == :noop
              Aro::Dom::Designer.design_menu(current_menu)
            else
              Aro::Dom::Designer.design_menu_item(
                current_menu.menu_items.find_by(uuid: selected_menu_item_uuid)
              )
            end
          end
        rescue NoMethodError => e
        rescue StandardError => e
        rescue ThreadError => e
          return [e.inspect] + Thread.current.backtrace
        end

        return ["#{self.name} complete."]
      end

      def get_store_for(aro_file)
        return if aro_file.nil?

        # todo validate aro_file
        if @stores[aro_file.uuid].nil?
          new_store = Aro::Dom::Store.new
          new_store.open_file_path = aro_file.aro_file_path
          @stores[aro_file.uuid] = new_store
        end

        return Aro::Dom::Ma_ain.instance.stores[aro_file.uuid]
      end
    end
  end
end