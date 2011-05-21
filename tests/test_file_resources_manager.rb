require 'file_resources_manager'
require 'test/unit'

class TestFileResourcesManager < Test::Unit::TestCase
	def test_get
		assert_nil(FileResourcesManager::get("some_non_existing_file_resources"),"There is none so it should most definately fail")
	end
	def test_system_file_resources
		test_directory_location = File.join(Dir.pwd,"file_resources_location_test")
		if File.directory?(test_directory_location) 
			(Dir.entries(test_directory_location) - [".",".."]).each{|f| File.delete(File.join(test_directory_location,f)) }
			Dir.rmdir(test_directory_location) 
		end
		ENV.delete "APP_SETTING"
		assert_equal(FileResourcesManager::main_file_resources_file_location,File.expand_path("~/.app_file_resources"),"if none exist then this should be $HOME/.app_file_resources")
		ENV["APP_SETTING"] = test_directory_location 
		assert_equal(FileResourcesManager::main_file_resources_file_location,test_directory_location,"Main Setting File Location Should be set to the current directory + file_resources_location_test")
		FileResourcesManager::ensure_main_file_resources_file_exists
		assert_equal(File.exists?(File.join(test_directory_location,".main_file_resources.yaml")),true,"file_resources file should have been created")
		assert_equal(FileResourcesManager::get_file_resources_location("test_kv"),File.join(test_directory_location,"test_kv.yml"),"test file_resources file location should match")
		FileResourcesManager::set("test_kv",{:name => "jockofcode",:occupation => "rubyist" })
		assert_equal(FileResourcesManager::get("test_kv")[:name],"jockofcode","should have retreived 'jockofcode' from file_resources")
		FileResourcesManager::set_file_resources_location("test_kv",File.join(test_directory_location,"not_the_default_kv.yml"))
		assert_nil(FileResourcesManager::get("test_kv"),"It should not be getting the value from test_kv.yml anymore")
		FileResourcesManager::set("test_kv",{:name => "john",:occupation => "kneeder"})
		assert_equal(FileResourcesManager::get("test_kv")[:name],"john","should now be john, not jockofcode")
	end
end
