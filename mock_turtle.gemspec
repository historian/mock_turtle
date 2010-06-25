# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'bundler'
require 'mock_turtle/version'

Gem::Specification.new do |s|
  s.name        = "mock_turtle"
  s.version     = MockTurtle::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Simon Menke"]
  s.email       = ["simon.menke@gmail.com"]
  s.homepage    = "http://github.com/fd/mock_turtle"
  s.summary     = "From mockup to production in *zero* steps"
  s.description = "Use your HTML mockups directly in Rails. All you need to do is add some attributes to tell Rails where the data should go."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "mock_turtle"

  s.files        = Dir.glob("{app,config,lib}/**/*") + %w(LICENSE README.md)
  s.require_path = 'lib'

  s.add_bundler_dependencies
end