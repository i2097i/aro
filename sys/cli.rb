=begin
  
  cli

  aro cli module.

  by i2097i

=end

module CLI
  # todo: set an Aro::Mancy.instance.you variable here:
  argv_sanitized = Aos::Os.sanitize_you(ARGV.join(" ")).split(" ")

  if CLI::CMDS[:DECK].values.include?(argv_sanitized[0]&.to_sym)
    # enable teck shortcut (skip typing teck while in-game)
    ARGV0 = :teck
    ARGV1 = argv_sanitized[0]&.to_sym
    ARGV2 = argv_sanitized[1]&.to_sym
  else
    # default
    ARGV0 = argv_sanitized[0]&.to_sym
    ARGV1 = argv_sanitized[1]&.to_sym
    ARGV2 = argv_sanitized[2]&.to_sym
  end
end
