=begin
  
  usage.rb

  display aro usage.

  by i2097i

=end

module CLI
  def self.usage
    Aro::P.less(I18n.t("usage.main"))
  end
end
