=begin

  uuid.rb

  basic uuid generator for active record

  by i2097i

=end

require "securerandom"

module Aro::Dom::Uuid
  extend ActiveSupport::Concern

  included do
    before_create :generate_uuid
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.send([
      :uuid,
      :uuid_v7,
      :uuid_v4
    ].sample)
  end
end
