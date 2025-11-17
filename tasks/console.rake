desc "run irb console with aro and autocomplete"
task :console do
  require :irb.to_s
  require :"irb/completion".to_s
  require :aro.to_s
  ARGV.clear
  IRB.start
end