require 'settings_manager'
require 'minitest/unit'
require 'fileutils'


class TestSettingsManager < Test::Unit::TestCase
	@@test_directory_location = File.join(Dir.pwd,"file_resources_location_test")
	def setup
		puts "setup called"
		remove_test_directory
		FileUtils.mkdir_p(@@test_directory_location)
	end
	def remove_test_directory
			if File.directory?(@@test_directory_location) #if the directory already exists then delete all the files out
			(Dir.entries(@@test_directory_location) - [".",".."]).each{|f| 
				File.delete(File.join(@@test_directory_location,f)) 
			}
			Dir.rmdir(@@test_directory_location) # then remove the directory
		end
	end
	def test_initialization
		ENV["APP_SETTING"] = @@test_directory_location
		settings_name = "test_database_info"
		settings = SettingsManager.settings(settings_name)
		settings.file_location = @@test_directory_location
		assert_not_equal(settings,nil,"an empty settings file should not be nil")
		assert_equal(settings.name,settings_name, "just the settings name is set")
		assert_equal(settings.file_type,:yaml,"should be defaulted to yaml")
		settings["server"] = "127.0.0.1"
		assert_equal(settings["server"],"127.0.0.1","server address should match 127.0.0.1")
		assert_equal(settings.file_location,@@test_directory_location ,"should be equal to the current directory")
		assert_equal(settings.filename,settings.name,"should equal the name test_database_info")
		settings.save_data
		
		settings = nil
		settings = SettingsManager.settings(settings_name)
		assert_equal(settings["file_type"],nil,"file_type should still equal nil")
		assert_equal(settings["server"],"127.0.0.1","it should still equal home")

		settings2 = SettingsManager.settings(settings_name+"2")
		settings2.file_location = @@test_directory_location
		settings2.file_type = :csv
		settings2["server"] = "1.1.1.1"
		settings2.save_data
		settings2 = nil
		settings2 = SettingsManager.settings(settings_name+"2")
		assert_equal(settings2["server"],"1.1.1.1","should equal 1.1.1.1")

	end
	def teardown
		puts "teardown called"
		remove_test_directory
	end
end
