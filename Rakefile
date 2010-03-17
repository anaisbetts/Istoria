$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'cucumber/rake/task'
require 'vagrant'

Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = %w{--format pretty}
end

Vagrant::Env.load!

task :test => [
  :cucumber
]
