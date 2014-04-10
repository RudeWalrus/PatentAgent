# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'patentagent/version'

Gem::Specification.new do |s|
  s.name        = "patentagent"
  s.version     = Patentagent::VERSION
  s.authors     = ["RudeWalrus"]
  s.email       = ["boss@rudewalrus.com"]
  s.homepage    = "https://github.com/RudeWalrus/PatentAgent"
  s.summary     = %q{Reads patent info from the USPTO and EPO}
  s.description = %q{Reads patent info from the USPTO and EPO}
  s.licenses    = %w[MIT]

  s.rubyforge_project = "patentagent"


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w[lib]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
  s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "nokogiri"
end
