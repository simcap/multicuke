# -*- encoding: utf-8 -*-
require File.expand_path('../lib/multicuke/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Simon Caplette"]
  gem.description   = %q{Run your features faster}
  gem.summary       = %q{Run one cucumber process per features directory}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "multicuke"
  gem.require_paths = ["lib"]
  gem.version       = Multicuke::VERSION
end
