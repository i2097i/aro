=begin

  you.rb

  aos you object.

  by i2097i

=end

module Aos
  class You < ActiveRecord::Base
    after_commit :update_aos_pwd

    def update_aos_pwd
      Dir.chdir(pwd)
    end
  end
end