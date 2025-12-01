=begin
  
  version.rb

  display aro version.

  by i2097i

=end

module CLI

  def self.version
    if CLI::FLAGS[:VERSION].include?(CLI::ARGV0)
      Aro::P.p.say(Aro::VERSION)
      exit(CLI::EXIT_CODES[:SUCCESS])
    end
  end
end