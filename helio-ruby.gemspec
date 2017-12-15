$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'helio/version'

Gem::Specification.new do |s|
  s.name = 'helio-ruby'
  s.version = Helio::VERSION
  s.required_ruby_version = '>= 2.0.0'
  s.summary = 'Ruby bindings for the Helio API'
  s.description = 'Discover design insights with surveys and tests. See https://zurb.com/helio for details.'
  s.author = 'Helio'
  s.email = 'helio@zurb.com'
  s.homepage = 'https://github.com/zurb/helio-ruby'
  s.license = 'MIT'

  s.add_dependency('faraday', '~> 0.10')

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
