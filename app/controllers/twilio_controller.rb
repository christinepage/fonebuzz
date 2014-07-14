require 'twilio-ruby'
require 'FizzBuzz'
 
class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header
  #before_action :validate_request
  skip_before_action :verify_authenticity_token

  def validate_request
    validator = Twilio::Util::RequestValidator.new(TwilioConfig.config_param('auth_token'))
    signature = request.headers[TwilioConfig.config_param('twilio_signature_header')]
    
    if !(validator.validate(request.original_url, params, signature))
      logger.debug "Validation failed"
      logger.debug "tok: #{@auth_token}"
      logger.debug "url: #{request.original_url}"
      logger.debug "par: #{params}"
      logger.debug "provided sig:   #{signature}"
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
    logger.debug "voice sid:       #{params['CallSid']}"
    call = Call.find_by(:call_sid => params['CallSid'])

    response = Twilio::TwiML::Response.new do |r|
      if call && call.keyed_num
        logger.debug "voice keyed_num: #{call.keyed_num}"
        r.Say 'Hello there. You previously entered #{call.keyed_num}'
        r.Say "Your results are " + FizzBuzz::str_to(call.keyed_num).join(", ")
      else         
        r.Say 'Hello there. '
        r.Gather :numDigits => '1', :action => 'handlegather', :method => 'post' do |g|
          g.Say 'Please enter a number.'        
        end
      end
    end

    render_twiml response
  end

  def handlegather
    logger.debug "handlegather sid:  #{params['CallSid']}"
    call = Call.find_by(:call_sid => params['CallSid'])

    response = Twilio::TwiML::Response.new do |r|
      input_num = params['Digits'] || "nothing"
      r.Say 'You entered ' + input_num
      if (integer_str? input_num)
        if (call)
          call.update(:keyed_num => Integer(input_num))
        end
        r.Say "Your results are " + FizzBuzz::str_to(Integer(input_num)).join(", ")
      else
        r.Say "I have no results for that entry."
      end
    end
    render_twiml response
  end

  def initiate_call
    call = Call.find(params[:call_id])
    if call
      call.update(:call_dt => Time.now)
    end
    begin
      client = Twilio::REST::Client.new TwilioConfig.config_param('account_sid'), TwilioConfig.config_param('auth_token')
      twilio_tel_num = '+1' + params[:tel_num]
      logger.debug "calling #{twilio_tel_num} ..."
      twilio_call = client.account.calls.create(
        :url => 'http://fast-sea-2300.herokuapp.com/twilio/voice',
        :to => twilio_tel_num,
        :from => TwilioConfig.config_param('caller'))
      logger.debug "initiate_call sid: #{twilio_call.sid}"
      call.update(:call_sid => twilio_call.sid)
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


