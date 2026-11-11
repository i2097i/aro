require :listen.to_s

listener = Listen.to(*[:sys.to_s, :bin.to_s, :locale.to_s], only: /[oss_om\.rb\.yml]/) {|modified, added, removed|
  # puts modified
  # puts added
  # puts removed 
  system("exec rake make")
}
listener.start
sleep
