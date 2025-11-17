desc "run irb console with aro and autocomplete"
task :console do
  require :irb.to_s
  require :"irb/completion".to_s
  # require :require_all.to_s
  require :aro.to_s
  # require_all 'lib/aro/*.rb'
  # require_all 'lib/models/*.rbe'
  ARGV.clear
  IRB.start
end