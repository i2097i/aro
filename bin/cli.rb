=begin
  
  cli

  the very first file loaded.

  by i2097i

=end

require :aro.to_s
[:cli].each{|d|
  Dir[
    File.join(__dir__, d.to_s, :"*.rb".to_s)
  ].each { |f| require f}
}

# set environment variable
ENV[:ARO_ENV.to_s] = :production.to_s
# ENV[:ARO_ENV.to_s] = :development.to_s

module CLI
  if CLI::CMDS[:DECK].values.include?(ARGV[0]&.to_sym)
    # enable deck shortcut (skip typing deck while in-game)
    ARGV0 = :deck
    ARGV1 = ARGV[0]&.to_sym
    ARGV2 = ARGV[1]&.to_sym
  else
    # default
    ARGV0 = ARGV[0]&.to_sym
    ARGV1 = ARGV[1]&.to_sym
    ARGV2 = ARGV[2]&.to_sym
  end
end
