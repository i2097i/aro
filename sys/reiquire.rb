=begin
  
  reiquire.rb

  ruby require helpers.

  by i2097i

=end

module Reiquire
  def self.aro
    Reiquire::requires [:aro, :dom, :models, :shr]
  end

  def self.requires(dirs)
    dirs.each{|d|
      Dir[
        File.join(__dir__, d.to_s, :"*.rb".to_s)
      ].each { |f| require f}
    }
  end
end