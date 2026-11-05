=begin
  
  usage.rb

  display aro usage.

  by i2097i

=end

module CLI

  def self.usage_main
    Aro::P.less(I18n.t("usage.main"))
  end

  def self.usage_cor
    Aro::P.less(I18n.t("usage.cor"))
  end

  def self.usage_teck
    Aro::P.less(I18n.t("usage.teck"))
  end

end
