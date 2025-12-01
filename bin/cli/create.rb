=begin
  
  constants.rb

  process aro creation commands

  by i2097i

=end

module CLI
  def self.create
    Aro::Create.new(CLI::ARGV1)
  end
end
