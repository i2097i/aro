=begin

  you.rb

  aos you object.

  by i2097i

=end

module Aos
  class You < ActiveRecord::Base
    has_many :ilogs
    has_one :agodo
    has_many :fpxies
    before_validation :set_pwd
    after_create :create_home_directory
    after_update :clear_aos_display

    enum :access, [
      :agodo,
      :user,
      :root,
    ]

    def generate_ilog(cmd)
      ilogs.create(
        pwd: Aos::Os.osify(pwd),
        cmd: cmd
      )
    end

    def home!
      update(pwd: home)
    end

    def home?
      self.pwd == self.home
    end

    def home
      File.join(
        Aro::Dom::dom_root,
        Aro::Dom.room_path(root? ? Aro::Dom::CONFIG : Aro::Dom::HOME),
        root? ? "" : self.name
      )
    end

    def get_lines
      [
        I18n.t(
          "data.yous.display",
          name: name&.ljust(Aro::Mancy::NUMERALS[:XIV]),
          access: access&.ljust(Aro::Mancy::NUMERALS[:XIV]),
          pwd: Aos::Os.osify(pwd)&.ljust(Aro::Mancy::NUMERALS[:XIV])
        )
      ]
    end

    private

    def set_pwd
      self.pwd = Dir.pwd if self.pwd.nil?
    end

    def create_home_directory
      return if root? || agodo? || Dir.exist?(File.join(Aro::Dom.room_path(Aro::Dom::HOME), self.name))
      Aro::Dom.instance.generate_room(Aro::Dom::D::LAYOUT[:HOME], {name: self.name.to_sym})
    end

    def clear_aos_display
      return unless Aos::Os.instance.you == self || Aos::Os.instance.you_flag == self
      Aro::Config.instance.config_path = nil
      # Aro::Config.instance.load
      Aos::Os.instance.display_lines = [Aos::Os.osify(pwd, true)]
    end
  end
end