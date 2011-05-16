# FileResourcesManager helps manage global application file_resources stored in 
# a file by giving the application a central location and
# consistent interface no matter where the data is stored

# FileResourcesManager needs a central place to store it's file, the default
# is in the ~/.app_file_resources directory, but it will use the
# APP_SETTINGS environment variable for the directory instead
# if the directory does not exist it will be created on the 
# first get or set or if you call FileResourcesManager.ensure_main_file_resources_file_exists

# Usage:
#      FileResourcesManager.set("business_database",{:adapter => "mysql",:host => "database",...})
#       saves the business database file_resources to the business_database.yml file
#        in the ~/.app_file_resources directory
#      FileResourcesManager.get("business_database")[:adapter]       => "mysql
#       retrieves all the file_resources from the file
#
#      FileResourcesManager.set_file_resources_location("business_database","/var/myapp/values.yml")
#       sets the location for future file_resources to the file "values.yml" at /var/myapp
#
#
#       Full Example:
#       require 'rubygems' #if not in path and ruby version before 1.9.*
#       require 'file_resources_manager'
#       FileResourcesManager.set_file_resources_location("my_login","~/.login_info")
#       FileResourcesManager.set("my_login",{ :username => "JockOfCode",:password => "1235711"})
#       ...
#       #later in program, or in another program...
#       info = FileResourcesManager.get("my_login")
#       SomeWebbyThingie.login(info[:username],info[:password])



require 'fileutils'
require 'yaml'

class FileResourcesManager
	# Loads the file that is referred to by <file_resources_name>
	def self.get file_resources_name
		ensure_main_file_resources_file_exists

		file_resources_file = if file_resources_name == "main_file_resources"
					main_file_resources_filename
				else
					# BTW example of a-b-c recursion
					get_file_resources_location(file_resources_name)
				end

		if File.exists?(file_resources_file)
			return YAML::load(File.read(file_resources_file))
		else
			# a NO_SETTINGS_ERROR could be raised here
			# but I will let the implementer decide on
			# the validation
			return nil
		end
	end
	# Saves the file that is referred to by <file_resources_name>
	def self.set(file_resources_name,file_resources)
		ensure_main_file_resources_file_exists

		file_resources_file = if file_resources_name == "main_file_resources"
					main_file_resources_filename
				else
					get_file_resources_location(file_resources_name)
				end

		File.open(file_resources_file,"w"){|f| f << file_resources.to_yaml }
		return file_resources
	end
	# gets the full path and filename that is loaded when you read <file_resources_name>
	def self.get_file_resources_location(file_resources_name)
		get("main_file_resources")[file_resources_name] || File.join(main_file_resources_file_location, file_resources_name + ".yml")
	end
	# sets the full path and filename that is referred to by <setting_name> to <location>
	def self.set_file_resources_location(file_resources_name,location)
		main_file_resources = get("main_file_resources")
		main_file_resources[file_resources_name] = location
		set("main_file_resources",main_file_resources)
		self
	end

	class << self
		alias file_resources_location get_file_resources_location
	end
	
	def self.file_resources_location=(args)
		set_file_resources_location(*args)
	end


	# gets the directory where the main file_resources file is saved
	def self.main_file_resources_file_location
		ENV["APP_SETTING"] || File.join(Dir.home,".app_file_resources")
	end
	# gets the full path and filename of the main file_resources file
	def self.main_file_resources_filename
		File.join(main_file_resources_file_location,".main_file_resources.yaml")
	end

	# guarantees the directory exists and a file is present at the location the main file_resources file should be at
	def self.ensure_main_file_resources_file_exists
		filename = main_file_resources_filename
		if !File.file?(filename) then 
			FileUtils.mkdir_p(File.dirname(filename))
			File.open(filename,"w"){|f| f << {}.to_yaml }
		end
	end
end

#turns out ruby < 1.9 doesn't have Dir::home
#here is an 80% solution, (Checking for $HOME on a rescue would maybe
#cover more edge cases, next would be username in a /home or /User
#directory 
if Dir.respond_to?(:home) == false
	class Dir
		def self.home
			File.expand_path("~/")
		end
	end
end
