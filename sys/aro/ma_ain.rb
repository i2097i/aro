=begin

  ma_ain.rb

  aro dom ma_ain.

  by i2097i

=end

module Aro
  module Dom
    class Ma_ain < Aro::Mancy
      # inherits Singleton

      attr_accessor :current_menu
      attr_accessor :oss_om_mutex, :data_mutex, :store_mutex
      attr_accessor :stores
      attr_accessor :oss_om_thread, :oss_om_busy

      def initialize
        self.oss_om_mutex = Mutex.new
        self.data_mutex = Mutex.new
        self.store_mutex = Mutex.new
        self.oss_om_thread = nil
        @stores = {}

        self.oss_om_mutex.synchronize do
          begin
            Thread.new do
              self.start_oss_om_thread
            end
            self.oss_om_thread.join
          rescue NoMethodError => e
          rescue StandardError => e
          rescue ThreadError => e
            Aro::P.say([e.inspect] + Thread.current.backtrace)
          end
        end
      end

      def self.domain
        self.instance.current_menu.nil? ? super : "#{Aro::Mancy.aro_mancy_name}#{Aro::Mancy::A}#{Aro::Dom::Ma_ain}"
      end

      def self.ps1_display(cls_name = nil)
        super(domain)
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

      private

      def start_oss_om_thread
        return if @oss_om_busy
        @oss_om_busy = true
        self.oss_om_thread&.exit
        self.oss_om_thread&.kill
        self.oss_om_thread = Thread.new do
          loop do
            @oss_om_busy = true
            self.oss_om_mutex.synchronize do
              Aro::Dom::Designer.design
            end
            @oss_om_busy = false
          end
        end
      end

    end
  end
end