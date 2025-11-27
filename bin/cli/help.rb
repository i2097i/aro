=begin
	
	constants.rb

	process aro creation commands

	by i2097i

=end

module CLI
	def self.help
		if CLI::FLAGS[:HELP].include?(CLI::ARGV1)
		  CLI::usage
		  exit(CLI::EXIT_CODES[:SUCCESS])
		end
	end
end