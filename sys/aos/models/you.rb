=begin

  you.rb

  aos you object.

  by i2097i

=end

module Aos
  class You < ActiveRecord::Base
    has_many :input_logs
    before_validation :set_pwd
    after_update :clear_aos_display

    enum :access, [
      :user,
      :root,
    ]

    def generate_input_log(cmd)
      input_logs.create(
        pwd: Aos::Os.osify(pwd),
        cmd: cmd
      )
    end

    def get_lines
      [
        I18n.t(
          "data.yous.display",
          name: name,
          access: Aos::You::accesses[access],
          pwd: Aos::Os.osify(pwd)
        )
      ]
    end

    private

    def set_pwd
      self.pwd = Dir.pwd if self.pwd.nil?
    end

    def clear_aos_display
      Aos::Os.instance.display_lines = [Aos::Os.osify(pwd, true)]
    end
  end
end