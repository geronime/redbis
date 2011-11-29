# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'redbis/version'

Gem::Specification.new do |s|
	s.name        = 'redbis'
	s.version     = ReDBis::VERSION
	s.authors     = ['Jiri Nemecek']
	s.email       = ['nemecek.jiri@gmail.com']
	s.homepage    = ''
	s.summary     = %q{redis wrapper}
	s.description = %q{Simple redis wrapper to select database by name.}

	s.rubyforge_project = 'redbis'

	s.files         = `git ls-files`.split("\n")
	s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
	s.require_paths = ['lib']

	s.add_dependency 'redis', '~> 2.2.0'

end

