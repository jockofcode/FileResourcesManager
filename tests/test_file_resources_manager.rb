require 'settings_manager'
require 'test/unit'

class TestSettingsManager < Test::Unit::TestCase
	def test_get
		assert_nil(SettingsManager::get("some_non_existing_settings"),"There is none so it should most definately fail")
	end
	def test_system_settings
		test_directory_location = File.join(Dir.pwd,"settings_location_test")
		if File.directory?(test_directory_location) 
			(Dir.entries(test_directory_location) - [".",".."]).each{|f| File.delete(File.join(test_directory_location,f)) }
			Dir.rmdir(test_directory_location) 
		end
		ENV.delete "APP_SETTING"
		assert_equal(SettingsManager::main_settings_file_location,File.expand_path("~/.app_settings"),"if none exist then this should be $HOME/.app_settings")
		ENV["APP_SETTING"] = test_directory_location 
		assert_equal(SettingsManager::main_settings_file_location,test_directory_location,"Main Setting File Location Should be set to the current directory + settings_location_test")
		SettingsManager::ensure_main_settings_file_exists
		assert_equal(File.exists?(File.join(test_directory_location,".main_settings.yaml")),true,"settings file should have been created")
		assert_equal(SettingsManager::get_settings_location("test_kv"),File.join(test_directory_location,"test_kv.yml"),"test settings file location should match")
		SettingsManager::set("test_kv",{:name => "jockofcode",:occupation => "rubyist" })
		assert_equal(SettingsManager::get("test_kv")[:name],"jockofcode","should have retreived 'jockofcode' from settings")
		SettingsManager::set_settings_location("test_kv",File.join(test_directory_location,"not_the_default_kv.yml"))
		assert_nil(SettingsManager::get("test_kv"),"It should not be getting the value from test_kv.yml anymore")
		SettingsManager::set("test_kv",{:name => "john",:occupation => "kneeder"})
		assert_equal(SettingsManager::get("test_kv")[:name],"john","should now be john, not jockofcode")
	end
end
