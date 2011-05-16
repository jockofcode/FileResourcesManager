 #-*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
	s.name        = "file_resources_manager"
	s.version     = 1.0 
	s.platform    = Gem::Platform::RUBY
	s.authors     = ["Branden Giacoletto"]
	s.email       = ["branden@carbondatacomputers.com"]
	s.homepage    = "http://JockOfCode.com/FileResourcesManager"
	s.summary     = "Keeps your app file_resources in a central location"
	s.description = "Instead of having to constantly use YAML::load(File.read('some/dir/with/file_resources/database_blah.yml')) in every app you write, now you can simply use SettingsManager::get('database') to get your file resources and the rest is automagically managed for you!"

	s.required_rubygems_version = ">= 1.3.6"
	s.rubyforge_project         = "file_resources_manager"

	s.add_development_dependency "yaml"

	s.files        = Dir.glob("{lib,tests}/**/*") + %w(LICENSE)
#	s.executables  = ['none']
	s.require_path = 'lib'
end
