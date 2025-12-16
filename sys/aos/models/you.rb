=begin

  you.rb

  aos you object.

  by i2097i

=end

module Aos
  class You < ActiveRecord::Base
<<<<<<< HEAD
    has_many :ilogs
=======
    has_many :input_logs
>>>>>>> 1f50e46 (WIP: v0.2.2)
    before_validation :set_pwd
    after_update :clear_aos_display

    enum :access, [
      :user,
      :root,
    ]

<<<<<<< HEAD
    def generate_ilog(cmd)
      ilogs.create(
=======
    def generate_input_log(cmd)
      input_logs.create(
>>>>>>> 1f50e46 (WIP: v0.2.2)
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