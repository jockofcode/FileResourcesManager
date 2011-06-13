require 'file_resources_manager'

class SettingsManager
	attr_accessor :name,:file_type,:file_location,:filename,:data

	def initialize(settings_name)
		@name = settings_name
		@data,@file_type,@file_location,@filename = nil
		load_data
	end

	def load_data
		smd = SettingsManager.settings_manager_data[@name]
		@file_location = Dir.pwd
		@filename = @name 
		@file_type = :yaml
		if smd then
			@file_type = smd["file_type"].to_sym
			@file_location = smd["file_location"] || Dir.pwd
			@filename = smd["filename"] || @name 

			data = File.read(File.join(@file_location,@filename))
			@data=self.send("decode_" + @file_type.to_s,data)
		else
			@data={}	
		end
		self
	end

	def save_data
		File.open(File.join(@file_location,@filename),"w"){|f|
			case @file_type
			when nil
				@file_type = :yaml
				f << @data.to_yaml
			else
				f << self.send("encode_" + @file_type.to_s,data)
			end
		}
		file_data = {}
		file_data["file_type"] = @file_type.to_s if @file_type
		file_data["file_location"] = @file_location if @file_location
		file_data["filename"] = @filename if @filename
		smd = SettingsManager.settings_manager_data
		smd[@name] = file_data
		SettingsManager.settings_manager_data=smd
	end
	def self.create_encoder(datatype,&encode_method)
		define_method("encode_" + datatype.to_s,&encode_method)
	end

	def self.create_decoder(datatype,&encode_method)
		define_method("decode_" + datatype.to_s,&encode_method)
	end

	def []=(key,value)
		@data[key]=value
	end

	def [](key)
		@data[key]
	end

	def self.settings(settings_name)
		self.new(settings_name)
	end

	def self.settings_manager_data
		YAML::load(FileResourcesManager::get(".settings")||{}.to_yaml)
	end

	def self.settings_manager_data=(data)
		FileResourcesManager::set(".settings",data.to_yaml)
		self
	end
end

SettingsManager.create_encoder(:yaml){|data| data.to_yaml }
SettingsManager.create_decoder(:yaml){|data| YAML::load(data) }

# I think my encoder for csv is wonked, will fix someother time, dinner time!!
SettingsManager.create_encoder(:csv){|data| lines = []; data.each{|k,v| lines << [k,v].join(",") }; lines.join("\n") }
SettingsManager.create_decoder(:csv){|data| data.split.inject({}){|hash,line| hash[line.split(",").first] = line.split(",").last } }


SettingsManager.create_encoder(:csv){|data| data.to_yaml }
SettingsManager.create_decoder(:csv){|data| YAML::load(data) }
