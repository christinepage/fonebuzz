module TwilioConfig
extend self
	def config_file
	  "#{Rails.root.to_s}/config/twilio_config.yml"
	end

	def config_hash
	  if @config_hash.nil?
      puts "loading Twilio config..."
      @config_hash = YAML.load(ERB.new(File.read("#{config_file}")).result) || {}
    end
	end

	def config_param(key)
	  config_hash[key]
	end

end

puts TwilioConfig.config_hash