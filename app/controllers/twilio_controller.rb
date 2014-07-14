require 'twilio-ruby'
 
class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header
  #before_action :validate_request
  skip_before_action :verify_authenticity_token

  def validate_request
    logger.debug "--------- #{self.class}::#{__method__.to_s} ---------"
    @auth_token = "ce3887304e72ec11afbb73811c9305ae"
    validator = Twilio::Util::RequestValidator.new(@auth_token)
    uri = request.original_url
    signature = request.headers['HTTP_X_TWILIO_SIGNATURE']
    logger.debug "tok: #{@auth_token}"
    logger.debug "uri: #{uri}"
    logger.debug "par: #{params}"
    logger.debug   "provided sig:   #{signature}"
    if !(validator.validate(uri, params, signature))
      logger.debug "Validation failed"
      logger.debug "calculated sig: #{validator.build_signature_for(uri, params)}"
      response = Twilio::TwiML::Response.new do |r|     
        r.Say 'Sorry you are not authorized to use this application.'
      end
      render_twiml response
    else
      logger.debug "Validation succeeded"
    end
  end

  def voice
    logger.debug "--------- #{self.class}::#{__method__.to_s} ---------"
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
    logger.debug "--------- #{self.class}::#{__method__.to_s} ---------"
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

  def initiate_call
    account_sid = 'AC6b20bf0855729dc0658a845feb82a259'
    auth_token = 'ce3887304e72ec11afbb73811c9305ae'
    begin
      @client = Twilio::REST::Client.new account_sid, auth_token
      twilio_tel_num = '+1' + params[:tel_num]

      call = @client.account.calls.create(
        :url => 'http://fast-sea-2300.herokuapp.com/twilio/voice',
        :to => twilio_tel_num,
        :from => '+17079876311')
    rescue Twilio::REST::RequestError => e
      logger.debug e.message
      flash[:notice] = "The call to #{params[:tel_num]} did not go through."
      (flash[:errors] ||= []) << e.message
    end
    redirect_to :controller => 'calls', :action => 'index'
  end

end

def integer_str? num
  Integer(num)
  return true
rescue ArgumentError
  return false
end

def fizzbuzz num
  logger.debug "--------- #{self.class}::#{__method__.to_s} ---------"
  (1..num).map do |x|
    if ((x%15) == 0)
      "FizzBuzz"
    elsif ((x%3) == 0)
      "Fizz"
    elsif ((x%5) == 0)
      "Buzz"
    else
      String(x)
    end
  end
end

