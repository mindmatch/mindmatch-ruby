# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mind_match/version"

Gem::Specification.new do |spec|
  spec.name          = "mindmatch"
  spec.version       = MindMatch::VERSION
  spec.authors       = ["MindMatch", "Hugo Duksis", "Kado Damball"]
  spec.email         = ["admin@mindmatch.ai", "duksis@gmail.com", "kadodamball@hotmail.com"]

  spec.summary       = %q{MindMatch api client library for Ruby}
  spec.description   = %q{Api client library for Ruby based on the MindMatch graphql rest api}
  spec.homepage      = "https://github.com/mindmatch/mindmatch-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 0.12"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "vcr", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
