Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. For a detailed explanation
  # and listing of configuration options, please check the documentation
  # online.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "base"
  config.chef.cookbooks_path = 'cookbooks'
  config.vm.provisioner = :chef_solo
end
