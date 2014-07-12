require 'twilio-ruby'
 
class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header
  before_filter :validate_request
  skip_before_action :verify_authenticity_token

  def validate_request
    @auth_token = "ce3887304e72ec11afbb73811c9305ae"
    validator = Twilio::Util::RequestValidator.new(@auth_token)
    uri = request.original_url
    signature = request.headers['HTTP_X_TWILIO_SIGNATURE']
    logger.debug "uri: #{uri}"
    logger.debug "sig: #{signature}"
    logger.debug "par: #{params}"
    if !(validator.validate uri, params, signature)
      logger.debug "Validation failed"
      redirect_to root_url
    else
      logger.debug "Validation succeeded"
    end
  end

  def voice
    debugger
    logger.debug "::voice: headers:"
    logger.debug "HTTP_X_TWILIO_SIGNATURE: #{request.headers['HTTP_X_TWILIO_SIGNATURE']}"
    response = Twilio::TwiML::Response.new do |r|      
      r.Say 'Hello there. '
      r.Gather :numDigits => '1', :action => 'handlegather', :method => 'post' do |g|
        g.Say 'Please enter a number.'        
      end
    end
    render_twiml response
  end

  def handlegather
    response = Twilio::TwiML::Response.new do |r|
      input_num = params['Digits'] || "nothing"

      logger.debug "params: #{params}"
      logger.debug "Input was #{input_num}"

      r.Say 'You entered ' + input_num
      if (integer_str? input_num)
        r.Say "Your results are " + fizzbuzz(Integer(input_num)).join(", ")
      else
        r.Say "I have no results for that entry."
      end
    end
    render_twiml response
  end

end


def integer_str? num
  Integer(num)
  return true
rescue ArgumentError
  return false
end

def fizzbuzz num
    (1..num).map do |x|
      if ((x%15) == 0)
        "FizzBuzz"
      elsif ((x%5) == 0)
        "Buzz"
      elsif ((x%3) == 0)
        "Fizz"
      else
        String(x)
      end
    end
end

