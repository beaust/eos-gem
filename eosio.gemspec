Gem::Specification.new do |g|
  g.name = 'eosio'
  g.version = File.read 'VERSION'
  g.authors = ['The AUX Team']
  g.date = Time.now.strftime '%Y-%m-%d'
  g.description = 'Wrapper library for interacting with the EOS blockchain.'
  g.email = 'info@auxlabs.io'
  g.files = Dir.glob('{lib}/**/*') + %w(README.md Rakefile)
  g.homepage = 'https://github.com/AuxPlatform/eos-gem'
  g.require_paths = %w(lib)
  g.summary = 'Wrapper library for interacting with the EOS blockchain.'
  g.extensions = ['ext/eosio/extconf.rb']
end
