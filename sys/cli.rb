=begin
  
  cli

  the very first file loaded.

  by i2097i

=end

module CLI
  argv_sanitized = Aos::Os.sanitize_you(ARGV.join(" ")).split(" ")

  if CLI::CMDS[:DECK].values.include?(argv_sanitized[0]&.to_sym)
    # enable deck shortcut (skip typing deck while in-game)
    ARGV0 = :deck
    ARGV1 = argv_sanitized[0]&.to_sym
    ARGV2 = argv_sanitized[1]&.to_sym
  else
    # default
    ARGV0 = argv_sanitized[0]&.to_sym
    ARGV1 = argv_sanitized[1]&.to_sym
    ARGV2 = argv_sanitized[2]&.to_sym
  end
end
