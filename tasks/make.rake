desc "rake install && rspec"
task :make do
  exec "rake install && rspec --backtrace"
end
