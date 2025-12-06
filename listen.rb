require :listen.to_s

listener = Listen.to(*[:sys.to_s, :bin.to_s, :spec.to_s], only: /[\.rb\.yml]/) {|modified, added, removed|
  system("exec rake make")
}
listener.start
sleep
