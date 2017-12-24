# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slack/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'danger-slack'
  spec.version       = Slack::VERSION
  spec.authors       = ['shunsuke maeda']
  spec.email         = ['duck8823@gmail.com']
  spec.description   = 'Notify danger reports to slack.'
  spec.summary       = 'This is plugin for Danger \
                        that notify danger reports to slack.'
  spec.homepage      = 'https://github.com/duck8823/danger-slack'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'danger-plugin-api', '~> 1.0'

  # General ruby development
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.0'

  # Testing support
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'webmock', '~> 2.3'

  # Linting code and docs
  spec.add_development_dependency 'rubocop', '~> 0.49.0'
  spec.add_development_dependency 'yard', '~> 0.9.11'

  # Makes testing easy via `bundle exec guard`
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'

  # If you want to work on older builds of ruby
  spec.add_development_dependency 'listen', '3.0.7'

  # This gives you the chance to run a REPL inside your tests
  # via:
  #
  #    require 'pry'
  #    binding.pry
  #
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency 'pry'

  spec.add_development_dependency 'danger'
  spec.add_development_dependency 'danger-rubocop'
  spec.add_development_dependency 'danger-commit_lint'
end
