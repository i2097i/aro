=begin

  you.rb

  aos you object.

  by i2097i

=end

module Aos
  class You < ActiveRecord::Base
    has_many :ilogs
    has_one :agodo
    before_validation :set_pwd
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

    def clear_aos_display
      return unless Aos::Os.instance.you = self
      Aos::Os.instance.display_lines = [Aos::Os.osify(pwd, true)]
    end
  end
end