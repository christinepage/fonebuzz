class WelcomeController < ApplicationController
  def index
  	logger.debug "I'm inside the WelcomeController"
  	
  	if request.headers["HTTP_X_TWILIO_SIGNATURE"]
  		@output = "Twilio called us"
      logger.debug "Got HTTP_X_TWILIO_SIGNATURE header"
  	else
  		@output = "Twilio was NOT involved in this"
      logger.debug "did not get header"
  	end
  end
end