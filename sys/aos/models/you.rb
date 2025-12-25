=begin

  you.rb

  aos you object.

  by i2097i

=end

require_relative :"./base_model".to_s

module Aos
  class You < ActiveRecord::Base
    has_many :ilogs
    has_one :agodo
    has_many :fpxies
    before_validation :set_pwd
    before_create :create_home_directory
    after_update :clear_aos_display

    enum :access, [
      :agodo,
      :user,
      :root,
    ]

    ARO_SRT_FILE = :".aro_srt"

    def generate_ilog(cmd)
      ilogs.create(
        pwd: Aos::Os.osify(pwd),
        cmd: cmd
      )
    end

    def fpx
      {
        name: self.name,
        home: self.home,
        pwd: self.pwd,
      }
    end

    def home!
      h = home
      Aro::D.say("#{__method__}#{Aos::Os::A}#{h}")
      update(pwd: h)
    end

    def home?
      self.pwd == self.home
    end

    def home
      File.join(
        Aro::Dom::dom_root,
        Aro::Dom.room_path(root? ? Aro::Dom::COR : Aro::Dom::HOME),
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

    def stream(lines)
      File.open(File.join(self.home, Aos::You::ARO_SRT_FILE.to_s), "a+") do |aro_srt|
        aro_srt.write(lines.join("\n"))
        aro_srt.write("\n")
      end
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
      Aos::Os.instance.display_lines ||= []
      Aos::Os.instance.display_lines << ">" + Aos::Os.osify(pwd, true)
    end
  end
end