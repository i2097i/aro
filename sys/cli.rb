=begin
  
  cli

  aro cli module.

  by i2097i

=end

module CLI
  # todo: make this filtering better. dom uses :new as well
  if CLI::CMDS[:TECK].values.filter{|k| ![:new].include?(k)}.include?(ARGV[0]&.to_sym)
    # enable teck shortcut (skip typing teck while in-game)
    ARGV0 = :teck
    ARGV1 = ARGV[0]&.to_sym
    ARGV2 = ARGV[1]&.to_sym
  else
    # default
    ARGV0 = ARGV[0]&.to_sym
    ARGV1 = ARGV[1]&.to_sym
    ARGV2 = ARGV[2]&.to_sym
  end
end
