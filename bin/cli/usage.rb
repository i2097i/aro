=begin
	
	usage.rb

	display aro usage.

	by i2097i

=end

module CLI
	def self.usage
  	IO.popen("less", "w") { |f| f.puts I18n.t("cli.usage") }
	end
end
