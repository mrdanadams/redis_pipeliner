# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis_pipeliner/version"

Gem::Specification.new do |s|
  s.name        = "redis_pipeliner"
  s.version     = RedisPipeliner::VERSION
  s.authors     = ["Dan Adams"]
  s.email       = ["mr.danadams@gmail.com"]
  s.homepage    = "https://github.com/mrdanadams/redis_pipeliner"
  s.summary     = %q{Easy pipelining of REDIS commands}
  s.description = %q{Easy pipelining of REDIS commands}

  s.rubyforge_project = "redis_pipeliner"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "redis"
  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"
end
