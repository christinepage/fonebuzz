class WelcomeController < ApplicationController
  def index
  	logger.debug "I'm inside the WelcomeController"
  	logger.debug "headers:"
  	logger.debug "#{request.headers.inspect}"
  	if request.headers["X-Twilio-Signature"]
  		@output = "Twilio called us"
  	else
  		@output = "Twilio was NOT involved in this"
  	end
  end
end