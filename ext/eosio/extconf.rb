require 'mkmf'

# yarn is a requirement for installing JS bridge dependencies
find_executable('yarn')

File.open(File.join(Dir.pwd, 'eosio.' + RbConfig::CONFIG['DLEXT']), "w") {}

install_result = `yarn install`

if $?.success?
  $makefile_created = true
else
  puts 'Error installing JS dependencies:'
  puts install_result
end
