desc "rake install && rspec"
task :make do
  exec "rake install && bundle info aro"
  #exec "rake install && rspec --backtrace"
end
