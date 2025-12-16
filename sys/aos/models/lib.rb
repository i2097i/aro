=begin

  ilib.rb

  aos ilib object.

  by i2097i

=end

# installed lib modules section

module CRS
  SO_FILE = :"libcrs.so".to_s
  SO_PATH = File.join(
    Reiquire::GEM_PATH,
<<<<<<<< HEAD:sys/aos/models/ilib.rb
    :"sys/shr/ilib/crs".to_s,
========
    :"sys/shr/lib/crs".to_s,
>>>>>>>> 1f50e46 (WIP: v0.2.2):sys/aos/models/lib.rb
    CRS::SO_FILE
  )
  extend FFI::Library
  ffi_lib CRS::SO_PATH
  attach_function :hello, [], :string
end

# installed lib modules section

class Aos::Ilib < ActiveRecord::Base
  before_create :set_so_path

  enum :status, [
    :available,
    :installed,
  ]

  def usage
    # todo: each ffi lib should expose a 'usage' method
    CRS.hello.strip
  end

  private

  def set_so_path
    # todo make configurable for other modules
    self.so_path = CRS::SO_PATH
  end
end
