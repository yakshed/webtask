# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webtask/version'

Gem::Specification.new do |spec|
  spec.name          = "webtask"
  spec.version       = Webtask::VERSION
  spec.authors       = ["Yakshed / Dirk Breuer"]
  spec.email         = ["yakshed@breuer.io"]

  spec.summary       = %q{Provides a web GUI for your Rake tasks.}
  spec.description   = %q{Rake files are great when dealing with other devs. Which know Ruby. For all others a Rakefile is not very accessible. With webtask you can now make it accessible. Webtask will generate a nice web GUI for your Rakefile.}
  spec.homepage      = "https://github.com/yakshed/webtask"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra", "~> 1.4.7"
  spec.add_dependency "rake"
  spec.add_dependency "thin", "~> 1.7.0"
  spec.add_dependency "haml", "~> 4.0.7"
  spec.add_dependency "markdown", "~> 1.2.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "bourbon", "~> 4.2.7"
  spec.add_development_dependency "neat", "~> 1.8.0"
  spec.add_development_dependency "bitters", "~> 1.2.0"
  spec.add_development_dependency "pry", "~> 0.10"
end
