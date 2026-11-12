# frozen_string_literal: true

=begin

  ma_ain.rb

  aro dom ma_ain.

  by i2097i

=end

module Aro
  module Dom
    class Ma_ain < Aro::Mancy
      # inherits Singleton

      # evolution planning
      #
      # Cor       (copy of Aro::Cor)
      # Engine
      # Designer
      # Git
      # Ssh
      # Block     (copy of Aro::Dom::DataBase)
      # Chain     (copy of Aro::Dom::Directory)
      # Node      (copy of Aro::Dom::File)
      # List      (copy of Aro::Dom::Menu)
      # ListItem  (copy of Aro::Dom::MenuItem)
      #
      #

      EXEC_METHODS = [
        :exec_browse_data_bases!,
        :exec_settings!,
        :exec_quit!
      ]

      RUN_MODES = [
        :design,
        :run
      ]

      UNICODE_KEYS = {
        bang:     "\u0021",
        check:    "\u2713",
        close:    "\u2A2F",
        integral: "\u222B",
        secure:   "\u266F",
        unsecure: "\u266D",
        yinyang:  "\u262F",
      }

      attr_accessor :current_menu, :previous_menu
      attr_accessor :data_mutex, :store_mutex
      attr_accessor :stores
      # todo: unused currently. init instance with hashing algo stuff
      attr_accessor :valid_settings
      attr_accessor :run_mode

      def reign!
        begin
          # default mode is :run
          self.run_mode = Aro::Mancy::S
          Aro::P.say("Aro::Dom::Oss_OpenMenu.install!")
          if Aro::Dom::Oss_OpenMenu.install!
            Aro::P.say("Aro::Dom::Oss_OpenMenu.boot!")
            Aro::Dom::Oss_OpenMenu.boot!
          else
            Aro::P.say("installation failed. exiting now...")
            exit
          end
          Aro::P.say("Aro::Dom::Designer.design")
          Aro::Dom::Designer.design
        rescue RuntimeError => e

          Aro::P.say("#{e.class}! #{e.inspect}")
          self.class.i2097i_bookmark
          reign!
        end
      end

      def initialize
        self.data_mutex = Mutex.new
        self.store_mutex = Mutex.new

        @stores = {}
      end

      def self.i2097i_bookmark
        return
        Aro::P.less("\n#{UNICODE_KEYS[:bang] * Aro::Mancy::OS} <breakpoint> #{self.name}\n\n" +
          Thread.current.backtrace[1..].reverse.map{|l|
            l.gsub("#{Reiquire.gem_dir}", "").gsub(Aro::Mancy.root_dir, "")
          }.last(Aro::Mancy::V).join("\n")
        )
        puts __method__
      end

      def self.init!
        root_dir_path = Aro::Cor.ivar(:OSS_OM_HOME)
        return false if root_dir_path.nil? || !Dir.exist?(root_dir_path)
        Aro::P.say("#{self.name} initializing in #{root_dir_path}")
        Aro::Mancy.init(root_dir_path)
      end

      def self.is_encrypted?
        !Aro::Cor.ivar(:oss_om_ssh_key).nil? &&
          !self.instance.valid_settings.nil?
      end

      def self.domain
        self.instance.current_menu.nil? ? super : "#{Aro::Mancy.aro_mancy_name}#{Aro::Mancy::A}#{Aro::Dom::Ma_ain}"
      end

      def self.mini_hud_for(display_text = nil)
        cryption_text = UNICODE_KEYS[
          is_encrypted? ? :secure : :unsecure
        ] + UNICODE_KEYS[:bang]

        if is_encrypted?
          cryption_text = "#{UNICODE_KEYS[:secure]}#{UNICODE_KEYS[:bang]}"
        else
          cryption_text = "#{UNICODE_KEYS[:unsecure]}#{UNICODE_KEYS[:bang]}"
        end

        mode_text = RUN_MODES[self.instance.run_mode || Aro::Mancy::O]
        [
          "(#{cryption_text})[#{mode_text}: ",
          display_text
        ].join("")
      end

      def self.ps1_display(cls_name = nil)
        super(domain)
      end

      def self.open!(data_base = :ma_ain)
        Aro::P.say("Aro::Dom::DataBase.open_menu(#{data_base})")
        staged_menu = nil
        begin
          staged_menu = Aro::Dom::DataBase.open_menu(data_base)
        rescue StandardError => e
          raise "#{self.name} error opening data_base #{data_base}! #{e.inspect}"
        end
        self.instance.previous_menu = self.instance.current_menu
        self.instance.current_menu = staged_menu
      end

      def self.back!
        self.instance.current_menu = nil
        open!
      end

      def self.toggle_run_mode
        self.instance.run_mode = self.instance.run_mode == 0 ? 1 : 0
      end

      def self.running?
        RUN_MODES[self.instance.run_mode || Aro::Mancy::O] == :run
      end

      def self.get_current_options
        options = []

        options << {back: :back, value: :back} unless self.instance.previous_menu.nil?

        options << {name: "#{UNICODE_KEYS[:integral]}(#{Aro::Mancy::ARO_DIRECTORY})", value: :open_menu}

        options += self.instance.current_menu.menu_items.select{|mi| mi.user?}.map{|mi| mi.as_tty}
        options += self.instance.current_menu.menu_items.select{|mi| mi.system?}.map{|mi| mi.as_tty}

        options
      end

      def self.exec_browse_data_bases!
        Aro::Dom::Ma_ain.open!(:browse_data_bases)
      end

      def self.exec_settings!
        Aro::Dom::Ma_ain.open!(:settings)
      end

      def self.exec_quit!
        exit
      end

      def get_store_for(aro_file)
        raise "invalid aro_file!" if aro_file.nil?

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